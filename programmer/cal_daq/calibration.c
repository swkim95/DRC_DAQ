#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include "NoticeCALTCB.h"
#include "NoticeCALDAQ.h"

int main(int argc, char *argv[])
{
  int mid_to_cal;
  int sid = 0;
  unsigned long link_data[2];
  int linked[40];
  unsigned long mid_data[40];
  int ch;
  int mid_found;
  int mid;
  char data[65536];
  int i;
  int offset[32][1024];
  int count[32][1024];
  int evt;
  int adc;
  int tmp;
  char filename[256];
  FILE *fp;
  int max;
  char lut[32768];

  // get mid
  if (argc < 2) {
    printf("enter MID : ");
    scanf("%d", &mid_to_cal);
  }
  else 
    mid_to_cal = atoi(argv[1]);

  // init LIBUSB
  USB3Init();
    
  // open TCB
  CALTCBopen(sid);
  
  // get link status
  CALTCBread_LINK(0, link_data);
  CALTCBread_LINK(sid, link_data);

  for (ch = 0; ch < 32; ch++)
    linked[ch] = (link_data[0] >> ch) & 0x1;
  for (ch = 32; ch < 40; ch++)
    linked[ch] = (link_data[1] >> (ch - 32)) & 0x1;
  
  // read mid of linked DAQ modules
  CALTCBread_MID(sid, mid_data);

  // find module
  mid_found = 0;
  for (ch = 0; ch < 40; ch++) {
    if (linked[ch]) {
      if (mid_data[ch] == mid_to_cal) {
        printf("mid %d is found at ch%d\n", mid_to_cal, ch + 1);
        ch = 40;
        mid_found = 1;
      }
    }
  }
  
  if (mid_found) {
    mid = mid_to_cal;

    // reset DAQ    
    CALTCBreset(sid);

    // initialize DAQ
    CALTCB_DRSinit(sid, mid);

    // write setting
    CALTCBwrite_CW(sid, 0, 10);
    CALTCBwrite_PEDESTAL_TRIGGER_INTERVAL(sid, 0);
    CALTCBwrite_TRIGGER_ENABLE(sid, 4);
    CALTCBwrite_MULTIPLICITY_THR(sid, 0, 1);
    CALTCBwrite_CW(sid, mid, 3);
    CALTCBwrite_MULTIPLICITY_THR(sid, mid, 1);
    CALTCBwrite_TRIGGER_DELAY(sid, mid, 0);
    CALTCBwrite_TRIGGER_LATENCY(sid, mid, 250);
    CALTCBwrite_RUN_NUMBER(sid, mid, 1);
 
    // turn on calibration mode    
    CALTCBwrite_DRS_CALIB(sid, mid, 1);

    // initialize offset 
    for (ch = 0; ch < 32; ch++) {
      for (i = 0; i < 1024; i++)
        offset[ch][i] = 0;
        count[ch][i] = 0;
    }
    
    // open DAQ
    CALDAQopen(mid);

    // start DAQ
    CALTCBstart_DAQ(sid);
    
    // get 1000 event
    for (evt = 0; evt < 1000; evt++) {
      // wait for data
      while (!CALDAQread_DATASIZE(mid)) 
        CALTCBsend_TRIG(sid);
      
      // read data
      CALDAQread_DATA(mid, 64, data);
      
      // fill offset
      for (ch = 0; ch < 32; ch++) {
        for (i = 0; i < 1024; i++) {
          adc = data[i * 64 + ch * 2] & 0xFF;
          tmp = data[i * 64 + ch * 2 + 1] & 0xFF;
          tmp = tmp << 8;
          adc = adc + tmp;
          
          if (adc > 3000) {
            offset[ch][i] = offset[ch][i] + adc;
            count[ch][i] = count[ch][i] + 1;
          }
        }
      }
    }

    // stop DAQ
    CALTCBstop_DAQ(sid);
    
    // get average
    for (ch = 0; ch < 32; ch++) {
      for (i = 0; i < 1024; i++) {
        offset[ch][i] = (offset[ch][i] + count[ch][i] / 2) / count[ch][i];
      }
    }

    // find maximum & offset
    sprintf(filename, "offset_%d.txt", mid);
    fp = fopen(filename, "wt");
    for (ch = 0; ch < 32; ch++) {
      max = 0;
      for (i = 0; i < 1024; i++) {
        if (offset[ch][i] > max)
          max = offset[ch][i];
      }

      for (i = 0; i < 1024; i++) {
        fprintf(fp, "%d  %d  %d\n", ch, i, offset[ch][i]);
        offset[ch][i] = max - offset[ch][i];
        lut[ch * 1024 + i] = offset[ch][i] & 0xFF;
      }
    }    
    fclose(fp);
    
    // write file
    sprintf(filename, "calLUT_%d.dat", mid);
    fp = fopen(filename, "wb");
    fwrite(lut, 1, 32768, fp);
    fclose(fp);

    // close DAQ
    CALDAQclose(mid);

    // reset DAQ
    CALTCBreset(sid);
  }
  else
    printf("No module is found!\n");
  
  // close TCB
  CALTCBclose(sid);

  // exit LIBUSB
  USB3Exit();

  return 0;
}


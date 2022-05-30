#include <unistd.h>
#include <stdio.h>
#include "NoticeCALTCB.h"

int main(void)
{
  // settings used in case setup.txt does not exist
  int sid = 0;
  float hv = 57.0;
  unsigned long cw = 1;
  unsigned long run_number = 2;
  unsigned long pedestal_trigger_interval = 0;
  unsigned long trigger_enable = 0xF;
  unsigned long multiplicity_thr = 1;
  unsigned long trigger_delay = 0;
  unsigned long thr = 100;

  // local variables
//  char filename[256];
//  FILE *fp_setup;
  unsigned long link_data[2];
  int linked[40];
  int num_of_daq;
  int ch;
  unsigned long mid_data[40];
  unsigned long mid[40];
  int daq;

/*
  // read common setup file
  if ((access("setting/setup_com.txt", 0)) == 0) {
    fp_setup = fopen("setting/setup_com.txt", "rt");
    fscanf(fp_setup, "%f", &hv);
    fscanf(fp_setup, "%ld", &psw);
    fscanf(fp_setup, "%ld", &risetime);
    fscanf(fp_setup, "%ld", &psd_dly);
    fclose(fp_setup);
  }
  */

  // init LIBUSB
  USB3Init();
    
  // open TCB
  CALTCBopen(sid);

  // start DRS
  CALTCBstart_DRS(sid);
  CALTCBstop_DRS(sid);

  // reset
  CALTCBreset(sid);
  
  // check linked DAQ modules
  CALTCBread_LINK(sid, link_data);
  for (ch = 0; ch < 32; ch++)
    linked[ch] = (link_data[0] >> ch) & 0x1;
  for (ch = 32; ch < 40; ch++)
    linked[ch] = (link_data[1] >> (ch - 32)) & 0x1;
  
  // read mid of linked DAQ modules
  CALTCBread_MID(sid, mid_data);
  
  // assgin DAQ index
  num_of_daq = 0;
  
  for (ch = 0; ch < 40; ch++) {
    if (linked[ch]) {
      mid[num_of_daq] = mid_data[ch];
      printf("mid %ld is found at ch%d\n", mid[num_of_daq], ch + 1);
      num_of_daq = num_of_daq + 1;
    }
  }
  
  // setting TCB
  CALTCBwrite_CW(sid, 0, cw);
  CALTCBwrite_RUN_NUMBER(sid, run_number);
  CALTCBwrite_PEDESTAL_TRIGGER_INTERVAL(sid, pedestal_trigger_interval);
  CALTCBwrite_TRIGGER_ENABLE(sid, trigger_enable);
  CALTCBwrite_MULTIPLICITY_THR(sid, 0, multiplicity_thr);
  CALTCBwrite_TRIGGER_DELAY(sid, trigger_delay);

  printf("TCB CW = %ld\n", CALTCBread_CW(sid, 0));
//extern unsigned long CALTCBread_RUN_NUMBER(int sid);
//extern unsigned long CALTCBread_PEDESTAL_TRIGGER_INTERVAL(int sid);
//extern unsigned long CALTCBread_TRIGGER_ENABLE(int sid);
//extern unsigned long CALTCBread_MULTIPLICITY_THR(int sid, unsigned long mid);
//extern unsigned long CALTCBread_TRIGGER_DELAY(int sid);


  for (daq = 0; daq < num_of_daq; daq++) {
  /*
    // read DAQ setup file
    sprintf(filename, "setting/setup_%ld.txt", mid[daq]);
    if ((access(filename, 0)) == 0) {
      fp_setup = fopen(filename, "rt");
      for (ch = 1; ch <= 32; ch++) {
        fscanf(fp_setup, "%ld", thr + ch);
        fscanf(fp_setup, "%f", psd_thr_l + ch);
        fscanf(fp_setup, "%f", psd_thr_m + ch);
        fscanf(fp_setup, "%f", psd_thr_h + ch);
      }
      fclose(fp_setup);
    }
    else {
      for (ch = 1; ch <= 32; ch++) {
        thr[ch] = 100;
        psd_thr_l[ch] = 0.010;
        psd_thr_m[ch] = 0.200;
        psd_thr_h[ch] = 0.400;
      }
    }
    */

    CALTCBwrite_CW(sid, mid[daq], cw);
    //CALTCBwrite_MULTIPLICITY_THR(sid, mid[daq], multiplicity_thr);
    CALTCBalign_DRAM(sid, mid[daq]);
    CALTCB_DRSinit(sid, mid[daq]);

    // setting DAQ
    for (ch = 1; ch <= 4; ch++)
      CALTCBwrite_HV(sid, mid[daq], ch, hv);
    for (ch = 1; ch <= 32; ch++)
      CALTCBwrite_THR(sid, mid[daq], ch, thr);

    // readback DAQ setting
    //extern unsigned long CALTCBread_CW(int sid, unsigned long mid);
    printf("Temperature = %f\n", CALTCBread_TEMP(sid, mid[daq]));
    //extern unsigned long CALTCBread_DRS_PLL_LOCKED(int sid, unsigned long mid);


    for (ch = 1; ch <= 4; ch++) 
      printf("mid = %ld, ch%d HV = %f\n", mid[daq], ch, CALTCBread_HV(0, mid[daq], ch));
//    for (ch = 1; ch <= 32; ch++) 
//extern unsigned long CALTCBread_THR(int sid, unsigned long mid, unsigned long ch);
  }

  // reset
  CALTCBreset(sid);

  // close TCB
  CALTCBclose(sid);

  // exit LIBUSB
  USB3Exit();

  return 0;
}




#include <unistd.h>
#include <stdio.h>
#include "NoticeSIPMTCB.h"

int main(void)
{
  // settings used in case setup.txt does not exist
  float hv = 57.0;
  unsigned long psw = 1000;
  unsigned long risetime = 60;
  unsigned long psd_dly = 80;
  unsigned long thr[33];
  float psd_thr_l[33];
  float psd_thr_m[33];
  float psd_thr_h[33];

  // local variables
  char filename[256];
  FILE *fp_setup;
  unsigned long link_data[2];
  int linked[40];
  int num_of_daq;
  int ch;
  unsigned long mid_data[40];
  unsigned long mid[40];
  int daq;

  // read common setup file
  if ((access("setting/setup_com.txt", 0)) == 0) {
    fp_setup = fopen("setting/setup_com.txt", "rt");
    fscanf(fp_setup, "%f", &hv);
    fscanf(fp_setup, "%ld", &psw);
    fscanf(fp_setup, "%ld", &risetime);
    fscanf(fp_setup, "%ld", &psd_dly);
    fclose(fp_setup);
  }

  // init LIBUSB
  USB3Init();
    
  // open TCB
  SIPMTCBopen(0);

  // reset
  SIPMTCBreset(0);
  
  // check linked DAQ modules
  SIPMTCBread_LINK(0, link_data);
  for (ch = 0; ch < 32; ch++)
    linked[ch] = (link_data[0] >> ch) & 0x1;
  for (ch = 32; ch < 40; ch++)
    linked[ch] = (link_data[1] >> (ch - 32)) & 0x1;
  
  // read mid of linked DAQ modules
  SIPMTCBread_MID(0, mid_data);
  
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
  SIPMTCBwrite_SCAN_TIME(0, 100000);

  for (daq = 0; daq < num_of_daq; daq++) {
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

    // setting DAQ
    for (ch = 1; ch <= 4; ch++)
      SIPMTCBwrite_HV(0, mid[daq], ch, hv);
    for (ch = 1; ch <= 32; ch++)
      SIPMTCBwrite_THR(0, mid[daq], ch, thr[ch]);
    SIPMTCBwrite_PSW(0, mid[daq], psw);
    SIPMTCBwrite_RISETIME(0, mid[daq], risetime);
    SIPMTCBwrite_PSD_DLY(0, mid[daq], psd_dly);
    for (ch = 1; ch <= 32; ch++) {
      SIPMTCBwrite_PSD_THR(0, mid[daq], ch - 1, psd_thr_l[ch]);
      SIPMTCBwrite_PSD_THR(0, mid[daq], 32 + ch - 1, psd_thr_m[ch]);
      SIPMTCBwrite_PSD_THR(0, mid[daq], 64 + ch - 1, psd_thr_h[ch]);
    }

    // readback DAQ setting
    for (ch = 1; ch <= 4; ch++) 
      printf("mid = %ld, ch%d HV = %f\n", mid[daq], ch, SIPMTCBread_HV(0, mid[daq], ch));
    for (ch = 1; ch <= 4; ch++) 
      printf("mid = %ld, ch%d Temperature = %f\n", mid[daq], ch, SIPMTCBread_TEMP(0, mid[daq], ch));
    for (ch = 1; ch <= 32; ch++) 
      printf("mid = %ld, ch%d Pedestal = %ld\n", mid[daq], ch, SIPMTCBread_PED(0, mid[daq], ch));
    for (ch = 1; ch <= 32; ch++) 
      printf("mid = %ld, ch%d Threshold = %ld\n", mid[daq], ch, SIPMTCBread_THR(0, mid[daq], ch));
    printf("mid = %ld, Peak sum width = %ld\n", mid[daq], SIPMTCBread_PSW(0, mid[daq]));
    printf("mid = %ld, Pulse risetime = %ld\n", mid[daq], SIPMTCBread_RISETIME(0, mid[daq]));
    printf("mid = %ld, PSD delay = %ld\n", mid[daq], SIPMTCBread_PSD_DLY(0, mid[daq]));
    for (ch = 1; ch <= 32; ch++) 
      printf("mid = %ld, PSD threshold = %f %f %f\n", mid[daq], SIPMTCBread_PSD_THR(0, mid[daq], ch - 1)
                                                              , SIPMTCBread_PSD_THR(0, mid[daq], 32 + ch - 1)
                                                              , SIPMTCBread_PSD_THR(0, mid[daq], 64 + ch -1));
  }

  // reset
  SIPMTCBreset(0);

  // close TCB
  SIPMTCBclose(0);

  // exit LIBUSB
  USB3Exit();

  return 0;
}




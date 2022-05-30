#include <unistd.h>
#include <stdio.h>
#include "NoticeCALTCB.h"

int main(void)
{
  // setting here
  unsigned long cw = 1;
  unsigned long run_number = 5;
  unsigned long pedestal_trigger_interval = 0;
  unsigned long trigger_enable = 0xF;
  unsigned long multiplicity_thr = 1;
  unsigned long trigger_delay = 0;
  float hv = 38.0;
  unsigned long thr = 100;

  int sid = 0;
  int mid;
  unsigned long link_data[2];
  int linked[40];
  unsigned long mid_data[40];
  unsigned long ch;

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

  for (ch = 0; ch < 40; ch++) {
    if (linked[ch]) {
      mid = mid_data[ch];
      printf("mid %d is found at ch%ld\n", mid, ch + 1);
      // first come, first served
      ch = 40;
    }
  }

  // reset DAQ
  //CALTCBresetTIMER(sid);   // optional timer reset
  CALTCBreset(sid);

  // initialize DAQ
  CALTCB_DRSinit(sid, mid);

  // write setting
  CALTCBwrite_CW(sid, 0, cw);
  CALTCBwrite_RUN_NUMBER(sid, run_number);
  CALTCBwrite_PEDESTAL_TRIGGER_INTERVAL(sid, pedestal_trigger_interval);
  CALTCBwrite_TRIGGER_ENABLE(sid, trigger_enable);
  CALTCBwrite_MULTIPLICITY_THR(sid, 0, multiplicity_thr);
  CALTCBwrite_TRIGGER_DELAY(sid, trigger_delay);
  for (ch = 1; ch <= 4; ch++)
    CALTCBwrite_HV(sid, mid, ch, hv);
  for (ch = 1; ch <= 32; ch++)
    CALTCBwrite_THR(sid, mid, ch, thr);

  // readback setting
  printf("Coincidence width = %ld\n", CALTCBread_CW(sid, 0));
  printf("Run number = %ld\n", CALTCBread_RUN_NUMBER(sid));
  printf("Pedestal trigger interval = %ld\n", CALTCBread_PEDESTAL_TRIGGER_INTERVAL(sid));
  printf("Trigger enable = %ld\n", CALTCBread_TRIGGER_ENABLE(sid));
  printf("Multiplicity threshold = %ld\n", CALTCBread_MULTIPLICITY_THR(sid, 0));
  printf("Trigger delay = %ld\n", CALTCBread_TRIGGER_DELAY(sid));
  printf("Temperature = %f\n", CALTCBread_TEMP(sid, mid));
  for (ch = 1; ch <= 4; ch++)
    printf("HV[%ld] = %f\n", ch, CALTCBread_HV(sid, mid, ch));
  for (ch = 1; ch <= 32; ch++)
    printf("Threshold[%ld] = %ld\n", ch, CALTCBread_THR(sid, mid, ch));
  
  // close TCB
  CALTCBclose(sid);

  // exit LIBUSB
  USB3Exit();

  return 0;
}




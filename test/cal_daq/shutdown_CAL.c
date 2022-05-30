#include <unistd.h>
#include <stdio.h>
#include "NoticeCALTCB.h"

int main(void)
{
  int univ = 1;   // 0 = knu, 1 = ysu
  float hv = 0.0;
  int sid = 0;
  int mid[40];
  int num_of_daq = 0;
  unsigned long link_data[2];
  int linked[40];
  unsigned long mid_data[40];
  unsigned long ch;
  int daq;

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
  
  // read connected DAQ machines
  for (ch = 0; ch < 40; ch++) {
    if (linked[ch]) {
      mid[num_of_daq] = mid_data[ch];
      printf("mid %d is found at ch%ld\n", mid[num_of_daq], ch + 1);
      // first come, first served
      // ch = 40;
      num_of_daq = num_of_daq + 1;
    }
  }

  // reset DAQ
  //CALTCBresetTIMER(sid);   // optional timer reset
  CALTCBreset(sid);

  // initialize DAQ
  for (int i=0;i<num_of_daq;i++) CALTCB_DRSinit(sid, mid[i]);

  // write setting
  for (daq = 0; daq < num_of_daq; daq++) {
    for (ch = 1; ch <= 4; ch++)
      CALTCBwrite_HV(sid, mid[daq], ch, univ, hv);
  }

  // readback setting
  for (ch = 1; ch <= 4; ch++)
    printf("HV[%ld] = %f\n", ch, CALTCBread_HV(sid, mid[0], ch, univ));
  
  // close TCB
  CALTCBclose(sid);

  // exit LIBUSB
  USB3Exit();

  return 0;
}




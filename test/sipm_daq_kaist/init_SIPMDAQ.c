#include <unistd.h>
#include <stdio.h>
#include "NoticeSIPMTCB.h"

int main(void)
{
  // local variables
  unsigned long link_data[2];
  int linked[40];
  unsigned long mid_data[40];
  unsigned long mid[40];
  int num_of_daq;
  int daq;

  // init LIBUSB
  USB3Init();
    
  // open TCB
  SIPMTCBopen(0);

  // reset
  SIPMTCBreset(0);
  
  // check linked DAQ modules
  SIPMTCBread_LINK(0, link_data);
  for (daq = 0; daq < 32; daq++)
    linked[daq] = (link_data[0] >> daq) & 0x1;
  for (daq = 32; daq < 40; daq++)
    linked[daq] = (link_data[1] >> (daq - 32)) & 0x1;
  
  // read mid of linked DAQ modules
  SIPMTCBread_MID(0, mid_data);
  
  // assgin DAQ index
  num_of_daq = 0;
  
  for (daq = 0; daq < 40; daq++) {
    if (linked[daq]) {
      mid[num_of_daq] = mid_data[daq];
      printf("mid %ld is found at ch%d\n", mid[num_of_daq], daq + 1);
      num_of_daq = num_of_daq + 1;
    }
  }
  
  // initalize DAQ
  for (daq = 0; daq < num_of_daq; daq++) {
    SIPMTCBalign_ADC(0, mid[daq]);
    SIPMTCBalign_DRAM(0, mid[daq]);
  }

  // reset
  SIPMTCBreset(0);
  
  // close TCB
  SIPMTCBclose(0);

  // exit LIBUSB
  USB3Exit();

  return 0;
}




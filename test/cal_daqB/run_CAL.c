#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include "NoticeCALTCB.h"
#include "NoticeCALDAQ.h"

#define BUF_SIZE (65536)           // in kbyte

// 1st argument : 0 = charge data, 1 = charge data + FADC data
int main(int argc, char *argv[])
{
  int sid = 0;
  char *data;
  unsigned long data_size;
  FILE *fp;
  unsigned long link_data[2];
  int linked[40];
  unsigned long mid_data[40];
  int num_of_daq;
  int daq;
  unsigned long mid[40];
  int nevt = 100;
  int run;
  int evt = 0;

  // assign data array
  data = (char *)malloc(BUF_SIZE * 1024); 

  // open data file
  fp = fopen("cal.dat", "wb");

  // init LIBUSB
  USB3Init();
    
  // open TCB
  CALTCBopen(sid);

  // reset
  CALTCBreset(sid);

  // check linked DAQ modules
  CALTCBread_LINK(sid, link_data);
  for (daq = 0; daq < 32; daq++)
    linked[daq] = (link_data[0] >> daq) & 0x1;
  for (daq = 32; daq < 40; daq++)
    linked[daq] = (link_data[1] >> (daq - 32)) & 0x1;
  
  // read mid of linked DAQ modules
  CALTCBread_MID(sid, mid_data);
  
  // assgin DAQ index
  num_of_daq = 0;
  
  for (daq = 0; daq < 40; daq++) {
    if (linked[daq]) {
      mid[num_of_daq] = mid_data[daq];
      num_of_daq = num_of_daq + 1;
    }
  }

  // open DAQ
  for (daq = 0; daq < num_of_daq; daq++) 
    CALDAQopen(mid[daq]);
    
  // start DAQ
  CALTCBstart_DAQ(sid);

  run = 1;  
  while (run) {
    for (daq = 0; daq < num_of_daq; daq++) {
      // check data size
      data_size = CALDAQread_DATASIZE(mid[daq]);
      if (data_size > BUF_SIZE)
        data_size = BUF_SIZE;

      // read raw data
      if (data_size) {
        CALDAQread_DATA(mid[daq], data_size, data);
        fwrite(data, 1, data_size * 1024, fp);
        if (daq == 0) {
          evt = evt + (data_size / 64);
          printf("%d events raw data are taken\n", evt);
        }
      }
    }
    
    if (evt >= nevt)
      run = 0;  
  }
  
  // finish data acquisition  
  fclose(fp);

  // stop DAQ
  CALTCBstop_DAQ(sid);
  
  // close DAQ
  for (daq = 0; daq < num_of_daq; daq++) 
    CALDAQclose(mid[daq]);

  // close TCB
  CALTCBclose(sid);
  
  // exit LIBUSB
  USB3Exit();

  // release memory
  free(data);

  return 0;
}


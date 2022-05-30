#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include "NoticeSIPMTCB.h"
#include "NoticeSIPMDAQ.h"

#define TCB_BUF_SIZE (131072)           // in byte
#define RAW_BUF_SIZE (131072)           // in byte
#define FADC_BUF_SIZE (65536)           // in kbyte

// 1st argument : 0 = charge data, 1 = charge data + FADC data
int main(int argc, char *argv[])
{
  int daq_mode;
  char *data_tcb;
  char *data_raw;
  char *data_fadc;
  FILE *fp_tcb;
  FILE *fp_raw;
  FILE *fp_fadc;
  FILE *fp_size;
  int daq;
  unsigned long link_data[2];
  int linked[40];
  unsigned long mid_data[40];
  int num_of_daq;
  unsigned long mid[40];
  int read_frame;
  int read_raw;
  int read_fadc;
  int run;
  unsigned long data_size_tcb;
  unsigned long data_size_raw;
  unsigned long data_size_fadc;
  int data_flag_fadc;
  time_t t = time(NULL);
  struct tm tm = *localtime(&t);
  int year;
  int month;
  int day;
  int hour;
  int min;
  int sec;
  char date[15];
  char filename[256];
  char cmd[256];

  fp_size = fopen("/dev/shm/sipm_size.txt", "wt");
  fprintf(fp_size, "0\n");
  fclose(fp_size);

  // set DAQ mode
  daq_mode = 0;
  if (argc > 1) 
    daq_mode = atoi(argv[1]);

  // assign data array
  data_tcb = (char *)malloc(TCB_BUF_SIZE); 
  if (daq_mode)
    data_raw = (char *)malloc(RAW_BUF_SIZE);
  if (daq_mode > 1)
    data_fadc = (char *)malloc(FADC_BUF_SIZE * 1024);

  // open data file
  fp_tcb = fopen("sipm_tcb.dat", "wb");
  if (daq_mode)
    fp_raw = fopen("sipm_raw.dat", "wb");
  if (daq_mode > 1)
    fp_fadc = fopen("sipm_fadc.dat", "wb");

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
      num_of_daq = num_of_daq + 1;
    }
  }

  // open DAQ
  for (daq = 0; daq < num_of_daq; daq++) 
    SIPMDAQopen(mid[daq]);
    
  // start DAQ
  SIPMTCBstart_DAQ(0);

  read_frame = 0;
  read_raw = 0;
  read_fadc = 0;
    
  run = 1;  
  while (run) {
    // read image data
    data_size_tcb = SIPMTCBread_DATASIZE(0);
    if (data_size_tcb) {
      SIPMTCBread_DATA(0, data_size_tcb, data_tcb);
      fwrite(data_tcb, 1, data_size_tcb * 1024, fp_tcb);
      read_frame = read_frame + (data_size_tcb / 4);
      printf("%d frames are taken\n", read_frame);
      fp_size = fopen("/dev/shm/sipm_size.txt", "wt");
      fprintf(fp_size, "%d\n", read_frame);
      fclose(fp_size);
    }
  
    // read raw data
    if (daq_mode) {
      for (daq = 0; daq < num_of_daq; daq++) {
        // check raw data size
        data_size_raw = SIPMDAQread_DATASIZE(mid[daq]);

        // read raw data
        if (data_size_raw) {
          SIPMDAQread_DATA(mid[daq], data_size_raw, data_raw);
          fwrite(data_raw, 1, data_size_raw * 16, fp_raw);
          read_raw = read_raw + data_size_raw;
          printf("%d events raw data are taken\n", read_raw);
        }
      }
    }

    // stop DAQ    
    if ((access("/dev/shm/sipm_daq_stop.txt", 0)) == 0) {
      SIPMTCBstop_DAQ(0);
      system("rm /dev/shm/sipm_daq_stop.txt");
      run = 0;
    }
  }
  
  // read still unread image data
  data_size_tcb = SIPMTCBread_DATASIZE(0);
  if (data_size_tcb) {
    SIPMTCBread_DATA(0, data_size_tcb, data_tcb);
    fwrite(data_tcb, 1, data_size_tcb * 1024, fp_tcb);
    read_frame = read_frame + (data_size_tcb / 4);
    printf("%d frames are taken\n", read_frame);
    fp_size = fopen("/dev/shm/sipm_size.txt", "wt");
    fprintf(fp_size, "%d\n", read_frame);
    fclose(fp_size);
  }

  // finish image acquisition  
  fclose(fp_tcb);
  system("touch /dev/shm/sipm_daq_done.txt");

  // read still unread raw data
  if (daq_mode) {
    for (daq = 0; daq < num_of_daq; daq++) {
      // check raw data size
      data_size_raw = SIPMDAQread_DATASIZE(mid[daq]);

      // read raw data
      if (data_size_raw) {
        SIPMDAQread_DATA(mid[daq], data_size_raw, data_raw);
        fwrite(data_raw, 1, data_size_raw * 16, fp_raw);
        read_raw = read_raw + data_size_raw;
        printf("%d events raw data are taken\n", read_raw);
      }
    }
  }

//  printf("%d events raw data are taken\n", read_raw);

  // read fadc data if necessary
  if (daq_mode > 1) {
    data_flag_fadc = num_of_daq;
    while (data_flag_fadc) {
      for (daq = 0; daq < num_of_daq; daq++) {
        // check fadc data size
        data_size_fadc = SIPMDAQread_FADC_DATASIZE(mid[daq]);
        if (data_size_fadc > (2 * read_raw)) {
          data_size_fadc = 0;
          SIPMTCBreset(0);
          SIPMTCBreset(0);
          SIPMTCBreset(0);
          SIPMTCBreset(0);
          SIPMTCBreset(0);
          printf("Abnormal FADC data size!!\n");
        }
        else if (data_size_fadc > FADC_BUF_SIZE)
          data_size_fadc = FADC_BUF_SIZE;

        // read fadc data
        if (data_size_fadc) {
          SIPMDAQread_FADC_DATA(mid[daq], data_size_fadc, data_fadc);
          fwrite(data_fadc, 1, data_size_fadc * 1024, fp_fadc);
          read_fadc = read_fadc + data_size_fadc;
          printf("%d events fadc data are taken\n", read_fadc);
        }
        else
          data_flag_fadc = data_flag_fadc - 1;
      }
    }

//    printf("%d events fadc data are taken\n", read_fadc);
  }

  // reset
  SIPMTCBreset(0);
  
  // close DAQ
  for (daq = 0; daq < num_of_daq; daq++) 
    SIPMDAQclose(mid[daq]);

  // close TCB
  SIPMTCBclose(0);
  
  // exit LIBUSB
  USB3Exit();

  // release memory
  free(data_tcb);
  if (daq_mode)
    free(data_raw);
  if (daq_mode > 1)
    free(data_fadc);

  //close data file
  if (daq_mode)
    fclose(fp_raw);
  if (daq_mode > 1)
    fclose(fp_fadc);

  // copy data files
  year = tm.tm_year + 1900;
  month = tm.tm_mon + 1;
  day = tm.tm_mday;
  hour = tm.tm_hour;
  min = tm.tm_min;
  sec = tm.tm_sec;
  sprintf(date, "%d", year);
  if (month < 10)
    sprintf(date + 4, "0%d", month);
  else
    sprintf(date + 4, "%d", month);
  if (day < 10)
    sprintf(date + 6, "0%d_", day);
  else
    sprintf(date + 6, "%d_", day);
  if (hour < 10)
    sprintf(date + 9, "0%d", hour);
  else
    sprintf(date + 9, "%d", hour);
  if (min < 10)
    sprintf(date + 11, "0%d", min);
  else
    sprintf(date + 11, "%d", min);
  if (sec < 10)
    sprintf(date + 13, "0%d", sec);
  else
    sprintf(date + 13, "%d", sec);
    
  sprintf(filename, "data/sipm_tcb_%s.dat", date);
  sprintf(cmd, "cp sipm_tcb.dat %s", filename);
  system(cmd);

  if (daq_mode) {
    sprintf(filename, "data/sipm_raw_%s.dat", date);
    sprintf(cmd, "cp sipm_raw.dat %s", filename);
    system(cmd);
  }

  if (daq_mode > 1) {
    sprintf(filename, "data/sipm_fadc_%s.dat", date);
    sprintf(cmd, "cp sipm_fadc.dat %s", filename);
    system(cmd);
  }
  
  // notify DAQ is ready to server
  system("touch /dev/shm/sipm_daq_ready.txt");

  return 0;
}


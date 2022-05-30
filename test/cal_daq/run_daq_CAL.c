#include <unistd.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include "NoticeCALTCB.h"
#include "NoticeCALDAQ.h"

#define BUF_SIZE (65536)           // in kbyte

int main(int argc, char *argv[])
{
  //int sid = 0;
  int mid;
  //unsigned long link_data[2];
  //int linked[40];
  //unsigned long mid_data[40];
  //unsigned long ch;
  char *data;
  unsigned long data_size;
  FILE *fp;
  int nevt = 100;
  unsigned long run;
  char file_name[100];
  int evt = 0;
  int test_id = 0;
  //int num_of_daq=0;
  //int daq;
  long long file_size; 
  int file_number=0;
  time_t rawtime1;
  time_t rawtime2;
  struct tm * timeinfo;
  double d_diff;
  double time_interval=1800;//time interval to measure
  long long file_size_output=1E12;//output size
  // assign data array
  data = (char *)malloc(BUF_SIZE * 1024); 
  
  // default mid
  mid = 1;

  // set mid ./run_daq_CAL.exe mid
  if (argc>1){
    mid = atoi(argv[1]);
    test_id = atoi(argv[2]);

  }
  // open data file
  sprintf(file_name,"/media/yu/Expansion/DAQ_data/cal_%d_%d_%d.dat",mid,test_id,file_number);
  //sprintf(file_name,"cal_%d_%d_%d.dat",mid,test_id,file_number);

  fp = fopen(file_name, "wb");
  
  // init LIBUSB
  USB3Init();
  
  // open daq
  CALDAQopen(mid);
  // open TCB
  //CALTCBopen(sid);
/*
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
      mid[num_of_daq] = mid_data[ch];
      printf("mid %d is found at ch%ld\n", mid[num_of_daq], ch + 1);
      // first come, first served
      //ch = 40;
      num_of_daq = num_of_daq + 1;
    }
  }

  // open DAQ
  for (int i=0;i<num_of_daq;i++) CALDAQopen(mid[i]);

  // reset DAQ
  CALTCBreset(sid);

  // start DAQ
  CALTCBstart_DAQ(sid);
  printf("Run status = %ld\n", CALDAQread_RUN(mid[0]));
*/
  // waiting until run 
  run = CALDAQread_RUN(mid);
  while (!run){
    run = CALDAQread_RUN(mid);
  }
  time (&rawtime1);
  timeinfo = localtime(&rawtime1);

  // run = 1;  
  while (run) {
//    CALTCBsend_TRIG(sid);  // optional software trigger
      time (&rawtime2);
      timeinfo = localtime(&rawtime2);
      d_diff = difftime(rawtime2,rawtime1);
      //printf("time different is %f\n",d_diff);
      
      //by setting time interval measure file size
      if (d_diff>time_interval){
	fseek(fp, 0, SEEK_END);
	file_size = ftell(fp);
	//printf("hello\n");
	//printf("file size is %d\n",file_size);
	rawtime1=rawtime2;

	// file size is bounded by setting value
	if (file_size>file_size_output){
	  printf("hello I am here please debug me\n");
	  file_number+=1;
          //sprintf(file_name,"cal_%d_%d_%d.dat",mid,test_id,file_number);
	  sprintf(file_name,"/media/yu/Expansion/DAQ_data/cal_%d_%d_%d.dat",mid,test_id,file_number);
	  
	  // close file
	  fclose(fp);

	  // insert system script
	  //system("sleep 10 &");
	  rewind(fp);
	  // new file
          fp = fopen(file_name, "wb");
	}
	

      }
      //if (evt%10==0&&evt>60){
      //  printf("time different is %f\n",d_diff);
	//break;
      //}
      data_size = CALDAQread_DATASIZE(mid);
      if (data_size > BUF_SIZE)
        data_size = BUF_SIZE;

      if (data_size) {
        printf("data size = %ld\n", data_size);
        CALDAQread_DATA(mid, data_size, data);
        fwrite(data, 1, data_size * 1024, fp);
        evt = evt + (data_size / 64);
        //evt = evt + (data_size / 128);
        printf("%d / %d events are taken\n", evt, nevt);
        //if (evt >= nevt) {
          //CALTCBstop_DAQ(sid);
          // run = 0;
        //}  
      }
      else{
       run = CALDAQread_RUN(mid);//check run
      }
    }
  

  //printf("Run status = %ld\n", CALDAQread_RUN(mid[0]));

  // close file  
  fclose(fp);  
  
  // release memory
  free(data);

  // close DAQ
  CALDAQclose(mid);

  // reset DAQ
//  CALTCBreset(sid);

  // close TCB
  //CALTCBclose(sid);
  
  // exit LIBUSB
  USB3Exit();

  return 0;
}


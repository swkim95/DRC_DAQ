#include <sys/time.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include "debug_ibs_sipm_daq.h"

int main(void)
{
  int tcp_Handle;                // TCP/IP handler
  int com;
  int data;
  float hv;

  // open MINITCB_V2
  tcp_Handle = IBS_SIPM_DAQopen();

  com = 99;

  while(com) {
    printf("\n");
    printf("1. write   2. read    3. HV    4. Temp   0. quit\n");
    printf("enter command : ");
    scanf("%d", &com);

    if (com == 1) {
      printf("enter value : ");
      scanf("%d", &data);
      IBS_SIPM_DAQwrite_DBG(tcp_Handle, data);
      IBS_SIPM_DAQreset(tcp_Handle);
    }
    else if (com == 2) 
      printf("value = %d\n", IBS_SIPM_DAQread_DBG(tcp_Handle));

    else if (com == 3) {
      printf("enter value : ");
      scanf("%f", &hv);
      IBS_SIPM_DAQwrite_HV(tcp_Handle, hv);
      printf("High voltage = %f\n", IBS_SIPM_DAQread_HV(tcp_Handle));
    }
    else if (com == 4) 
      printf("Temperature = %f\n", IBS_SIPM_DAQread_TEMP(tcp_Handle));
  }

  // close MINITCB_V2
  IBS_SIPM_DAQclose(tcp_Handle);

  return 0;
}
  
 








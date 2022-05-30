#include <sys/time.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include "programmer_ibs_sipm_daq.h"

int main(void)
{
  int tcp_Handle;                // TCP/IP handler
  int com;
  char data[256];
  int i;
  char filename[256];
  int length;
  FILE *fp;
  char cdat[0x60000];
  int sector;
  int page;
  int errcnt;

  // open MINITCB_V2
  tcp_Handle = IBS_SIPM_DAQopen();

  // read present firmware version
  IBS_SIPM_DAQverify(tcp_Handle, 5, 255, data);
  printf("FPGA firmware = %s\n", data);

  com = 99;

  while(com) {
    printf("\n");
    printf("1. upload FPGA firmware\n");
    printf("2. verify FPGA firmware\n");
    printf("0. quit\n");
    printf("enter command : ");
    scanf("%d", &com);

    if (com == 1) {
      printf("enter bit filename : ");
      scanf("%s", filename);

      fp = fopen(filename, "rb");
      if (fp == NULL)
	      printf("File not found! Quit without uploading. Bye!\n");
      else {
	      fread(cdat, 1, 0x532E0, fp);
  	    fclose(fp);

        for (i = 0x532E0; i < 0x60000; i++)
          cdat[i] = 0x0;

        length = strlen(filename);

	      for (i = 0; i < length; i++)
	        cdat[0x5FF00 + i] = filename[i];

	      // enable flash
        IBS_SIPM_DAQunprotect(tcp_Handle);
	
	      // write FPGA firmware
        for (sector = 0; sector < 6; sector++) {
	        // erase sector
          IBS_SIPM_DAQerase(tcp_Handle, sector);
	  
          // write data
	        for (page = 0; page < 256; page++) {
	          for (i = 0; i < 256; i++)
	            data[i] = cdat[sector * 0x10000 + page * 0x100 + i] & 0xFF;

            // write flash memory
            IBS_SIPM_DAQprogram(tcp_Handle, sector, page, data);
	          printf(".");
	          fflush(stdout);
	        }
	      }

	      printf("\n");

	      // finish flash
        IBS_SIPM_DAQprotect(tcp_Handle);
      }
    }
    else if (com == 2) {
      printf("enter bit filename : ");
      scanf("%s", filename);

      fp = fopen(filename, "rb");
      if (fp == NULL)
	      printf("File not found! Quit without uploading. Bye!\n");
      else {
        errcnt = 0;
  
	      fread(cdat, 1, 0x532E0, fp);
	      fclose(fp);

        for (i = 0x532E0; i < 0x60000; i++)
          cdat[i] = 0x0;

        length = strlen(filename);

	      for (i = 0; i < length; i++)
	        cdat[0x5FF00 + i] = filename[i];

	      // verify FPGA firmware
	      for (sector = 0; sector < 6; sector++) {
	  
     	    // read data
	        for (page = 0; page < 256; page++) {
            IBS_SIPM_DAQverify(tcp_Handle, sector, page, data);

            // compare data
	          for (i = 0; i < 256; i++) {
              if ((data[i] & 0xFF) != (cdat[sector * 0x10000 + page * 0x100 + i] & 0xFF)) {
                errcnt = errcnt + 1;
                printf("%X : %X : %X, write = %X, read = %X, errcnt = %d\n", sector, page, i, cdat[sector * 0x10000 + page * 0x100 + i] & 0xFF, data[i] & 0xFF, errcnt);
              }
            }
	        }
	      }
       
        if (errcnt == 0)
          printf("verification is okay!\n");
      }
    }
  }

  // close MINITCB_V2
  IBS_SIPM_DAQclose(tcp_Handle);

  return 0;
}
  
 








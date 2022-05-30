#include <sys/time.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include "NoticeIBS_SIPM_DAQ.h"

int IBS_SIPM_DAQtransmit(int tcp_Handle, char *buf, int len);
int IBS_SIPM_DAQreceive(int tcp_Handle, char *buf, int len);
void IBS_SIPM_DAQwriteS(int tcp_Handle, int address, int data);
void IBS_SIPM_DAQwriteL(int tcp_Handle, int address, int data);
int IBS_SIPM_DAQreadS(int tcp_Handle, int address);
int IBS_SIPM_DAQreadL(int tcp_Handle, int address);
void IBS_SIPM_DAQreadN(int tcp_Handle, int address, int nbyte, short *data);
int IBS_SIPM_DAQstatus(int tcp_Handle);
void IBS_SIPM_DAQarm_MON(int tcp_Handle);
int IBS_SIPM_DAQread_MON_STATUS(int tcp_Handle);
int IBS_SIPM_DAQread_DATA_SIZE(int tcp_Handle);
void IBS_SIPM_DAQread_DATA_FIFO(int tcp_Handle, int nevt, short *data);
void IBS_SIPM_DAQread_MON_FIFO(int tcp_Handle, short *data);
void IBS_SIPM_DAQsend_TRIG(int tcp_Handle);

// open IBS_SIPM_DAQ
int IBS_SIPM_DAQopen(void)
{
  struct sockaddr_in serv_addr;
  int tcp_Handle;
  const int disable = 1;
        
  serv_addr.sin_family      = AF_INET;
  serv_addr.sin_addr.s_addr = inet_addr("192.168.0.3");
  serv_addr.sin_port        = htons(5000);
        
  if ( (tcp_Handle = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    printf("Can't open IBS_SIPM_DAQ\n");
    return -1;
  }

  setsockopt(tcp_Handle, IPPROTO_TCP,TCP_NODELAY,(char *) &disable, sizeof(disable)); 

  if (connect(tcp_Handle, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
    printf("client: can't connect to server\n");
    printf("ip 192.168.0.3 , port 5000 \n");
    printf("error number is %d \n", connect(tcp_Handle, (struct sockaddr *) &serv_addr,sizeof(serv_addr)));

    return -2;
  } 
  
  return tcp_Handle;
}

// close IBS_SIPM_DAQ
void IBS_SIPM_DAQclose(int tcp_Handle)
{
  close(tcp_Handle);
}

// transmit characters to IBS_SIPM_DAQ
int IBS_SIPM_DAQtransmit(int tcp_Handle, char *buf, int len)
{
  int result;
  int bytes_more;
  int  bytes_xferd;
  char *idxPtr;

  bytes_more = len;
  idxPtr = buf;
  bytes_xferd = 0;
  while (1) {
    idxPtr = buf + bytes_xferd;
    result=write (tcp_Handle, (char *) idxPtr, bytes_more);

    if (result<0) {
      printf("Could not write the rest of the block successfully, returned: %d\n",bytes_more);
      return -1;
    }
    
    bytes_xferd += result;
    bytes_more -= result;
    
    if (bytes_more <= 0)
      break;
  }

  return 0;
}

// receive characters from IBS_SIPM_DAQ
int IBS_SIPM_DAQreceive(int tcp_Handle, char *buf, int len)
{
  int result;
  int accum;
  int space_left;
  int bytes_more;
  int buf_count;
  char *idxPtr;

  fd_set rfds;
  struct timeval tval;

  tval.tv_sec = MAX_TCP_READ;
  tval.tv_usec = 0;

  FD_ZERO(&rfds);
  FD_SET(tcp_Handle, &rfds);

  if (buf==NULL)
    return -1;

  idxPtr = buf;

  buf_count = 0;
  space_left = len;
  while (1) {
    accum = 0;
    while (1) {
      idxPtr = buf + (buf_count + accum);
      bytes_more = space_left;
      
      if ((result = read(tcp_Handle, (char *) idxPtr, (bytes_more>2048)?2048:bytes_more)) < 0) {
        printf("Unable to receive data from the server.\n");
        return -1;
      }
      
      accum += result;
      if ((accum + buf_count) >= len)
	break;

      if(result<bytes_more) {
        printf("wanted %d got %d \n",bytes_more,result);
        return accum+buf_count;
      }
    }
    
    buf_count += accum;
    space_left -= accum;

    if (space_left <= 0)
      break;
  }

  return buf_count;
}

// write 1byte to IBS_SIPM_DAQ
void IBS_SIPM_DAQwriteS(int tcp_Handle, int address, int data)
{
  char tcpBuf[3];

  tcpBuf[0] = 1;
  tcpBuf[1] = address & 0xFF;
  tcpBuf[2] = data & 0xFF;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 3);
  
  IBS_SIPM_DAQreceive(tcp_Handle, tcpBuf, 1);
}

// write 2bytes to IBS_SIPM_DAQ
void IBS_SIPM_DAQwriteL(int tcp_Handle, int address, int data)
{
  char tcpBuf[4];

  tcpBuf[0] = 2;
  tcpBuf[1] = address & 0xFF;
  tcpBuf[2] = data & 0xFF;
  tcpBuf[3] = (data >> 8) & 0xFF;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 4);
  
  IBS_SIPM_DAQreceive(tcp_Handle, tcpBuf, 1);
}

// read 1byte from IBS_SIPM_DAQ
int IBS_SIPM_DAQreadS(int tcp_Handle, int address)
{
  char tcpBuf[2];
  int data;

  tcpBuf[0] = 3;
  tcpBuf[1] = address & 0xFF;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 2);
  
  IBS_SIPM_DAQreceive(tcp_Handle, tcpBuf, 1);

  data = tcpBuf[0] & 0xFF;

  return data;
}

// read 2bytes from IBS_SIPM_DAQ
int IBS_SIPM_DAQreadL(int tcp_Handle, int address)
{
  char tcpBuf[2];
  int data;

  tcpBuf[0] = 4;
  tcpBuf[1] = address & 0xFF;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 2);
  
  IBS_SIPM_DAQreceive(tcp_Handle, tcpBuf, 2);

  data = tcpBuf[1] & 0xFF;
  data = data << 8;
  data = data + (tcpBuf[0] & 0xFF);

  return data;
}

// read nbytes from IBS_SIPM_DAQ
void IBS_SIPM_DAQreadN(int tcp_Handle, int address, int nbyte, short *data)
{
  char tcpBuf[1024];
  int nword;
  int i;

  tcpBuf[0] = 5;
  tcpBuf[1] = address & 0xFF;
  tcpBuf[2] = nbyte & 0xFF;
  tcpBuf[3] = (nbyte >> 8) & 0xFF;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 4);
  
  IBS_SIPM_DAQreceive(tcp_Handle, tcpBuf, nbyte);
  
  nword = nbyte / 2;

  for (i = 0; i < nword; i++) {  
    data[i] = tcpBuf[2 * i + 1] & 0xFF;
    data[i] = data[i] << 8;
    data[i] = data[i] + (tcpBuf[2 * i] & 0xFF);
  }
}

// unprotect flash memory
void IBS_SIPM_DAQunprotect(int tcp_Handle)
{
  char tcpBuf[2];

  tcpBuf[0] = 6;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 1);
  
  IBS_SIPM_DAQreceive(tcp_Handle, tcpBuf, 1);
}

// protect flash memory
void IBS_SIPM_DAQprotect(int tcp_Handle)
{
  char tcpBuf[2];

  tcpBuf[0] = 7;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 1);
  
  IBS_SIPM_DAQreceive(tcp_Handle, tcpBuf, 1);
}

// erase flash memory
void IBS_SIPM_DAQerase(int tcp_Handle, int sector)
{
  char tcpBuf[2];
  int stat;

  tcpBuf[0] = 8;
  tcpBuf[1] = sector & 0xFF;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 2);
  
  IBS_SIPM_DAQreceive(tcp_Handle, tcpBuf, 1);
  
  stat = 1;
  while (stat)
    stat = IBS_SIPM_DAQstatus(tcp_Handle);
}

// read status flash memory
int IBS_SIPM_DAQstatus(int tcp_Handle)
{
  char tcpBuf[2];
  int stat;

  tcpBuf[0] = 9;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 1);
  
  IBS_SIPM_DAQreceive(tcp_Handle, tcpBuf, 1);
  stat = tcpBuf[0] & 0xFF;
  
  return stat;
}

// program flash memory
void IBS_SIPM_DAQprogram(int tcp_Handle, int sector, int page, char *data)
{
  char tcpBuf[259];
  int i;

  tcpBuf[0] = 10;
  tcpBuf[1] = sector & 0xFF;
  tcpBuf[2] = page & 0xFF;
  for (i = 0; i < 256; i++)
    tcpBuf[i + 3] = data[i] & 0xFF;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 259);
  
  IBS_SIPM_DAQreceive(tcp_Handle, tcpBuf, 1);
}

// verify flash memory
void IBS_SIPM_DAQverify(int tcp_Handle, int sector, int page, char *data)
{
  char tcpBuf[256];

  tcpBuf[0] = 11;
  tcpBuf[1] = sector & 0xFF;
  tcpBuf[2] = page & 0xFF;

  IBS_SIPM_DAQtransmit(tcp_Handle, tcpBuf, 3);
  
  IBS_SIPM_DAQreceive(tcp_Handle, data, 256);
}

// reset DAQ
void IBS_SIPM_DAQreset(int tcp_Handle)
{
  IBS_SIPM_DAQwriteS(tcp_Handle, 0x0, 0);
}

// start DAQ
void IBS_SIPM_DAQstart(int tcp_Handle)
{
  IBS_SIPM_DAQwriteS(tcp_Handle, 0x0, 1);
}

// read RUN status
int IBS_SIPM_DAQread_RUN(int tcp_Handle)
{
  return IBS_SIPM_DAQreadS(tcp_Handle, 0x0);
}

// arm monitor
void IBS_SIPM_DAQarm_MON(int tcp_Handle)
{
  IBS_SIPM_DAQwriteS(tcp_Handle, 0x1, 0);
}

// read monitor status
int IBS_SIPM_DAQread_MON_STATUS(int tcp_Handle)
{
  return IBS_SIPM_DAQreadS(tcp_Handle, 0x1);
}

// read data size
int IBS_SIPM_DAQread_DATA_SIZE(int tcp_Handle)
{
  IBS_SIPM_DAQwriteS(tcp_Handle, 0x2, 0);
  return IBS_SIPM_DAQreadL(tcp_Handle, 0x2);
}

// read data FIFO
void IBS_SIPM_DAQread_DATA_FIFO(int tcp_Handle, int nevt, short *data)
{
  IBS_SIPM_DAQreadN(tcp_Handle, 0x4, nevt * 2, data);
}

// read data
int IBS_SIPM_DAQread_DATA(int tcp_Handle, unsigned short *data)
{
  int nevt;
  short fifo_data[512];
  int i;
  
  nevt = IBS_SIPM_DAQread_DATA_SIZE(tcp_Handle);

  if (nevt) {
    if (nevt > 512)
      nevt = 512;
  
    IBS_SIPM_DAQread_DATA_FIFO(tcp_Handle, nevt, fifo_data);
    for (i = 0; i < nevt; i++)
      data[i] = fifo_data[i] & 0xFFFF;
  }

  return nevt;
}

// read monitor data FIFO
void IBS_SIPM_DAQread_MON_FIFO(int tcp_Handle, short *data)
{
  IBS_SIPM_DAQreadN(tcp_Handle, 0x5, 512, data);
}

// read monitor data
void IBS_SIPM_DAQread_MON(int tcp_Handle, int trig_mode, short *data)
{
  int stat;
  
  // arm MON
  IBS_SIPM_DAQarm_MON(tcp_Handle);

  // wait for trigger
  stat = 0;
  while (!stat) {
    if (trig_mode)
      IBS_SIPM_DAQsend_TRIG(tcp_Handle);
    stat = IBS_SIPM_DAQread_MON_STATUS(tcp_Handle);
  }

  IBS_SIPM_DAQread_MON_FIFO(tcp_Handle, data);
}

// send software trigger
void IBS_SIPM_DAQsend_TRIG(int tcp_Handle)
{
  IBS_SIPM_DAQwriteS(tcp_Handle, 0x6, 0);
}

// write bias voltage
void IBS_SIPM_DAQwrite_HV(int tcp_Handle, float data)
{
  float fval;
  int value;

  fval = 4.59 * (data - 4.5);
  value = (int)(fval);
  if (value > 254)
    value = 254;
  else if (value < 0)
    value = 0;
printf("value = %X\n", value);    

  IBS_SIPM_DAQwriteS(tcp_Handle, 0x7, value);
}

// read bias voltage
float IBS_SIPM_DAQread_HV(int tcp_Handle)
{
  int data;
  float value;

  data = IBS_SIPM_DAQreadS(tcp_Handle, 0x7);
  value = data;
  value = value / 4.59 + 4.5;

  return value;
}

// write discriminator threshold
void IBS_SIPM_DAQwrite_THR(int tcp_Handle, int data)
{
  IBS_SIPM_DAQwriteL(tcp_Handle, 0x8, data);
}

// read discriminator threshold
int IBS_SIPM_DAQread_THR(int tcp_Handle)
{
  return IBS_SIPM_DAQreadL(tcp_Handle, 0x8);
}

// read temperature
float IBS_SIPM_DAQread_TEMP(int tcp_Handle)
{
  int data;
  int ival;
  int sign;
  float value;

  IBS_SIPM_DAQwriteS(tcp_Handle, 0xA, 0);
  data = IBS_SIPM_DAQreadL(tcp_Handle, 0xA);
  
  ival = data & 0x7FF;
  sign = data & 0x800;

  if (sign)
    ival = -ival;

  value = ival;
  value = value / 16.0;

  return value;
}

int IBS_SIPM_DAQread_PED(int tcp_Handle)
{
  IBS_SIPM_DAQwriteS(tcp_Handle, 0xC, 0);
  return IBS_SIPM_DAQreadL(tcp_Handle, 0xC);
}

// write readback register for debug
void IBS_SIPM_DAQwrite_DBG(int tcp_Handle, int data)
{
  IBS_SIPM_DAQwriteS(tcp_Handle, 0xF, data);
}

// read readback register for debug
int IBS_SIPM_DAQread_DBG(int tcp_Handle)
{
  return IBS_SIPM_DAQreadS(tcp_Handle, 0xF);
}


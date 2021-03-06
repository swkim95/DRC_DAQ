#include <sys/time.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include "test_client.h"

// open TCP/IP socket
int CLIENT_Open(char *host)
{
  struct sockaddr_in	serv_addr;
  int tcp_Handle;
  const int disable = 1;
  /*
   * Fill in the structure "serv_addr" with the address of the
   * server that we want to connect with.
   */
        
  //bzero((char *) &serv_addr, sizeof(serv_addr));
  serv_addr.sin_family      = AF_INET;
  serv_addr.sin_addr.s_addr = inet_addr(host);
  serv_addr.sin_port        = htons(5000);
        
  /*
   * Open a TCP socket (an Internet stream socket).
   */
        
  if ( (tcp_Handle = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    printf("client: can't open stream socket\n");
    return -1;
  }
        
  /* turning off TCP NAGLE algorithm : if not, there is a delay 
     problem (up to 200ms) when packet size is small */ 
  setsockopt(tcp_Handle, IPPROTO_TCP,TCP_NODELAY,(char *) &disable, sizeof(disable)); 

  /*
   * Connect to the server.
   */
        
  if (connect(tcp_Handle, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
    printf("client: can't connect to server\n");
    printf("ip %s , port 5000 \n", host);
    printf("error number is %d \n", connect(tcp_Handle, (struct sockaddr *) &serv_addr,sizeof(serv_addr)));

    return -2;
  } 
  
  return (tcp_Handle);
}

// close TCP/IP socket
int CLIENT_Close(int tcp_Handle) 
{
  close(tcp_Handle);

  return 0;
}

// transmit len byte character stream buf
int CLIENT_Transmit(int tcp_Handle, char *buf,int len)
{
  int result, bytes_more, bytes_xferd;
  char *idxPtr;

  //	BOOL eoi_flag	= TRUE;

  bytes_more = len;
  idxPtr = buf;
  bytes_xferd = 0;
  while (1) {
    /* then write the rest of the block */
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

// receiver len byte character stream buf
int CLIENT_Receive(int tcp_Handle, char *buf, int len)
{
  int result, accum, space_left, bytes_more, buf_count;
  //int i;
  char *idxPtr;

  fd_set rfds;
  struct timeval tval;

  tval.tv_sec = MAX_TCP_READ;
  tval.tv_usec = 0;

  FD_ZERO(&rfds);
  FD_SET(tcp_Handle, &rfds);

  if (buf==NULL)
    return -1;

  //memset(buf, 0, len);

  idxPtr = buf;

  buf_count = 0;
  space_left = len;
  while (1) {
    /* block here until data is received of timeout expires */
    /*
    //      result = select((tcp_Handle+1), &rfds, NULL, NULL, &tval);
    if (result < 0) {
    printf("Read timeout\n");
    return -1;
    }

    printf("Passed Timeout  \n");
    */
    
    /* read the block */
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
      /* in case data is smaller than wanted on */
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

// send data to server
void TCP_send_CMD(int tcp_Handle, char cmd, int length, char *data)
{
  char wbuf[256];
  int byte_to_send;
  int i;
  int check_sum;
  
  // byte to send
  byte_to_send = length + 6;

  wbuf[0] = 0x02;
  wbuf[1] = cmd & 0xFF;
  wbuf[2] = length & 0xFF;
  wbuf[3] = (length >> 8) & 0xFF;
  for (i = 0; i < length; i++)
    wbuf[i + 4] = data[i];
    
  // get check sum
  check_sum = wbuf[1] & 0xFF;
  check_sum = check_sum + (wbuf[2] & 0xFF);
  check_sum = check_sum + (wbuf[3] & 0xFF);
  for (i = 0; i < length; i++)
    check_sum = check_sum + (wbuf[i + 4] & 0xFF);
  wbuf[length + 4] = check_sum & 0xFF;
  wbuf[length + 5] = 0x03;

  CLIENT_Transmit(tcp_Handle, wbuf, byte_to_send);
}

// read 
void TCP_read_DATA(int tcp_Handle, int length, char *data)
{
  int byte_to_read;
  
  byte_to_read = length + 6;
  CLIENT_Receive(tcp_Handle, data, byte_to_read);
}


int main(void)
{
  int tcp_Handle;                // TCP/IP handler
  char data[1024];
  int scan_time = 100000;
  int i;

  // open CLIENT
  tcp_Handle = CLIENT_Open("192.168.0.7");

  // read DAQ status
  data[0] = 0;
  TCP_send_CMD(tcp_Handle, 'S', 1, data);
  TCP_read_DATA(tcp_Handle, 1, data);
  printf("DAQ status = %d\n", data[4] & 0xFF);
  
  // set DAQ mode
  data[0] = 1;
  TCP_send_CMD(tcp_Handle, 'M', 1, data);
  TCP_read_DATA(tcp_Handle, 1, data);

  data[0] = 0x11;
  TCP_send_CMD(tcp_Handle, 'M', 1, data);
  TCP_read_DATA(tcp_Handle, 1, data);
  printf("DAQ mode = %d\n", data[4] & 0xFF);
  
  data[0] = 0;
  TCP_send_CMD(tcp_Handle, 'M', 1, data);
  TCP_read_DATA(tcp_Handle, 1, data);

  data[0] = 0x11;
  TCP_send_CMD(tcp_Handle, 'M', 1, data);
  TCP_read_DATA(tcp_Handle, 1, data);
  printf("DAQ mode = %d\n", data[4] & 0xFF);
  
  // set scan time
  scan_time = 100000;
  data[0] = scan_time & 0xFF;
  data[1] = (scan_time >> 8) & 0xFF;
  data[2] = (scan_time >> 16) & 0xFF;
  TCP_send_CMD(tcp_Handle, 'T', 3, data);
  TCP_read_DATA(tcp_Handle, 3, data);
  
  // begin scan
  data[0] = 0x0;
  TCP_send_CMD(tcp_Handle, 'B', 1, data);
  TCP_read_DATA(tcp_Handle, 1, data);
printf("get resp after B = %c\n", data[1]);  
usleep(1000000);

  // read 10 lines
  for (i = 0; i < 10; i++) {
    data[0] = 0x0A;
    TCP_send_CMD(tcp_Handle, 'D', 1, data);
printf("send D\n");    
    TCP_read_DATA(tcp_Handle, 940, data);
    printf("line %d = %d\n", i, data[4] & 0xFF);
  }
  
  // end scan
  data[0] = 0x0;
  TCP_send_CMD(tcp_Handle, 'E', 1, data);
  TCP_read_DATA(tcp_Handle, 1, data);
printf("get resp after E = %c\n", data[1]);  

  data[0] = 0;
  TCP_send_CMD(tcp_Handle, 'Q', 1, data);
	
	// close client
  CLIENT_Close(tcp_Handle);

  return 0;
}
  
 








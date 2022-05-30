#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include<string.h>   
#include<sys/socket.h>
#include<arpa/inet.h>

// subroutine
void send_data_to_client(int client_fd, int data_size, char *filename); 
void send_raw_data_to_client(int client_fd, int nevt);

// send server data to client
void send_data_to_client(int client_fd, int data_size, char *filename)
{
  char wbuf[1024];
  int packet_to_send;
  int byte_to_send;
  FILE *fp;
  int i;

  if (data_size) {
    // send data size
    wbuf[0] = data_size & 0xFF;
    wbuf[1] = (data_size >> 8) & 0xFF;
    wbuf[2] = (data_size >> 16) & 0xFF;
    wbuf[3] = (data_size >> 24) & 0xFF;
    send(client_fd, wbuf, 4, 0);

    // if data size is more than 1024 bytes split into many packets
    packet_to_send = data_size / 1024;
    byte_to_send = data_size % 1024;

    // open data file
    fp = fopen(filename, "rb");

    for (i = 0; i < packet_to_send; i++) {
      fread(wbuf, 1, 1024, fp);
      send(client_fd, wbuf, 1024, 0);
    }

   if (byte_to_send) {
      fread(wbuf, 1, byte_to_send, fp);
      send(client_fd, wbuf, byte_to_send, 0);
    }

    // close file
    fclose(fp);
  }
  else {
    wbuf[0] = 0;
    wbuf[1] = 0;
    wbuf[2] = 0;
    wbuf[3] = 0;
    send(client_fd, wbuf, 4, 0);
  }
}

// send raw data to client
void send_raw_data_to_client(int client_fd, int nevt)
{
  char wbuf[1024];
  int data_size;
  int packet_to_send;
  int byte_to_send;
  FILE *fp;
  int i;

  if (nevt) {
    // 1 event = 64 byte
    data_size = nevt * 64;

    // send data size
    wbuf[0] = data_size & 0xFF;
    wbuf[1] = (data_size >> 8) & 0xFF;
    wbuf[2] = (data_size >> 16) & 0xFF;
    wbuf[3] = (data_size >> 24) & 0xFF;
    send(client_fd, wbuf, 4, 0);

    // if data size is more than 1024 bytes split into many packets
    packet_to_send = data_size / 1024;
    byte_to_send = data_size % 1024;

    // open data file
    fp = fopen("/root/gcam/data/raw_data.dat", "rb");

    for (i = 0; i < packet_to_send; i++) {
      fread(wbuf, 1, 1024, fp);
      send(client_fd, wbuf, 1024, 0);
    }

   if (byte_to_send) {
      fread(wbuf, 1, byte_to_send, fp);
      send(client_fd, wbuf, byte_to_send, 0);
    }

    // close file
    fclose(fp);
  }
  else {
    wbuf[0] = 0;
    wbuf[1] = 0;
    wbuf[2] = 0;
    wbuf[3] = 0;
    send(client_fd, wbuf, 4, 0);
  }
}

int main(void)  
{ 
  struct sockaddr_in server_addr; 
  struct sockaddr_in client_addr; 
  int server_fd;
  int client_fd;
  char client_buf[20];
  char rbuf[10];
  char wbuf[4];
  unsigned int client_len;
  int daq;
  int connected;
  int client_status;
  char client_com;
  int daq_time;
  float fdaq_time;
  FILE *count_fp;
  FILE *spect_fp;
  FILE *image_fp;
  FILE *req_fp;
  FILE *wr_fp;
  FILE *rd_fp;
  FILE *run_fp;
  int data_size;
  int nevt;
  int itmp;
  int evt_cnt;

  // register server
  if((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == -1) 
    return -1;

  memset(&server_addr, 0x00, sizeof(server_addr));
 
  server_addr.sin_family = AF_INET;
  server_addr.sin_addr.s_addr = inet_addr("192.168.0.3");
  server_addr.sin_port = htons(5000);

  // bind
  if(bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) <0) 
    return -1;

  // listen   
  if(listen(server_fd, 5) < 0) 
    return -1;
 
  client_len = sizeof(client_addr);

  daq = 1;
  while(daq) {
    // wait for client being connected
    client_fd = accept(server_fd, (struct sockaddr *)&client_addr, &client_len);
    if(client_fd < 0) 
      return -1;

    inet_ntop(AF_INET, &client_addr.sin_addr.s_addr, client_buf, sizeof(client_buf));

    connected = 1;
    evt_cnt = 0;

    while (connected) {
      // get command from server, if no command for 5 seconds, disconnect client
      client_status = recv(client_fd, rbuf, 5, 0);
      if (client_status < 0) 
        connected = 0;
      else {
        client_com = rbuf[0];

        data_size = 0;

        // set DAQ time and start DAQ and CAMERA software
        if (client_com == 'A') {
          daq_time = rbuf[1] & 0xFF;
          itmp = rbuf[2] & 0xFF;
          itmp = itmp << 8;
          daq_time = daq_time + itmp;
          itmp = rbuf[3] & 0xFF;
          itmp = itmp << 16;
          daq_time = daq_time + itmp;
          itmp = rbuf[4] & 0xFF;
          itmp = itmp << 24;
          daq_time = daq_time + itmp;
          fdaq_time = daq_time;

          // write DAQ time to file
          run_fp = fopen("/dev/shm/run.txt", "wt");
          fprintf(run_fp, "%f\n", fdaq_time);
          fclose(run_fp);

          // start DAQ software
          system("sudo /root/gcam/run/gcam_daq.exe&");
        }

        // update count rate       
        else if (client_com == 'C') {
          if ((access("/dev/shm/count.txt", 0)) == 0) {
            count_fp = fopen("/dev/shm/count.txt", "rt");
            fscanf(count_fp, "%d", &data_size);
            fclose(count_fp);
            send_data_to_client(client_fd, data_size, "/root/gcam/data/count.dat"); 
            system("rm /dev/shm/count.txt");
          }
          else {
            send_data_to_client(client_fd, 0, "/root/gcam/data/count.dat"); 
          }
        }
             
        // update spectrum
        else if (client_com == 'S') {
          if ((access("/dev/shm/spectrum.txt", 0)) == 0) {
            spect_fp = fopen("/dev/shm/spectrum.txt", "rt");
            fscanf(spect_fp, "%d", &data_size);
            fclose(spect_fp);
            send_data_to_client(client_fd, data_size, "/root/gcam/data/spectrum.dat"); 
            system("rm /dev/shm/spectrum.txt");
          }
          else {
            send_data_to_client(client_fd, 0, "/root/gcam/data/spectrum.dat"); 
          }
        }

        // update image
        else if (client_com == 'I') {
          if ((access("/dev/shm/image.txt", 0)) == 0) {
            image_fp = fopen("/dev/shm/image.txt", "rt");
            fscanf(image_fp, "%d", &data_size);
            fclose(image_fp);
            send_data_to_client(client_fd, data_size, "/root/gcam/data/image.dat"); 
            system("rm /dev/shm/image.txt");
          }
          else {
            send_data_to_client(client_fd, 0, "/root/gcam/data/image.dat"); 
          }
        }

        // raw data request
        else if (client_com == 'R') {
	  // get # of events to send
          nevt = rbuf[1] & 0xFF;
          itmp = rbuf[2] & 0xFF;
          itmp = itmp << 8;
          nevt = nevt + itmp;
          itmp = rbuf[3] & 0xFF;
          itmp = itmp << 16;
          nevt = nevt + itmp;
          itmp = rbuf[4] & 0xFF;
          itmp = itmp << 24;
          nevt = nevt + itmp;

          if (nevt) {
            // write 0 to data size file
            wr_fp = fopen("/dev/shm/daq_write.txt", "wt");
            fprintf(wr_fp, "%d\n", 0);
            fclose(wr_fp);

            // save data request file
            rd_fp = fopen("/dev/shm/daq_read.txt", "wt");
            fprintf(rd_fp, "%d\n", nevt);
            fclose(rd_fp);

            // make request file
            req_fp = fopen("/dev/shm/daq_req.txt", "wt");
            fclose(req_fp);
          }

          // reset event count
          evt_cnt = 0;

          // send back event size
          wbuf[0] = nevt & 0xFF;
          wbuf[1] = (nevt >> 8) & 0xFF;
          wbuf[2] = (nevt >> 16) & 0xFF;
          wbuf[3] = (nevt >> 24) & 0xFF;
          send(client_fd, wbuf, 4, 0);
        }

        // get event count
        else if (client_com == 'E') {
          evt_cnt = 0;
          if ((access("/dev/shm/daq_write.txt", 0)) == 0) {
            wr_fp = fopen("/dev/shm/daq_write.txt", "rt");
            fscanf(wr_fp, "%d", &evt_cnt);
            fclose(wr_fp);
            system("rm /dev/shm/daq_write.txt");
          }
          
          // send data size
          wbuf[0] = evt_cnt & 0xFF;
          wbuf[1] = (evt_cnt >> 8) & 0xFF;
          wbuf[2] = (evt_cnt >> 16) & 0xFF;
          wbuf[3] = (evt_cnt >> 24) & 0xFF;
          send(client_fd, wbuf, 4, 0);
        }

        // raw data read
        else if (client_com == 'D') {
          send_raw_data_to_client(client_fd, nevt);
        }

        // disconnect server
        else if (client_com == 'T') {
          if ((access("/dev/shm/run.txt", 0)) == 0) 
            system("rm /dev/shm/run.txt");

          connected = 0;
        }
      }
    }

    // close client connection
    close(client_fd);
  }

  // close server
  close(server_fd);

  return 0;
} 

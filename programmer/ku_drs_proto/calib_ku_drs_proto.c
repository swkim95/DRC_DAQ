#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "NoticeKU_DRS_PROTO.h"

int main(int argc, char *argv[])
{
  int sid;
  int ch;
  int i;
  int offset[4][4096];
  int loop;
  int buf_cnt;
  char data[32768];
  int adc;
  int max;
  FILE *fp;
  char lut[16384];
  FILE *tfp;

  // check # of argument
  if (argc < 2) 
    sid = 1;
  else
    sid = atoi(argv[1]);

  // open DRS
  KU_DRS_PROTOopen(sid);

  // reset PDRS
  KU_DRS_PROTOreset(sid);

  // set calibration mode on
  KU_DRS_PROTOwrite_CALMODE(sid, 1);

  // reset offset
  for (ch = 1; ch <= 4; ch++) {
    for (i = 0; i < 4096; i++)  
      offset[ch -1][i] = 0;
  }

  // start DAQ
  KU_DRS_PROTOstart(sid);

  for (loop = 0; loop < 1000; loop++) {
    buf_cnt = 0;
    while(!buf_cnt) {
      KU_DRS_PROTOsend_TRIG(sid);
      buf_cnt = KU_DRS_PROTOread_DATASIZE(sid);
    }

    KU_DRS_PROTOread_DATA(sid, 1, data);

    for (i = 0; i < 4096; i++) {
      for (ch = 0; ch < 4; ch++) {
        adc = data[8 * i + ch * 2 + 1] & 0xFF;
        adc = adc << 8;
        adc = adc + (data[8 * i + ch * 2] & 0xFF);
        offset[ch][i] = offset[ch][i] + adc;
      }
    }

    printf("%d / 1000 data are taken\n", loop + 1);
  }

  // get average
  for (ch = 0; ch < 4; ch++) {
    for (i = 0; i < 4096; i++) {
      offset[ch][i] = (offset[ch][i] + 500) / 1000;
    }
  }
  
  // find maximum & offset
  tfp = fopen("offset.txt", "wt");
  for (ch = 0; ch < 4; ch++) {
    max = 0;
    for (i = 0; i < 4096; i++) {
      if (offset[ch][i] > max)
        max = offset[ch][i];
    }

    for (i = 0; i < 4096; i++) {
      fprintf(tfp, "%d  %d  %d\n", ch, i, offset[ch][i]);
      offset[ch][i] = max - offset[ch][i];
      lut[ch * 4096 + i] = offset[ch][i] & 0xFF;
    }
  }    
  fclose(tfp);

  // stop DAQ
  KU_DRS_PROTOstop(sid);

  // set calibration mode off
  KU_DRS_PROTOwrite_CALMODE(sid, 0);

  // reset DAQ
  KU_DRS_PROTOreset(sid);

  // write file
  fp = fopen("calLUT.dat", "wb");
  fwrite(lut, 1, 16384, fp);
  fclose(fp);

  // close DRS
  KU_DRS_PROTOclose(sid);

  return 0;
}


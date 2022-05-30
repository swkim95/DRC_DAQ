#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main(void)
{
  char lut[32768];
  FILE *fp;
  int i;

  for (i = 0; i < 32768; i++)
//    lut[i] = i & 0xFF;
    lut[i] = 0x00;
    
  // write file
  fp = fopen("mydbg.dat", "wb");
  fwrite(lut, 1, 32768, fp);
  fclose(fp);

  return 0;
}


#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// 1st argument : 0 = charge data, 1 = charge data + FADC data
int main(int argc, char *argv[])
{
  FILE *fp;
  unsigned short data[100];
  int i;
  
  // open data file
  fp = fopen("cal.dat", "rb");

  fread(data, 2, 100, fp);
  for (i = 0; i < 100; i++) 
    printf("%d : %d\n", i, data[i]);

  // close file  
  fclose(fp);  

  return 0;
}


#include <unistd.h>
#include <stdio.h>

void plot_fadc()
{
  char filename[256];
  FILE *fp;
  int file_size;
  int nevt; 
  TCanvas *c1;
  TH1F *plot_fadc = 0;
  int evt;
  char header[8];
  short data[512];
  int mid;
  int ch;
  int trigger_type;
  int fine_time;
  int coarse_time;
  double ttime;
  int tmp;
  int i;
  int dummy;

  // data filename
  sprintf(filename, "sipm_fadc.dat");
  
  // get # of events
  fp = fopen(filename, "rb");
  fseek(fp, 0L, SEEK_END);
  file_size = ftell(fp);
  fclose(fp);

  // 1 event = 16 byte
  nevt = file_size / 1024;

  // define canvas & histograms
  c1 = new TCanvas("c1", "KFADC", 800, 400);

  plot_fadc = new TH1F("plot_fadc", "Waveform", 508, 0, 4064);
  plot_fadc->SetStats(0);

  // open data file
  fp = fopen(filename, "rb");

  for (evt = 0; evt < nevt; evt++) {
    // read header
    fread(header, 1, 8, fp);

    // get mid
    mid = header[0] & 0xFF;
    
    // get channel
    ch = header[1] & 0xFF;
    
    // get trigger type
    trigger_type = header[2] & 0xFF;
    
    // get time
    fine_time = header[3] & 0xFF;
    
    coarse_time = header[4] & 0xFF;
    tmp = header[5] & 0xFF;
    tmp = tmp << 8;
    coarse_time = coarse_time + tmp;
    tmp = header[6] & 0xFF;
    tmp = tmp << 16;
    coarse_time = coarse_time + tmp;
    tmp = header[7] & 0xFF;
    tmp = tmp << 24;
    coarse_time = coarse_time + tmp;

    ttime = coarse_time;
    ttime = coarse_time * 1000;
    ttime = ttime + fine_time * 8;
    ttime = ttime / 1000000.0;        // in ms

    // read data
    fread(data, 2, 508, fp);

    // get fadc
    plot_fadc->Reset();
    for (i = 0; i < 508; i++) 
      plot_fadc->Fill(i * 8, data[i]);

    plot_fadc->Draw("hist");
    c1->Modified();
    c1->Update();
    
    printf("evt = %d, ttime = %lf, continue(1 = yes, 0 = no) : ", evt, ttime);
    scanf("%d", &dummy);
    if (!dummy)
      evt = nevt;
  }
  
  fclose(fp);
}


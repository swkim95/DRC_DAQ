#include <unistd.h>
#include <stdio.h>

void plot_raw_data()
{
  char filename[256];
  FILE *fp;
  int file_size;
  int nevt; 
  TCanvas *c1;
  TH1F *plot_peak = 0;
  TH1F *plot_body = 0;
  TH1F *plot_tail = 0;
  TH1F *plot_ratio = 0;
  TH2F *plot_psd = 0;
  TH1F *plot_flag = 0;
  int evt;
  char data[16];
  int mid;
  int ch;
  int fine_time;
  int coarse_time;
  double ttime;
  int flag;
  int body;
  int peak;
  int tail;
  double fbody;
  double ftail;
  double ratio;
  int tmp;

  // data filename
  sprintf(filename, "sipm_raw.dat");
  
  // get # of events
  fp = fopen(filename, "rb");
  fseek(fp, 0L, SEEK_END);
  file_size = ftell(fp);
  fclose(fp);

  // 1 event = 16 byte
  nevt = file_size / 16;

  // define canvas & histograms
  c1 = new TCanvas("c1", "KFADC", 1200, 800);
  c1->Divide(3,2);
  plot_peak = new TH1F("plot_peak", "Peak", 1024, 0, 16384);
  plot_body = new TH1F("plot_body", "Body", 1000, 0, 100000);
  plot_tail = new TH1F("plot_tail", "Tail", 1000, 0, 100000);
  plot_ratio = new TH1F("plot_ratio", "Ratio", 200, 0.0, 1.0);
  plot_psd = new TH2F("plot_psd", "PSD", 1000, 0, 100000, 1000, 0, 100000);
  plot_flag = new TH1F("plot_flag", "Neutron = 1", 4, 0, 4);
//  plot_flag = new TH1F("plot_flag", "time tag", nevt, 0, nevt);
  plot_peak->Reset();
  plot_body->Reset();
  plot_tail->Reset();
  plot_ratio->Reset();
  plot_psd->Reset();
  plot_flag->Reset();
//  plot_peak->SetStats(0);
//  plot_body->SetStats(0);
//  plot_tail->SetStats(0);
  plot_ratio->SetStats(0);
  plot_psd->SetStats(0);
  plot_flag->SetStats(0);

  // open data file
  fp = fopen(filename, "rb");

  for (evt = 0; evt < nevt; evt++) {
    // read data
    fread(data, 1, 16, fp);

    // get mid
    mid = data[0] & 0xFF;
    
    // get channel
    ch = data[1] & 0xFF;
    
    // get time
    fine_time = data[2] & 0xFF;
    
    coarse_time = data[3] & 0xFF;
    tmp = data[4] & 0xFF;
    tmp = tmp << 8;
    coarse_time = coarse_time + tmp;
    tmp = data[5] & 0xFF;
    tmp = tmp << 16;
    coarse_time = coarse_time + tmp;
    tmp = data[6] & 0xFF;
    tmp = tmp << 24;
    coarse_time = coarse_time + tmp;

    ttime = coarse_time;
    ttime = coarse_time * 1000;
    ttime = ttime + fine_time * 8;
    ttime = ttime / 1000000.0;        // in ms
    
    // get flag
    flag = data[7] & 0xFF;
    
    // get body
    body = data[8] & 0xFF;
    tmp = data[9] & 0xFF;
    tmp = tmp << 8;
    body = body + tmp;
    tmp = data[10] & 0xFF;
    tmp = tmp << 16;
    body = body + tmp;

    // get peak
    peak = data[11] & 0xFF;
    tmp = data[12] & 0xFF;
    tmp = tmp << 8;
    peak = peak + tmp;
    
    // get tail
    tail = data[13] & 0xFF;
    tmp = data[14] & 0xFF;
    tmp = tmp << 8;
    tail = tail + tmp;
    tmp = data[15] & 0xFF;
    tmp = tmp << 16;
    tail = tail + tmp;
    
    // get ratio
    fbody = body;
    ftail = tail;
    ratio = ftail / fbody;
    
    // fill histogram
//    if (peak > 0) {
      plot_peak->Fill(peak, peak);
      plot_body->Fill(body, body);
      plot_tail->Fill(tail, tail);
      plot_ratio->Fill(ratio);
      plot_psd->Fill(body, tail);
      plot_flag->Fill(flag);
//    plot_flag->Fill(evt, ttime);
//    }
  }
  
  fclose(fp);

  c1->cd(1);
  plot_peak->Draw("hist");
  c1->cd(2);
  plot_body->Draw("hist");
  c1->cd(3);
  plot_tail->Draw("hist");
  c1->cd(4);
  plot_ratio->Draw("hist");
  c1->cd(5);
  plot_psd->Draw("COLZ");
  c1->cd(6);
  plot_flag->Draw("hist");
  c1->Modified();
  c1->Update();
}


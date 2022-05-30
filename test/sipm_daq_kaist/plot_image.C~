#include<stdio.h>

void plot_image()
{
  char filename[256];
  FILE *fp;	
  int file_size;
  int num_of_frame;
  int frame;
  int ctime;
  int data[1024];
  int x;
  int y;
  TCanvas *c1;
  TH2F *plot_n = 0;
  TH2F *plot_g = 0;
  double image_n[144];
  double image_g[144];
  double ref_n;
  double ref_g;
  int mod;
  
  // data filename
  sprintf(filename, "sipm_tcb.dat");

  // get # of frames
  fp = fopen(filename, "rb");
  fseek(fp, 0L, SEEK_END);
  file_size = ftell(fp);
  fclose(fp);

  num_of_frame = file_size / 4096;

  // define canvas & histograms
  c1 = new TCanvas("c1", "KFADC", 1200, 600);
  c1->Divide(2, 1);

  plot_n = new TH2F("plot_n", "Neutron", 116, 0, 116, num_of_frame, 0, num_of_frame);
  plot_g = new TH2F("plot_g", "Gamma", 116, 0, 116, num_of_frame, 0, num_of_frame);
  plot_n->SetStats(0);
  plot_g->SetStats(0);
  plot_n->Reset();
  plot_g->Reset();
  
  fp = fopen(filename, "rb");
  
  for (y = 0; y < num_of_frame; y++) {
    // read data
    fread(data, 4, 1024, fp);
    
    // get frame
    frame = data[0];
    
    // get ctime
    ctime = data[1];
    
    // get image
    for (mod = 0; mod < 9; mod++) {
      image_n[16 * mod + 0] = data[64 * mod + 2] + data[64 * mod + 16];
      image_n[16 * mod + 1] = data[64 * mod + 4] + data[64 * mod + 14];
      image_n[16 * mod + 2] = data[64 * mod + 6] + data[64 * mod + 12];
      image_n[16 * mod + 3] = data[64 * mod + 8] + data[64 * mod + 10];
      image_n[16 * mod + 4] = data[64 * mod + 18] + data[64 * mod + 32];
      image_n[16 * mod + 5] = data[64 * mod + 20] + data[64 * mod + 30];
      image_n[16 * mod + 6] = data[64 * mod + 22] + data[64 * mod + 28];
      image_n[16 * mod + 7] = data[64 * mod + 24] + data[64 * mod + 26];
      image_n[16 * mod + 8] =  data[64 * mod + 34] + data[64 * mod + 48];
      image_n[16 * mod + 9] =  data[64 * mod + 36] + data[64 * mod + 46];
      image_n[16 * mod + 10] = data[64 * mod + 38] + data[64 * mod + 44];
      image_n[16 * mod + 11] = data[64 * mod + 40] + data[64 * mod + 42];
      image_n[16 * mod + 12] = data[64 * mod + 50] + data[64 * mod + 64];
      image_n[16 * mod + 13] = data[64 * mod + 52] + data[64 * mod + 62];
      image_n[16 * mod + 14] = data[64 * mod + 54] + data[64 * mod + 60];
      image_n[16 * mod + 15] = data[64 * mod + 56] + data[64 * mod + 58];

      image_g[16 * mod + 0] = data[64 * mod + 3] + data[64 * mod + 17];
      image_g[16 * mod + 1] = data[64 * mod + 5] + data[64 * mod + 15];
      image_g[16 * mod + 2] = data[64 * mod + 7] + data[64 * mod + 13];
      image_g[16 * mod + 3] = data[64 * mod + 9] + data[64 * mod + 11];
      image_g[16 * mod + 4] = data[64 * mod + 19] + data[64 * mod + 33];
      image_g[16 * mod + 5] = data[64 * mod + 21] + data[64 * mod + 31];
      image_g[16 * mod + 6] = data[64 * mod + 23] + data[64 * mod + 29];
      image_g[16 * mod + 7] = data[64 * mod + 25] + data[64 * mod + 27];
      image_g[16 * mod + 8] =  data[64 * mod + 35] + data[64 * mod + 49];
      image_g[16 * mod + 9] =  data[64 * mod + 37] + data[64 * mod + 47];
      image_g[16 * mod + 10] = data[64 * mod + 39] + data[64 * mod + 45];
      image_g[16 * mod + 11] = data[64 * mod + 41] + data[64 * mod + 43];
      image_g[16 * mod + 12] = data[64 * mod + 51] + data[64 * mod + 65];
      image_g[16 * mod + 13] = data[64 * mod + 53] + data[64 * mod + 63];
      image_g[16 * mod + 14] = data[64 * mod + 55] + data[64 * mod + 61];
      image_g[16 * mod + 15] = data[64 * mod + 57] + data[64 * mod + 59];
    }

    ref_n = image_n[128] + image_n[129] + image_n[130] + image_n[131]
          + image_n[132] + image_n[133] + image_n[134] + image_n[135]
          + image_n[136] + image_n[137] + image_n[138] + image_n[139]
          + image_n[140] + image_n[141] + image_n[142] + image_n[143];
    ref_n = ref_n / 16.0;

    ref_g = image_g[128] + image_g[129] + image_g[130] + image_g[131]
          + image_g[132] + image_g[133] + image_g[134] + image_g[135]
          + image_g[136] + image_g[137] + image_g[138] + image_g[139]
          + image_g[140] + image_g[141] + image_g[142] + image_g[143];
    ref_g = ref_g / 16.0;

    if (ref_n == 0)
      ref_n = 1.0;

    if (ref_g == 0)
      ref_g = 1.0;

    for (x = 0; x < 116; x++) {
      image_n[x] = image_n[x] / ref_n;
      image_n[x] = image_n[x] / ref_n;
    }

    // fill image
    for (x = 0; x < 116; x++) {
      plot_n->Fill(x, y, image_n[x]);
      plot_g->Fill(x, y, image_g[x]);
    }
  }

  fclose(fp);

  c1->cd(1);
  plot_n->Draw("COLZ");
  c1->cd(2);
  plot_g->Draw("COLZ");
  c1->Modified();
  c1->Update();
}

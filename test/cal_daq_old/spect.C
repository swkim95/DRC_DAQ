void spect()
{
  char data[200];
  unsigned short sval[100];
  int i;
  FILE *fp;
  unsigned short val;
  unsigned short tmp;

  TCanvas* c1 = new TCanvas("c1", "IBS_SIPM_DAQ", 800, 400);
  TH1F* plot = new TH1F("plot", "Spectrum", 100, 0, 100);
  plot->Reset();

   // open data file
  fp = fopen("cal.dat", "rb");

  fread(data, 1, 200, fp);
    memcpy(sval, data, 200);

  // close file  
  fclose(fp);  

     // plot waveform
      for (i = 0; i < 100; i++) {
//        val = data[i * 2] & 0xFF;
//        tmp = data[i * 2 + 1] & 0xFF;
//        tmp = tmp << 8;
//        val = val + tmp;
       plot->Fill(i, sval[i]);
      }
      plot->Draw("hist");
      c1->Modified();
      c1->Update();
}



  

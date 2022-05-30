void ibs_sipm_daq_spectrum()
{
  // setting
  float hv = 55.0;          // high voltage, 4.5 ~ 60.0
  int thr = 100;            // discriminator threshold, 1 ~ 65535, pulse area for 320 ns width

  // variables
  char filename[256];
  sprintf(filename, "spectrum.dat");        // data file name
  int nevt = 100000;                         // number of events
  unsigned short data[512];
  int evt;
  TCanvas *c1;
  TH1F *plot;
  int tcp_Handle;
  FILE *fp;
  int data_size;
  int i;

  // Loading library
  gSystem->Load("libNoticeIBS_SIPM_DAQROOT.so");			

  // define class
  NKIBS_SIPM_DAQ *daq = new NKIBS_SIPM_DAQ;
   
  c1 = new TCanvas("c1", "IBS_SIPM_DAQ", 800, 400);
  plot = new TH1F("plot", "Spectrum", 1024, 0, 65536);
  plot->Reset();

  // open DAQ
  tcp_Handle = daq->IBS_SIPM_DAQopen();

  // reset DAQ
  daq->IBS_SIPM_DAQreset(tcp_Handle);

  // set high voltage
  daq->IBS_SIPM_DAQwrite_HV(tcp_Handle, hv);
  
  // set threshold
  daq->IBS_SIPM_DAQwrite_THR(tcp_Handle, thr);

  // readback settings
  printf("High voltage = %f\n", daq->IBS_SIPM_DAQread_HV(tcp_Handle));
  printf("Threshold = %d\n", daq->IBS_SIPM_DAQread_THR(tcp_Handle));
  printf("Temperature = %f\n", daq->IBS_SIPM_DAQread_TEMP(tcp_Handle));
  printf("Pedestal = %d\n", daq->IBS_SIPM_DAQread_PED(tcp_Handle));
  
  // open data file
  fp = fopen(filename, "wb");

  // start DAQ
  daq->IBS_SIPM_DAQstart(tcp_Handle);

  evt = 0;
  while (evt < nevt) {
    data_size = daq->IBS_SIPM_DAQread_DATA(tcp_Handle, data);
    
    if (data_size) {
      // write to file
      fwrite(data, 2, data_size, fp);
    
      // plot waveform
      for (i = 0; i < data_size; i++)
        plot->Fill(data[i]);
      plot->Draw();
      c1->Modified();
      c1->Update();

      evt = evt + data_size;
      printf("%d / %d is taken.\n", evt + 1, nevt);
    }
  }

  // close data file
  fclose(fp);

  // close DAQ    
  daq->IBS_SIPM_DAQclose(tcp_Handle);
}



  

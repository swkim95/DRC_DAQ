enum discriminator {
	kIntegral = 0,
	kPeak,
	kWaveform
};


void Prompt(TString name, enum discriminator opt) {
	if( opt == 0 ) gROOT->ProcessLine(".x prompt_analysis_using_integral.cc(\"muon_06_02_"+name+"\")");
	if( opt == 1 ) gROOT->ProcessLine(".x prompt_analysis_using_peak.cc(\"muon_06_02_"+name+"\")");
	if( opt == 2 ) gROOT->ProcessLine(".x plot_waveform_4ch.C(\"/media/yu/Expansion/DAQ_data/220602/muon_06_02_"+name+".dat\")");

	printf("Allowed option is [kIntegral, kPeak, kWaveform] \n");
}


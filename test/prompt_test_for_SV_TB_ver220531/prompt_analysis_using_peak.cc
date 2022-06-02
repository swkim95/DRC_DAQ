#include <cstdio>
#include <algorithm>
#include <vector>
#include <TPad.h>

void pad_set(TPad* tPad) {
    tPad->Draw();
    tPad->cd();

    tPad->SetTopMargin(0.12);
    tPad->SetLeftMargin(0.12);    
    tPad->SetRightMargin(0.12);
    tPad->SetBottomMargin(0.12);
}

void prompt_analysis_using_peak(const char* filename) {

    // ch 1 : A 
    // ch 5 : B - S
    // ch 11 : B - C
    // ch 15 : C    

    int chNum_1 = 0;
    int chNum_2 = 4;
    int chNum_3 = 10;
    int chNum_4 = 14;

    FILE *fp;
    int file_size;
    int nevt;
    char data[64];
    short adc[32736];

    // kWhite  = 0,   kBlack  = 1,   kGray    = 920,  kRed    = 632,  kGreen  = 416,
    // kBlue   = 600, kYellow = 400, kMagenta = 616,  kCyan   = 432,  kOrange = 800,
    // kSpring = 820, kTeal   = 840, kAzure   =  860, kViolet = 880,  kPink   = 900
    
    TH1F* plot1 = new TH1F("ch1", "#font[42]{#scale[0.8]{Module A - #color[634]{S ch}}};#font[42]{ADC};#font[42]{evts}", 256, 0., 4095.); plot1->SetStats(0);
    plot1->SetLineWidth(2); plot1->SetLineColor(634); plot1->Sumw2(); plot1->GetYaxis()->SetTitle( "" );    
    TH1F* plot3 = new TH1F("ch3", "#font[42]{#scale[0.8]{Module B - #color[634]{S ch}}};#font[42]{ADC};#font[42]{evts}", 256, 0., 4095.); plot3->SetStats(0);
    plot3->SetLineWidth(2); plot3->SetLineColor(634); plot3->Sumw2(); plot3->GetYaxis()->SetTitle( "" );  
    TH1F* plot5 = new TH1F("ch5", "#font[42]{#scale[0.8]{Module B - #color[602]{C ch}}};#font[42]{ADC};#font[42]{evts}", 256, 0., 4095.); plot5->SetStats(0);
    plot5->SetLineWidth(2); plot5->SetLineColor(602); plot5->Sumw2(); plot5->GetYaxis()->SetTitle( "" );  
    TH1F* plot7 = new TH1F("ch7", "#font[42]{#scale[0.8]{Module C - #color[634]{S ch}}};#font[42]{ADC};#font[42]{evts}", 256, 0., 4095.); plot7->SetStats(0);
    plot7->SetLineWidth(2); plot7->SetLineColor(634); plot7->Sumw2(); plot7->GetYaxis()->SetTitle( "" );  

    TH1F* plot_wav_1 = new TH1F("plot1", "Waveform", 1000, 1, 1000);
    TH1F* plot_wav_2 = new TH1F("plot2", "Waveform", 1000, 1, 1000);
    TH1F* plot_wav_3 = new TH1F("plot3", "Waveform", 1000, 1, 1000);
    TH1F* plot_wav_4 = new TH1F("plot4", "Waveform", 1000, 1, 1000);

    fp = fopen(filename, "rb");
    fseek(fp, 0L, SEEK_END);
    file_size = ftell(fp);
    fclose(fp);
    nevt = file_size / 65536;
    
    fp = fopen(filename, "rb");

    for (int evt = 0; evt < nevt; evt++) {
        fread(data, 1, 64, fp);
        fread(adc, 2, 32736, fp);

        float ch1_ped = 0;
        float ch3_ped = 0;
        float ch5_ped = 0;
        float ch7_ped = 0;

        std::vector<int> waveform_vec_1;
        std::vector<int> waveform_vec_3;
        std::vector<int> waveform_vec_5;
        std::vector<int> waveform_vec_7;

        plot_wav_1->Reset("ICESM");
        plot_wav_2->Reset("ICESM");
        plot_wav_3->Reset("ICESM");
        plot_wav_4->Reset("ICESM");


        // fill waveform for channel to plotgecit
        float pedNbin = 50.;
        for (int i = 1; i < pedNbin + 1; i++) {
            ch1_ped += (float)adc[i * 32 + chNum_1] / pedNbin;
            ch3_ped += (float)adc[i * 32 + chNum_2] / pedNbin;
            ch5_ped += (float)adc[i * 32 + chNum_3] / pedNbin;
            ch7_ped += (float)adc[i * 32 + chNum_4] / pedNbin;
        }

        for (int i = 1; i < 1001; i++) {

        // for (int i = 0; i < 1023; i++) {
            // waveform_vec_1.push_back(ch1_ped - adc[i * 32 + chNum_1]);
            // waveform_vec_3.push_back(ch3_ped - adc[i * 32 + chNum_2]);
            // waveform_vec_5.push_back(ch5_ped - adc[i * 32 + chNum_3]);
            // waveform_vec_7.push_back(ch7_ped - adc[i * 32 + chNum_4]);

            plot_wav_1->Fill(i,ch1_ped - adc[i * 32 + chNum_1]);
            plot_wav_2->Fill(i,ch3_ped - adc[i * 32 + chNum_2]);
            plot_wav_3->Fill(i,ch5_ped - adc[i * 32 + chNum_3]);
            plot_wav_4->Fill(i,ch7_ped - adc[i * 32 + chNum_4]);
        }

        // plot1->Fill(*std::max_element(waveform_vec_1.begin(), waveform_vec_1.end()));
        // plot3->Fill(*std::max_element(waveform_vec_3.begin(), waveform_vec_3.end()));
        // plot5->Fill(*std::max_element(waveform_vec_5.begin(), waveform_vec_5.end()));
        // plot7->Fill(*std::max_element(waveform_vec_7.begin(), waveform_vec_7.end()));

        plot1->Fill(plot_wav_1->GetMaximum());
        plot3->Fill(plot_wav_2->GetMaximum());
        plot5->Fill(plot_wav_3->GetMaximum());
        plot7->Fill(plot_wav_4->GetMaximum());

        
    }
    TCanvas* c = new TCanvas("c", "c", 1000, 1000);

    c->cd();
    TPad* pad_LB = new TPad("pad_LB","pad_LB", 0.01, 0.01, 0.5, 0.5 );
    pad_set(pad_LB);

    c->cd();
    TPad* pad_RB = new TPad("pad_RB","pad_RB", 0.5, 0.01, 0.99, 0.5 );
    pad_set(pad_RB);

    c->cd();
    TPad* pad_LT = new TPad("pad_LT","pad_LT", 0.01, 0.5, 0.5, 0.99 );
    pad_set(pad_LT);

    c->cd();
    TPad* pad_RT = new TPad("pad_RT","pad_RT", 0.5, 0.5, 0.99, 0.99 );
    pad_set(pad_RT);

    c->cd(); pad_LT->cd(); plot1->Draw("Hist");
    c->cd(); pad_RT->cd(); plot7->Draw("Hist");
    c->cd(); pad_LB->cd(); plot3->Draw("Hist");
    c->cd(); pad_RB->cd(); plot5->Draw("Hist");

    c->cd(); pad_LT->cd();
    TLatex cmspreLatex; 
    cmspreLatex.DrawLatexNDC(0.12, 0.89, "#font[62]{DRC}#font[42]{#it{#scale[0.8]{ Internal}}}");
}


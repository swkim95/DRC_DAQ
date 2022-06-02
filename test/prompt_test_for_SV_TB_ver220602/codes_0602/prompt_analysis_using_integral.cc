#include <cstdio>
#include <algorithm>
#include <vector>
#include <numeric>
#include <TPad.h>

void pad_set(TPad* tPad) {
    tPad->Draw();
    tPad->cd();

    tPad->SetTopMargin(0.08);
    tPad->SetLeftMargin(0.08);    
    tPad->SetRightMargin(0.08);
    tPad->SetBottomMargin(0.08);
}

void prompt_analysis_using_integral(std::string filename) {
    // ch 1 : A 
    // ch 3 : B - S
    // ch 5 : B - C
    // ch 7 : C 

    // int channel;
    // int ch_to_plot;
    FILE *fp;
    int file_size;
    int nevt;
    char data[64];
    short adc[32736];

    int chNum_1 = 0;
    int chNum_2 = 4;
    int chNum_3 = 10;
    int chNum_4 = 14;
    
    // int data_length;
    // int run_number;
    // int tcb_trig_type;
    // int tcb_trig_number;
    // long long tcb_trig_time;
    // int mid;
    // int local_trig_number;
    // int local_trigger_pattern;
    // long long local_trig_time;
    // long long diff_time;
    // long long fine_time;
    // long long coarse_time;
    // int itmp;
    // long long ltmp;
    // int i;
    // int cont;

    // ch 1 : A 
    // ch 3 : B - S
    // ch 5 : B - C
    // ch 7 : C    

    // kWhite  = 0,   kBlack  = 1,   kGray    = 920,  kRed    = 632,  kGreen  = 416,
    // kBlue   = 600, kYellow = 400, kMagenta = 616,  kCyan   = 432,  kOrange = 800,
    // kSpring = 820, kTeal   = 840, kAzure   =  860, kViolet = 880,  kPink   = 900
    
    TH1F* plot1 = new TH1F("ch1", "#font[42]{#scale[0.8]{Module A - #color[634]{S ch}}};Integral(ADC)/100;evts", 320, -1024., 4095.); 
    plot1->SetLineWidth(2); plot1->SetLineColor(634); plot1->Sumw2(); plot1->GetYaxis()->SetTitle( "" ); 
    TH1F* plot3 = new TH1F("ch5", "#font[42]{#scale[0.8]{Module B - #color[634]{S ch}}};Integral(ADC)/100;evts", 320, -1024., 4095.); 
    plot3->SetLineWidth(2); plot3->SetLineColor(634); plot3->Sumw2(); plot3->GetYaxis()->SetTitle( "" ); 
    TH1F* plot5 = new TH1F("ch11", "#font[42]{#scale[0.8]{Module B - #color[602]{C ch}}};Integral(ADC)/100;evts", 320, -1024., 4095.); 
    plot5->SetLineWidth(2); plot5->SetLineColor(602); plot5->Sumw2(); plot5->GetYaxis()->SetTitle( "" ); 
    TH1F* plot7 = new TH1F("ch15", "#font[42]{#scale[0.8]{Module C - #color[634]{S ch}}};Integral(ADC)/100;evts", 320, -1024., 4095.); 
    plot7->SetLineWidth(2); plot7->SetLineColor(634); plot7->Sumw2(); plot7->GetYaxis()->SetTitle( "" ); 

    TH1F *plot = new TH1F("plot", "Waveform", 1023, 0, 1023);

    fp = fopen(("/media/yu/Expansion/DAQ_data/220602/"+filename+".dat").c_str(), "rb");
    fseek(fp, 0L, SEEK_END);
    file_size = ftell(fp);
    fclose(fp);
    nevt = file_size / 65536;
    
    fp = fopen(("/media/yu/Expansion/DAQ_data/220602/"+filename+".dat").c_str(), "rb");

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

        // fill waveform for channel to plotgecit
        int pedNbin = 50;
        for (int i = 1; i < pedNbin + 1; i++) {
            ch1_ped += (float)adc[i * 32 + chNum_1] / pedNbin;
            ch3_ped += (float)adc[i * 32 + chNum_2] / pedNbin;
            ch5_ped += (float)adc[i * 32 + chNum_3] / pedNbin;
            ch7_ped += (float)adc[i * 32 + chNum_4] / pedNbin;
        }

        for (int i = 1; i < 1001; i++) {
            waveform_vec_1.push_back(ch1_ped - adc[i * 32 + chNum_1]);
            waveform_vec_3.push_back(ch3_ped - adc[i * 32 + chNum_2]);
            waveform_vec_5.push_back(ch5_ped - adc[i * 32 + chNum_3]);
            waveform_vec_7.push_back(ch7_ped - adc[i * 32 + chNum_4]);
        }


        plot1->Fill((std::accumulate(waveform_vec_1.begin(), waveform_vec_1.end(), 0.f) / 100.));
        plot3->Fill((std::accumulate(waveform_vec_3.begin(), waveform_vec_3.end(), 0.f) / 100.));
        plot5->Fill((std::accumulate(waveform_vec_5.begin(), waveform_vec_5.end(), 0.f) / 100.));
        plot7->Fill((std::accumulate(waveform_vec_7.begin(), waveform_vec_7.end(), 0.f) / 100.));
        
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
    c->SaveAs("/usr/local/notice/test/prompt_test/plots_0602/Integral/png/"+(TString)filename+".png");
    c->SaveAs("/usr/local/notice/test/prompt_test/plots_0602/Integral/svg/"+(TString)filename+".svg");

    c->cd(); pad_LT->cd();
    TLatex cmspreLatex; 
    cmspreLatex.DrawLatexNDC(0.087, 0.93, "#font[62]{DRC}#font[42]{#it{#scale[0.8]{ Internal}}}");

    TFile* validFile = new TFile("/usr/local/notice/test/prompt_test/validFiles/Intergrated/"+(TString)filename+"_validation.root", "RECREATE");
    validFile->WriteTObject(plot1);
    validFile->WriteTObject(plot3);
    validFile->WriteTObject(plot5);
    validFile->WriteTObject(plot7);
    validFile->Close();
}


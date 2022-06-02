#include <cstdio>
#include <algorithm>
#include <vector>
#include <TPad.h>

void pad_set(TPad* tPad) {
    tPad->Draw();
    tPad->cd();

    tPad->SetTopMargin(0.08);
    tPad->SetLeftMargin(0.08);    
    tPad->SetRightMargin(0.08);
    tPad->SetBottomMargin(0.08);
    tPad->SetLogx();
}

void compare_single(TString scenario, TString filename, TString NumNum, TString DenNum) {

    if ( !( scenario == "Intergrated" ) && !( scenario == "Peak" ) ) {
        std::cout << " Allowed scenario : [Integrated, Peak]" << std::endl;
        return;
    }

    TString baseDir = "/usr/local/notice/test/prompt_test/validFiles/";

    TH1F* Num_ch1       = (TH1F*)(TFile::Open(baseDir+scenario+"/"+filename+"_"+NumNum+"_validation.root", "READ")->Get("ch1"));
    TH1F* Num_ch5       = (TH1F*)(TFile::Open(baseDir+scenario+"/"+filename+"_"+NumNum+"_validation.root", "READ")->Get("ch5"));
    TH1F* Num_ch11      = (TH1F*)(TFile::Open(baseDir+scenario+"/"+filename+"_"+NumNum+"_validation.root", "READ")->Get("ch11"));
    TH1F* Num_ch15      = (TH1F*)(TFile::Open(baseDir+scenario+"/"+filename+"_"+NumNum+"_validation.root", "READ")->Get("ch15"));

    TH1F* Den_ch1       = (TH1F*)(TFile::Open(baseDir+scenario+"/"+filename+"_"+DenNum+"_validation.root", "READ")->Get("ch1"));
    TH1F* Den_ch5       = (TH1F*)(TFile::Open(baseDir+scenario+"/"+filename+"_"+DenNum+"_validation.root", "READ")->Get("ch5"));
    TH1F* Den_ch11      = (TH1F*)(TFile::Open(baseDir+scenario+"/"+filename+"_"+DenNum+"_validation.root", "READ")->Get("ch11"));
    TH1F* Den_ch15      = (TH1F*)(TFile::Open(baseDir+scenario+"/"+filename+"_"+DenNum+"_validation.root", "READ")->Get("ch15"));

    Num_ch1->SetLineWidth(2);  Num_ch1->SetLineColor( 632);  Num_ch1->Sumw2();  Num_ch1->GetYaxis()->SetTitle( "" );  Num_ch1->SetMarkerStyle(20);       
    Num_ch5->SetLineWidth(2);  Num_ch5->SetLineColor( 632);  Num_ch5->Sumw2();  Num_ch5->GetYaxis()->SetTitle( "" );  Num_ch5->SetMarkerStyle(20);
    Num_ch11->SetLineWidth(2); Num_ch11->SetLineColor(600); Num_ch11->Sumw2(); Num_ch11->GetYaxis()->SetTitle( "" ); Num_ch11->SetMarkerStyle(20); 
    Num_ch15->SetLineWidth(2); Num_ch15->SetLineColor(632); Num_ch15->Sumw2(); Num_ch15->GetYaxis()->SetTitle( "" ); Num_ch15->SetMarkerStyle(20); 

    Den_ch1->SetLineWidth(2);  Den_ch1->SetLineColor(632);  Den_ch1->Sumw2();  Den_ch1->GetYaxis()->SetTitle( "" );    
    Den_ch5->SetLineWidth(2);  Den_ch5->SetLineColor(632);  Den_ch5->Sumw2();  Den_ch5->GetYaxis()->SetTitle( "" );  
    Den_ch11->SetLineWidth(2); Den_ch11->SetLineColor(600); Den_ch11->Sumw2(); Den_ch11->GetYaxis()->SetTitle( "" );  
    Den_ch15->SetLineWidth(2); Den_ch15->SetLineColor(632); Den_ch15->Sumw2(); Den_ch15->GetYaxis()->SetTitle( "" );

    for ( int binN = 1; binN < Den_ch1->GetNbinsX(); binN++ ) {
        Num_ch1->SetBinError(binN, 1e-8);
        Num_ch5->SetBinError(binN, 1e-8);
        Num_ch11->SetBinError(binN, 1e-8);
        Num_ch15->SetBinError(binN, 1e-8);
    }

    Num_ch1->Scale(1./Num_ch1->GetEntries());
    Num_ch5->Scale(1./Num_ch5->GetEntries());
    Num_ch11->Scale(1./Num_ch11->GetEntries());
    Num_ch15->Scale(1./Num_ch15->GetEntries());
    Den_ch1->Scale(1./Den_ch1->GetEntries());
    Den_ch5->Scale(1./Den_ch5->GetEntries());
    Den_ch11->Scale(1./Den_ch11->GetEntries());
    Den_ch15->Scale(1./Den_ch15->GetEntries());

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

    c->cd(); pad_LT->cd(); Den_ch1->Draw("Hist");  Num_ch1->Draw("p&sames"); 
    c->cd(); pad_RT->cd(); Den_ch5->Draw("Hist");  Num_ch5->Draw("p&sames");
    c->cd(); pad_LB->cd(); Den_ch11->Draw("Hist"); Num_ch11->Draw("p&sames");
    c->cd(); pad_RB->cd(); Den_ch15->Draw("Hist"); Num_ch15->Draw("p&sames");

    c->cd(); pad_LT->cd();
    TLatex cmspreLatex; 
    cmspreLatex.DrawLatexNDC(0.087, 0.93, "#font[62]{DRC}#font[42]{#it{#scale[0.8]{ Internal}}}");
}
#include "NoticeSIPMTCBROOT.h"
#include "NoticeSIPMTCB.h"

ClassImp(NKSIPMTCB)

NKSIPMTCB::NKSIPMTCB() {}

NKSIPMTCB::~NKSIPMTCB() {}

void NKSIPMTCB::USB3Init(void)
{::USB3Init();}

void NKSIPMTCB::USB3Exit(void)
{::USB3Exit();}

int NKSIPMTCB::SIPMTCBopen(int sid)
{return ::SIPMTCBopen(sid);}

void NKSIPMTCB::SIPMTCBclose(int sid)
{::SIPMTCBclose(sid);}

void NKSIPMTCB::SIPMTCBreset(int sid)
{::SIPMTCBreset(sid);}

void NKSIPMTCB::SIPMTCBstart_DAQ(int sid)
{::SIPMTCBstart_DAQ(sid);}

void NKSIPMTCB::SIPMTCBstop_DAQ(int sid)
{::SIPMTCBstop_DAQ(sid);}

void NKSIPMTCB::SIPMTCBsend_TRIG(int sid)
{::SIPMTCBsend_TRIG(sid);}

unsigned long NKSIPMTCB::SIPMTCBread_RUN(int sid)
{return ::SIPMTCBread_RUN(sid);}

void NKSIPMTCB::SIPMTCBwrite_FRAME(int sid, unsigned long data)
{::SIPMTCBwrite_FRAME(sid, data);}

unsigned long NKSIPMTCB::SIPMTCBread_FRAME(int sid)
{return ::SIPMTCBread_FRAME(sid);}

void NKSIPMTCB::SIPMTCBwrite_SCAN_TIME(int sid, unsigned long data)
{::SIPMTCBwrite_SCAN_TIME(sid, data);}

unsigned long NKSIPMTCB::SIPMTCBread_SCAN_TIME(int sid)
{return ::SIPMTCBread_SCAN_TIME(sid);}

void NKSIPMTCB::SIPMTCBwrite_TRIGGER_MODE(int sid, unsigned long data)
{::SIPMTCBwrite_TRIGGER_MODE(sid, data);}

unsigned long NKSIPMTCB::SIPMTCBread_TRIGGER_MODE(int sid)
{return ::SIPMTCBread_TRIGGER_MODE(sid);}

void NKSIPMTCB::SIPMTCBread_LINK(int sid, unsigned long *data)
{::SIPMTCBread_LINK(sid, data);}

void NKSIPMTCB::SIPMTCBread_MID(int sid, unsigned long *data)
{::SIPMTCBread_MID(sid, data);}

unsigned long NKSIPMTCB::SIPMTCBread_DATASIZE(int sid)
{return ::SIPMTCBread_DATASIZE(sid);}

void NKSIPMTCB::SIPMTCBread_DATA(int sid, unsigned long data_size, char *data)
{::SIPMTCBread_DATA(sid, data_size, data);}

void NKSIPMTCB::SIPMTCBwrite_HV(int sid, unsigned long mid, unsigned long ch, float data)
{::SIPMTCBwrite_HV(sid, mid, ch, data);}

float NKSIPMTCB::SIPMTCBread_HV(int sid, unsigned long mid, unsigned long ch)
{return ::SIPMTCBread_HV(sid, mid, ch);}

float NKSIPMTCB::SIPMTCBread_TEMP(int sid, unsigned long mid, unsigned long ch)
{return ::SIPMTCBread_TEMP(sid, mid, ch);}

unsigned long NKSIPMTCB::SIPMTCBread_PED(int sid, unsigned long mid, unsigned long ch)
{return ::SIPMTCBread_PED(sid, mid, ch);}

void NKSIPMTCB::SIPMTCBwrite_THR(int sid, unsigned long mid, unsigned long ch, unsigned long data)
{::SIPMTCBwrite_THR(sid, mid, ch, data);}

unsigned long NKSIPMTCB::SIPMTCBread_THR(int sid, unsigned long mid, unsigned long ch)
{return ::SIPMTCBread_THR(sid, mid, ch);}

void NKSIPMTCB::SIPMTCBwrite_PSW(int sid, unsigned long mid, unsigned long data)
{::SIPMTCBwrite_PSW(sid, mid, data);}

unsigned long NKSIPMTCB::SIPMTCBread_PSW(int sid, unsigned long mid)
{return ::SIPMTCBread_PSW(sid, mid);}

void NKSIPMTCB::SIPMTCBwrite_RISETIME(int sid, unsigned long mid, unsigned long data)
{::SIPMTCBwrite_RISETIME(sid, mid, data);}

unsigned long NKSIPMTCB::SIPMTCBread_RISETIME(int sid, unsigned long mid)
{return ::SIPMTCBread_RISETIME(sid, mid);}

void NKSIPMTCB::SIPMTCBwrite_PSD_DLY(int sid, unsigned long mid, unsigned long data)
{::SIPMTCBwrite_PSD_DLY(sid, mid, data);}

unsigned long NKSIPMTCB::SIPMTCBread_PSD_DLY(int sid, unsigned long mid)
{return ::SIPMTCBread_PSD_DLY(sid, mid);}

void NKSIPMTCB::SIPMTCBwrite_PSD_THR(int sid, unsigned long mid, unsigned long ch, float data)
{::SIPMTCBwrite_PSD_THR(sid, mid, ch, data);}

float NKSIPMTCB::SIPMTCBread_PSD_THR(int sid, unsigned long mid, unsigned long ch)
{return ::SIPMTCBread_PSD_THR(sid, mid, ch);}

void NKSIPMTCB::SIPMTCBalign_ADC(int sid, unsigned long mid)
{::SIPMTCBalign_ADC(sid, mid);}

void NKSIPMTCB::SIPMTCBalign_DRAM(int sid, unsigned long mid)
{::SIPMTCBalign_DRAM(sid, mid);}



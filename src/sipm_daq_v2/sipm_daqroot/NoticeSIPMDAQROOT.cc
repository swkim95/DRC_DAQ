#include "NoticeSIPMDAQROOT.h"
#include "NoticeSIPMDAQ.h"

ClassImp(NKSIPMDAQ)

NKSIPMDAQ::NKSIPMDAQ() {}

NKSIPMDAQ::~NKSIPMDAQ() {}

int NKSIPMDAQ::SIPMDAQopen(int sid)
{return ::SIPMDAQopen(sid);}

void NKSIPMDAQ::SIPMDAQclose(int sid)
{::SIPMDAQclose(sid);}

unsigned long NKSIPMDAQ::SIPMDAQread_DATASIZE(int sid)
{return ::SIPMDAQread_DATASIZE(sid);}

unsigned long NKSIPMDAQ::SIPMDAQread_FADC_DATASIZE(int sid)
{return ::SIPMDAQread_FADC_DATASIZE(sid);}

unsigned long NKSIPMDAQ::SIPMDAQread_RUN(int sid)
{return ::SIPMDAQread_RUN(sid);}

void NKSIPMDAQ::SIPMDAQread_DATA(int sid, unsigned long data_size, char *data)
{::SIPMDAQread_DATA(sid, data_size, data);}

void NKSIPMDAQ::SIPMDAQread_FADC_DATA(int sid, unsigned long data_size, char *data)
{::SIPMDAQread_FADC_DATA(sid, data_size, data);}


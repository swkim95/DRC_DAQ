#include "NoticeIBS_SIPM_DAQROOT.h"
#include "NoticeIBS_SIPM_DAQ.h"

ClassImp(NKIBS_SIPM_DAQ)

NKIBS_SIPM_DAQ::NKIBS_SIPM_DAQ()
{
}

NKIBS_SIPM_DAQ::~NKIBS_SIPM_DAQ()
{
}

int NKIBS_SIPM_DAQ::IBS_SIPM_DAQopen(void)
{return ::IBS_SIPM_DAQopen();}

void NKIBS_SIPM_DAQ::IBS_SIPM_DAQclose(int tcp_Handle)
{::IBS_SIPM_DAQclose(tcp_Handle);}

void NKIBS_SIPM_DAQ::IBS_SIPM_DAQreset(int tcp_Handle)
{::IBS_SIPM_DAQreset(tcp_Handle);}

void NKIBS_SIPM_DAQ::IBS_SIPM_DAQstart(int tcp_Handle)
{::IBS_SIPM_DAQstart(tcp_Handle);}

int NKIBS_SIPM_DAQ::IBS_SIPM_DAQread_RUN(int tcp_Handle)
{return ::IBS_SIPM_DAQread_RUN(tcp_Handle);}

int NKIBS_SIPM_DAQ::IBS_SIPM_DAQread_DATA(int tcp_Handle, unsigned short *data)
{return ::IBS_SIPM_DAQread_DATA(tcp_Handle, data);}

void NKIBS_SIPM_DAQ::IBS_SIPM_DAQread_MON(int tcp_Handle, int trig_mode, short *data)
{::IBS_SIPM_DAQread_MON(tcp_Handle, trig_mode, data);}

void NKIBS_SIPM_DAQ::IBS_SIPM_DAQwrite_HV(int tcp_Handle, float data)
{::IBS_SIPM_DAQwrite_HV(tcp_Handle, data);}

float NKIBS_SIPM_DAQ::IBS_SIPM_DAQread_HV(int tcp_Handle)
{return ::IBS_SIPM_DAQread_HV(tcp_Handle);}

void NKIBS_SIPM_DAQ::IBS_SIPM_DAQwrite_THR(int tcp_Handle, int data)
{::IBS_SIPM_DAQwrite_THR(tcp_Handle, data);}

int NKIBS_SIPM_DAQ::IBS_SIPM_DAQread_THR(int tcp_Handle)
{return ::IBS_SIPM_DAQread_THR(tcp_Handle);}

float NKIBS_SIPM_DAQ::IBS_SIPM_DAQread_TEMP(int tcp_Handle)
{return ::IBS_SIPM_DAQread_TEMP(tcp_Handle);}

int NKIBS_SIPM_DAQ::IBS_SIPM_DAQread_PED(int tcp_Handle)
{return ::IBS_SIPM_DAQread_PED(tcp_Handle);}



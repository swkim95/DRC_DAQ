#ifndef NKSIPMTCB_ROOT_H
#define NKSIPMTCB_ROOT_H

#include "TObject.h"

struct libusb_context;

class NKSIPMTCB : public TObject {
public:
	
  NKSIPMTCB();
  virtual ~NKSIPMTCB();
  void USB3Init(void);
  void USB3Exit(void);
  int SIPMTCBopen(int sid);
  void SIPMTCBclose(int sid);
  void SIPMTCBreset(int sid);
  void SIPMTCBstart_DAQ(int sid);
  void SIPMTCBstop_DAQ(int sid);
  void SIPMTCBsend_TRIG(int sid);
  unsigned long SIPMTCBread_RUN(int sid);
  void SIPMTCBwrite_FRAME(int sid, unsigned long data);
  unsigned long SIPMTCBread_FRAME(int sid);
  void SIPMTCBwrite_SCAN_TIME(int sid, unsigned long data);
  unsigned long SIPMTCBread_SCAN_TIME(int sid);
  void SIPMTCBwrite_TRIGGER_MODE(int sid, unsigned long data);
  unsigned long SIPMTCBread_TRIGGER_MODE(int sid);
  void SIPMTCBread_LINK(int sid, unsigned long *data);
  void SIPMTCBread_MID(int sid, unsigned long *data);
  unsigned long SIPMTCBread_DATASIZE(int sid);
  void SIPMTCBread_DATA(int sid, unsigned long data_size, char* data);
  void SIPMTCBwrite_HV(int sid, unsigned long mid, unsigned long ch, float data);
  float SIPMTCBread_HV(int sid, unsigned long mid, unsigned long ch);
  float SIPMTCBread_TEMP(int sid, unsigned long mid, unsigned long ch);
  unsigned long SIPMTCBread_PED(int sid, unsigned long mid, unsigned long ch);
  void SIPMTCBwrite_THR(int sid, unsigned long mid, unsigned long ch, unsigned long data);
  unsigned long SIPMTCBread_THR(int sid, unsigned long mid, unsigned long ch);
  void SIPMTCBwrite_PSW(int sid, unsigned long mid, unsigned long data);
  unsigned long SIPMTCBread_PSW(int sid, unsigned long mid);
  void SIPMTCBwrite_RISETIME(int sid, unsigned long mid, unsigned long data);
  unsigned long SIPMTCBread_RISETIME(int sid, unsigned long mid);
  void SIPMTCBwrite_PSD_DLY(int sid, unsigned long mid, unsigned long data);
  unsigned long SIPMTCBread_PSD_DLY(int sid, unsigned long mid);
  void SIPMTCBwrite_PSD_THR(int sid, unsigned long mid, unsigned long ch, float data);
  float SIPMTCBread_PSD_THR(int sid, unsigned long mid, unsigned long ch);
  void SIPMTCBalign_ADC(int sid, unsigned long mid);
  void SIPMTCBalign_DRAM(int sid, unsigned long mid);

  ClassDef(NKSIPMTCB, 0) // NKSIPMTCB wrapper class for root
};

#endif

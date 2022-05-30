#ifndef NKSIPMDAQ_ROOT_H
#define NKSIPMDAQ_ROOT_H

#include "TObject.h"

struct libusb_context;

class NKSIPMDAQ : public TObject {
public:
	
  NKSIPMDAQ();
  virtual ~NKSIPMDAQ();
  int SIPMDAQopen(int sid);
  void SIPMDAQclose(int sid);
  unsigned long SIPMDAQread_DATASIZE(int sid);
  unsigned long SIPMDAQread_FADC_DATASIZE(int sid);
  unsigned long SIPMDAQread_RUN(int sid);
  void SIPMDAQread_DATA(int sid, unsigned long data_size, char *data);
  void SIPMDAQread_FADC_DATA(int sid, unsigned long data_size, char *data);

  ClassDef(NKSIPMDAQ, 0) // NKSIPMDAQ wrapper class for root
};

#endif

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libusb.h>

#ifdef __cplusplus
extern "C" {
#endif

#define SIPMDAQ_VENDOR_ID  (0x0547)
#define SIPMDAQ_PRODUCT_ID (0x2012)

#define USB3_SF_READ   (0x82)
#define USB3_SF_WRITE  (0x06)

extern int SIPMDAQopen(int sid);
extern void SIPMDAQclose(int sid);
extern unsigned long SIPMDAQread_DATASIZE(int sid);
extern unsigned long SIPMDAQread_FADC_DATASIZE(int sid);
extern unsigned long SIPMDAQread_RUN(int sid);
extern void SIPMDAQread_DATA(int sid, unsigned long data_size, char *data);
extern void SIPMDAQread_FADC_DATA(int sid, unsigned long data_size, char *data);

#ifdef __cplusplus
}
#endif





#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libusb.h>

#ifdef __cplusplus
extern "C" {
#endif

#define CALDAQ_VENDOR_ID  (0x0547)
#define CALDAQ_PRODUCT_ID (0x2112)

#define USB3_SF_READ   (0x82)
#define USB3_SF_WRITE  (0x06)

extern int CALDAQopen(int sid);
extern void CALDAQclose(int sid);
extern unsigned long CALDAQread_DATASIZE(int sid);
extern unsigned long CALDAQread_RUN(int sid);
extern void CALDAQread_DATA(int sid, unsigned long data_size, char *data);

#ifdef __cplusplus
}
#endif





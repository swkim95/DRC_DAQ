#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libusb.h>

#ifdef __cplusplus
extern "C" {
#endif

#define KU_DRS_PROTO_VENDOR_ID  (0x0547)
#define KU_DRS_PROTO_PRODUCT_ID (0x2110)

#define USB3_SF_READ   (0x82)
#define USB3_SF_WRITE  (0x06)

extern int KU_DRS_PROTOopen(int sid);
extern void KU_DRS_PROTOclose(int sid);
extern void KU_DRS_PROTOread_DATA(int sid, int buf_cnt, char *data);
extern void KU_DRS_PROTOreset(int sid);
extern void KU_DRS_PROTOstart(int sid);
extern void KU_DRS_PROTOstop(int sid);
extern int KU_DRS_PROTOread_RUN(int sid);
extern int KU_DRS_PROTOread_DATASIZE(int sid);
extern void KU_DRS_PROTOwrite_TRIG_DLY(int sid, int data);
extern int KU_DRS_PROTOread_TRIG_DLY(int sid);
extern void KU_DRS_PROTOwrite_CALMODE(int sid, int data);
extern int KU_DRS_PROTOread_CALMODE(int sid);
extern void KU_DRS_PROTOsend_TRIG(int sid);

#ifdef __cplusplus
}
#endif


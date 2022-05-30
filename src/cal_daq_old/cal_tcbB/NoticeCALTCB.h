#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <libusb.h>

#ifdef __cplusplus
extern "C" {
#endif

#define CALTCB_VENDOR_ID  (0x0547)
#define CALTCB_PRODUCT_ID (0x1501)

#define USB3_SF_READ   (0x82)
#define USB3_SF_WRITE  (0x06)

extern void USB3Init(void);
extern void USB3Exit(void);
extern int CALTCBopen(int sid);
extern void CALTCBclose(int sid);
extern void CALTCBresetTIMER(int sid);
extern void CALTCBreset(int sid);
extern void CALTCBstart_DAQ(int sid);
extern void CALTCBstop_DAQ(int sid);
extern void CALTCBstart_DRS(int sid);
extern void CALTCBstop_DRS(int sid);
extern unsigned long CALTCBread_RUN(int sid, unsigned long mid);
extern void CALTCBread_LINK(int sid, unsigned long *data);
extern void CALTCBread_MID(int sid, unsigned long *data);
extern void CALTCBwrite_CW(int sid, unsigned long mid, unsigned long data);
extern unsigned long CALTCBread_CW(int sid, unsigned long mid);
extern void CALTCBwrite_RUN_NUMBER(int sid, unsigned long data);
extern unsigned long CALTCBread_RUN_NUMBER(int sid);
extern void CALTCBsend_TRIG(int sid);
extern void CALTCBwrite_PEDESTAL_TRIGGER_INTERVAL(int sid, unsigned long data);
extern unsigned long CALTCBread_PEDESTAL_TRIGGER_INTERVAL(int sid);
extern void CALTCBwrite_TRIGGER_ENABLE(int sid, unsigned long data);
extern unsigned long CALTCBread_TRIGGER_ENABLE(int sid);
extern void CALTCBwrite_MULTIPLICITY_THR(int sid, unsigned long mid, unsigned long data);
extern unsigned long CALTCBread_MULTIPLICITY_THR(int sid, unsigned long mid);
extern void CALTCBwrite_TRIGGER_DELAY(int sid, unsigned long data);
extern unsigned long CALTCBread_TRIGGER_DELAY(int sid);
extern void CALTCBwrite_HV(int sid, unsigned long mid, unsigned long ch, float data);
extern float CALTCBread_HV(int sid, unsigned long mid, unsigned long ch);
extern void CALTCBwrite_THR(int sid, unsigned long mid, unsigned long ch, unsigned long data);
extern unsigned long CALTCBread_THR(int sid, unsigned long mid, unsigned long ch);
extern float CALTCBread_TEMP(int sid, unsigned long mid);
extern unsigned long CALTCBread_DRS_PLL_LOCKED(int sid, unsigned long mid);
extern unsigned long CALTCBread_DRAMTEST(int sid, unsigned long mid, unsigned long ch);
extern void CALTCBwrite_DRS_CALIB(int sid, unsigned long mid, unsigned long data);
extern void CALTCBwrite_DRS_OFS(int sid, unsigned long mid, unsigned long ch, unsigned long rofs, unsigned long oofs);
extern void CALTCBwrite_ADC_SETUP(int sid, unsigned long mid, unsigned long addr, unsigned long data);
extern void CALTCBsetup_DRAM(int sid, unsigned long mid);
extern void CALTCBwrite_DRAMTEST(int sid, unsigned long mid, int data);
extern int CALTCBread_DRAM_ALIGN(int sid, unsigned long mid, int ch);
extern void CALTCBreset_REF_CLK(int sid, unsigned long mid);
extern void CALTCBwrite_DRAMDLY(int sid, unsigned long mid, int ch, int data);
extern void CALTCBwrite_DRAM_BITSLIP(int sid, unsigned long mid, int ch);
extern void CALTCBalign_DRAM(int sid, unsigned long mid);
extern int CALTCB_DRSinit(int sid, unsigned long mid);

#ifdef __cplusplus
}
#endif





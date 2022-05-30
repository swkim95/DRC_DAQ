#include "cyu3types.h"
#include "cyu3usbconst.h"
#include "cyu3externcstart.h"
#include "cyu3externcend.h"

#define myEP_PRODUCER               (0x06)
#define myEP_CONSUMER               (0x82)

#define myEP_PRODUCER_SOCKET        CY_U3P_UIB_SOCKET_PROD_6
#define myEP_CONSUMER_SOCKET        CY_U3P_UIB_SOCKET_CONS_2

#define myBURST_LENGTH           (16)

extern const uint8_t myUSB20DeviceDscr[];
extern const uint8_t myUSB30DeviceDscr[];
extern const uint8_t myUSBDeviceQualDscr[];
extern const uint8_t myUSBFSConfigDscr[];
extern const uint8_t myUSBHSConfigDscr[];
extern const uint8_t myUSBBOSDscr[];
extern const uint8_t myUSBSSConfigDscr[];
extern const uint8_t myUSBStringLangIDDscr[];
extern const uint8_t myUSBManufactureDscr[];
extern const uint8_t myUSBProductDscr[];


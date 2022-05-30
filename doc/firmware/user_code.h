#include "cyu3types.h"
#include "cyu3usbconst.h"
#include "description.h"

#define VENDOR_I2C_EEPROM_WRITE          (0xBA)
#define VENDOR_FLASH_WRITE               (0xC2)
#define VENDOR_FLASH_ERASE               (0xC4) 
#define VENDOR_FLASH_FINISH              (0xC5) 
#define VENDOR_READ_SID                  (0xD2)
#define VENDOR_WRITE_SID                 (0xD3)
#define VENDOR_READ_FPGA_VERSION         (0xD4)
#define VENDOR_WRITE_FPGA_VERSION        (0xD5)
#define VENDOR_RESET		         (0xD6)

CyBool_t myVendorRequest(uint8_t bRequest, uint16_t wValue, uint16_t wIndex, uint16_t wLength);
void myVendorReset(void);
void FLASHerase(uint8_t sector);
void FLASHfinish(void);
void FLASHwrite(uint8_t *buffer);
void FLASHwriteByte(uint8_t sector, uint8_t addrH, uint8_t addrL, uint8_t data);
uint8_t FLASHread(uint8_t sector, uint8_t addrH, uint8_t addrL);
void download_CAL(void);



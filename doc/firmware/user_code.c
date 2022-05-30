#include "cyu3system.h"
#include "cyu3os.h"
#include "cyu3dma.h"
#include "cyu3error.h"
#include "cyu3usb.h"
#include "cyu3i2c.h"
#include "cyu3gpio.h"
#include "cyu3spi.h"
#include "gpio_regs.h"
#include "peripheral.h"
#include "user_code.h"

#define FPGA_VERSION_SIZE     (100)
uint8_t glEp0Buffer[EP0_BUFF_SIZE] __attribute__ ((aligned (32)));

CyBool_t myVendorRequest(uint8_t bRequest, uint16_t wValue, uint16_t wIndex, uint16_t wLength) 
{
  CyU3PReturnStatus_t status = CY_U3P_SUCCESS;
  uint16_t i;

  switch (bRequest) {
    // EEPROM write
    case VENDOR_I2C_EEPROM_WRITE:
      status = CyU3PUsbGetEP0Data(wLength, glEp0Buffer, NULL);
      if (status == CY_U3P_SUCCESS) 
        status = i2cWrite(glEp0Buffer);
      break;

    case VENDOR_FLASH_ERASE:
      status = CyU3PUsbGetEP0Data(wLength, glEp0Buffer, NULL);
      if (status == CY_U3P_SUCCESS) 
        FLASHerase(glEp0Buffer[0]);
      break;
  
    case VENDOR_FLASH_FINISH:
      FLASHfinish();
      CyU3PUsbAckSetup();
      break;

    case VENDOR_FLASH_WRITE:
      status = CyU3PUsbGetEP0Data(wLength, glEp0Buffer, NULL);
      if (status == CY_U3P_SUCCESS) 
        FLASHwrite(glEp0Buffer);
      break;

    case VENDOR_WRITE_SID:
      status = CyU3PUsbGetEP0Data(wLength, glEp0Buffer, NULL);
      if (status == CY_U3P_SUCCESS) {
        FLASHerase(0);
        FLASHwriteByte(0, 0, 0, glEp0Buffer[0]);
        FLASHfinish();
      }
      break;

    case VENDOR_READ_SID:
      CyU3PMemSet(glEp0Buffer, 0, sizeof(glEp0Buffer));
      glEp0Buffer[0] = FLASHread(0, 0, 0);
      status = CyU3PUsbSendEP0Data(wLength, glEp0Buffer);
      break;

    case VENDOR_WRITE_FPGA_VERSION:
      status = CyU3PUsbGetEP0Data(wLength, glEp0Buffer, NULL);
      if (status == CY_U3P_SUCCESS) {
        FLASHerase(1);
        FLASHwriteByte(1, 0, 0, glEp0Buffer[0]);
        FLASHfinish();
      }
      break;

    case VENDOR_READ_FPGA_VERSION:
      CyU3PMemSet(glEp0Buffer, 0, sizeof(glEp0Buffer));
      for (i = 0; i < 256; i++)
        glEp0Buffer[i] = FLASHread(1, 0, i & 0xFF);
      status = CyU3PUsbSendEP0Data(wLength, glEp0Buffer);
      break;

    // reset module
    case VENDOR_RESET:
      CyU3PUsbAckSetup();
      myVendorReset();
      break;
	
    default:
      return CyFalse;
  }

  return status == CY_U3P_SUCCESS;
}

// user functions

// download DRS calibration LUT
void download_CAL(void)
{
  uint8_t data[4];
  uint16_t i;
  uint8_t j;
  uint8_t rdat;
  uint8_t send_bit;

  // reset LUT address
  SPIcommand(0x00);
  SPIcommand(0x42);

  // get 32 kbyte from sector 0x30 and send it
  data[0] = 0x03;
  data[1] = 0x30;
  data[2] = 0x00;
  data[3] = 0x00;
  SPIdata(4, data);

  data[0] = 0x00;
  for (i = 0; i < 32768; i++) {
    rdat = SPIdata(1, data);

    for (j = 0; j < 8; j++) {
      send_bit = (rdat >> (7 - j)) & 0x1;

      if (send_bit)
        CyU3PGpioSimpleSetValue(FPGA_MIDSDI, CyTrue);
      else
        CyU3PGpioSimpleSetValue(FPGA_MIDSDI, CyFalse);

      CyU3PGpioSimpleSetValue(FPGA_MIDSCK, CyTrue);
      CyU3PGpioSimpleSetValue(FPGA_MIDSCK, CyFalse);
    }
  }

  // select none
  SPIcommand(0x00);
}

// erase flash memory
void FLASHerase(uint8_t sector)
{
	  uint8_t stat;
  	  uint8_t wdat[19];
	  uint8_t i;

	  // write protect high
	  SPIcommand(0x20);

	  // enable flash memory
	  SPIcommand(0x60);

	  // write enable
	  wdat[0] = 0x06;
	  SPIdata(1, wdat);

	  // set configuration
	  wdat[0] = 0x01;
	  wdat[1] = 0x00;
	  wdat[1] = 0x80;
	  SPIdata(3, wdat);

	  // check flag
	  wdat[0] = 0x05;
	  wdat[1] = 0x00;
	  stat = 1;
	  while (stat)
	    stat = SPIdata(2, wdat) & 0x01;

	  // write enable
	  wdat[0] = 0x06;
	  SPIdata(1, wdat);

	  // unprotect sectors
	  wdat[0] = 0x42;
	  for (i = 0; i < 18; i++)
	    wdat[i + 1] = 0x00;
	  SPIdata(19, wdat);

	  // check flag
	  wdat[0] = 0x05;
	  wdat[1] = 0x00;
	  stat = 1;
	  while (stat)
	    stat = SPIdata(2, wdat) & 0x01;

	  // write enable
	  wdat[0] = 0x06;
	  SPIdata(1, wdat);

	  // erase sectors
	  wdat[0] = 0xD8;
	  wdat[1] = sector;
	  wdat[2] = 0x00;
	  wdat[3] = 0x00;
	  SPIdata(4, wdat);

	  // check flag
	  wdat[0] = 0x05;
	  wdat[1] = 0x00;
	  stat = 1;
	  while (stat)
	    stat = SPIdata(2, wdat) & 0x01;

	  // deselect
	  SPIcommand(0x00);
}

// finish flash memory
void FLASHfinish(void)
{
	  uint8_t stat;
	  uint8_t wdat[19];
	  uint8_t i;

	  // enable flash memory
	  SPIcommand(0x60);

	  // write enable
	  wdat[0] = 0x06;
	  SPIdata(1, wdat);

	  // protect sectors
	  wdat[0] = 0x42;
	  wdat[1] = 0x55;
	  wdat[2] = 0x55;
	  for (i = 0; i < 16; i++)
	    wdat[i + 3] = 0xFF;
	  SPIdata(19, wdat);

	  // check flag
	  wdat[0] = 0x05;
	  wdat[1] = 0x00;
	  stat = 1;
	  while (stat)
	    stat = SPIdata(2, wdat) & 0x01;

	  // write protect low
	  SPIcommand(0x00);
}

// write to flash memory
void FLASHwrite(uint8_t *buffer)
{
  uint8_t stat;
  uint8_t wdat[260];
  uint16_t i;

  // enable flash memory
  SPIcommand(0x60);

  // write enable
  wdat[0] = 0x06;
  SPIdata(1, wdat);

  // write flash memory
  wdat[0] = 0x02;
  wdat[1] = buffer[0];
  wdat[2] = buffer[1];
  wdat[3] = 0x00;
  for (i = 0; i < 256; i++)
    wdat[i + 4] = buffer[i + 2];
  SPIdata(260, wdat);

  // check flag
  wdat[0] = 0x05;
  wdat[1] = 0x00;
  stat = 1;
  while (stat)
    stat = SPIdata(2, wdat) & 0x01;

  // deselect
  SPIcommand(0x00);
}

// write a byte to flash memory
void FLASHwriteByte(uint8_t sector, uint8_t addrH, uint8_t addrL, uint8_t data)
{
  uint8_t stat;
  uint8_t wdat[260];
  uint16_t i;

  // enable flash memory
  SPIcommand(0x60);

  // write enable
  wdat[0] = 0x06;
  SPIdata(1, wdat);

  // write flash memory
  wdat[0] = 0x02;
  wdat[1] = sector;
  wdat[2] = addrH;
  wdat[3] = addrL;
  wdat[4] = data;
  for (i = 0; i < 255; i++)
    wdat[i + 5] = 0;
  SPIdata(260, wdat);

  // check flag
  wdat[0] = 0x05;
  wdat[1] = 0x00;
  stat = 1;
  while (stat)
    stat = SPIdata(2, wdat) & 0x01;

  // deselect
  SPIcommand(0x00);
}

// read a byte from flash memory
uint8_t FLASHread(uint8_t sector, uint8_t addrH, uint8_t addrL)
{
  uint8_t wdat[5];
  uint8_t rdat;

  // enable flash memory
  SPIcommand(0x40);

  // read flash memory
  wdat[0] = 0x03;
  wdat[1] = sector;
  wdat[2] = addrH;
  wdat[3] = addrL;
  wdat[4] = 0x00;
  rdat = SPIdata(5, wdat);

  // disable flash memory
  SPIcommand(0x00);

  return rdat;
}


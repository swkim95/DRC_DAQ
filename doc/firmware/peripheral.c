#include "cyu3system.h"
#include "cyu3os.h"
#include "cyu3dma.h"
#include "cyu3error.h"
#include "cyu3i2c.h"
#include "cyu3gpio.h"
#include "cyu3utils.h"
#include "gpio_regs.h"
#include "peripheral.h"
#include "user_code.h"

uint16_t glI2cPageSize = 0x40; /* I2C Page size to be used for transfers. */

CyU3PDmaChannel glI2cTxHandle; /* I2C Tx channel handle */
CyU3PDmaChannel glI2cRxHandle; /* I2C Rx channel handle */

// initialize GPIO
CyU3PReturnStatus_t initGPIO(void) 
{
  CyU3PReturnStatus_t status = CY_U3P_SUCCESS;
  CyU3PGpioClock_t gpioClock;

  gpioClock.fastClkDiv = 2;
  gpioClock.slowClkDiv = 0;
  gpioClock.simpleDiv = CY_U3P_GPIO_SIMPLE_DIV_BY_2;
  gpioClock.clkSrc = CY_U3P_SYS_CLK;
  gpioClock.halfDiv = 0;
  status = CyU3PGpioInit(&gpioClock, NULL);

  return status;
}

// initializing I2C
CyU3PReturnStatus_t i2cInit(void) {
  CyU3PI2cConfig_t i2cConfig;
  CyU3PDmaChannelConfig_t dmaConfig;
  CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

  // turn on I2C interface
  status = CyU3PI2cInit();
  if (status != CY_U3P_SUCCESS) 
    return status;

  // configure I2C
  CyU3PMemSet((uint8_t *) &i2cConfig, 0, sizeof(i2cConfig));
  i2cConfig.bitRate = 100000;
  i2cConfig.busTimeout = 0xFFFFFFFF;
  i2cConfig.dmaTimeout = 0xFFFF;
  i2cConfig.isDma = CyTrue;
  status = CyU3PI2cSetConfig(&i2cConfig, NULL);
  if (status != CY_U3P_SUCCESS) 
    return status;

  // configure I2C DMA
  CyU3PMemSet((uint8_t *) &dmaConfig, 0, sizeof(dmaConfig));
  dmaConfig.size = glI2cPageSize;
  dmaConfig.count = 0;
  dmaConfig.prodAvailCount = 0;
  dmaConfig.dmaMode = CY_U3P_DMA_MODE_BYTE;
  dmaConfig.prodHeader = 0;
  dmaConfig.prodFooter = 0;
  dmaConfig.consHeader = 0;
  dmaConfig.notification = 0;
  dmaConfig.cb = NULL;
  dmaConfig.prodSckId = CY_U3P_CPU_SOCKET_PROD;
  dmaConfig.consSckId = CY_U3P_LPP_SOCKET_I2C_CONS;
  status = CyU3PDmaChannelCreate(&glI2cTxHandle, CY_U3P_DMA_TYPE_MANUAL_OUT, &dmaConfig);
  if (status != CY_U3P_SUCCESS) 
    return status;

  dmaConfig.prodSckId = CY_U3P_LPP_SOCKET_I2C_PROD;
  dmaConfig.consSckId = CY_U3P_CPU_SOCKET_CONS;
  status = CyU3PDmaChannelCreate(&glI2cRxHandle, CY_U3P_DMA_TYPE_MANUAL_IN, &dmaConfig);

  return status;
}

// I2C write
CyU3PReturnStatus_t i2cWrite(uint8_t *buffer)
{
  CyU3PDmaBuffer_t buf_p;
  CyU3PI2cPreamble_t preamble;
  CyU3PReturnStatus_t status = CY_U3P_SUCCESS;
  uint8_t devaddr;
  uint8_t addrH;
  uint8_t addrL;
  uint8_t wdat[256];
  uint16_t i;

  if (buffer[0] == 1)  
    devaddr = 4;
  else if (buffer[0] == 2)  
    devaddr = 1;
  else if (buffer[0] == 3)  
    devaddr = 5;
  else
    devaddr = 0;

  addrH = buffer[1];
  for (i = 0; i < 256; i++)
    wdat[i] = buffer[i + 2];

  /* Update the buffer address and status. */
  buf_p.buffer = wdat;
  buf_p.status = 0;
        
  preamble.length = 3;
  preamble.buffer[0] = 0xA0 | ((devaddr & 0x07) << 1);
  preamble.buffer[1] = addrH;
  
  for (i = 0; i < 4; i++) {
    addrL = i << 6;
    preamble.buffer[2] = addrL;
    preamble.ctrlMask = 0x0000;
    buf_p.size = 64;
    buf_p.count = 64;
    status = CyU3PDmaChannelSetupSendBuffer(&glI2cTxHandle, &buf_p);
    if (status != CY_U3P_SUCCESS) 
      return status;

    status = CyU3PI2cSendCommand(&preamble, 64, 0);
    if (status != CY_U3P_SUCCESS) 
      return status;

    status = CyU3PDmaChannelWaitForCompletion(&glI2cTxHandle, 5000);
    if (status != CY_U3P_SUCCESS) 
      return status;

    /* Update the parameters */
    buf_p.buffer += 64;

    /* Need a delay between write operations. */
    CyU3PThreadSleep(10);
  }

  return CY_U3P_SUCCESS;
}

// reset I2C
void i2cReset(void) {
  CyU3PDmaChannelReset(&glI2cTxHandle);
  CyU3PDmaChannelReset(&glI2cRxHandle);
}

// initialize SPI
CyU3PReturnStatus_t spiInit(void) 
{
  CyU3PGpioSimpleConfig_t gpioConfig;
  CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;

  // Configure GPIO 53 as output(SPI_CLOCK)
  gpioConfig.outValue = CyFalse;
  gpioConfig.inputEn = CyFalse;
  gpioConfig.driveLowEn = CyTrue;
  gpioConfig.driveHighEn = CyTrue;
  gpioConfig.intrMode = CY_U3P_GPIO_NO_INTR;
  apiRetStatus = CyU3PGpioSetSimpleConfig(SPI_CLK, &gpioConfig);
  if (apiRetStatus != CY_U3P_SUCCESS) 
    return apiRetStatus;

  // Configure GPIO 54 as output(SPI_SSN) 
  gpioConfig.outValue = CyTrue;
  gpioConfig.inputEn = CyFalse;
  gpioConfig.driveLowEn = CyTrue;
  gpioConfig.driveHighEn = CyTrue;
  gpioConfig.intrMode = CY_U3P_GPIO_NO_INTR;
  apiRetStatus = CyU3PGpioSetSimpleConfig(SPI_SS, &gpioConfig);
  if (apiRetStatus != CY_U3P_SUCCESS) 
    return apiRetStatus;

  // Configure GPIO 55 as input(MISO) 
  gpioConfig.outValue = CyFalse;
  gpioConfig.inputEn = CyTrue;
  gpioConfig.driveLowEn = CyFalse;
  gpioConfig.driveHighEn = CyFalse;
  gpioConfig.intrMode = CY_U3P_GPIO_NO_INTR;
  apiRetStatus = CyU3PGpioSetSimpleConfig(SPI_MISO, &gpioConfig);
  if (apiRetStatus != CY_U3P_SUCCESS) 
    return apiRetStatus;

  // Configure GPIO 56 as output(MOSI) 
  gpioConfig.outValue = CyFalse;
  gpioConfig.inputEn = CyFalse;
  gpioConfig.driveLowEn = CyTrue;
  gpioConfig.driveHighEn = CyTrue;
  gpioConfig.intrMode = CY_U3P_GPIO_NO_INTR;
  apiRetStatus = CyU3PGpioSetSimpleConfig(SPI_MOSI, &gpioConfig);

  return apiRetStatus;
}

// SPI send command
uint8_t SPIcommand(uint8_t data)
{
  uvint32_t * regGPIO_SS = &GPIO->lpp_gpio_simple[SPI_SS];
  uvint32_t * regGPIO_CLK = &GPIO->lpp_gpio_simple[SPI_CLK];
  uvint32_t * regGPIO_MISO = &GPIO->lpp_gpio_simple[SPI_MISO];
  uvint32_t * regGPIO_MOSI = &GPIO->lpp_gpio_simple[SPI_MOSI];
  uint8_t i;
  uint8_t value;
  uint8_t rdat;
  uint8_t wdat;
  

  *regGPIO_SS &= ~CY_U3P_LPP_GPIO_OUT_VALUE;
  *regGPIO_MOSI &= ~CY_U3P_LPP_GPIO_OUT_VALUE;
  *regGPIO_CLK |= CY_U3P_LPP_GPIO_OUT_VALUE;
  *regGPIO_CLK &= ~CY_U3P_LPP_GPIO_OUT_VALUE;

  value = 0;  
  for (i = 0; i < 8; i++) {
    rdat = ((*regGPIO_MISO) & CY_U3P_LPP_GPIO_IN_VALUE) >> 1;
    value |= (rdat << (7 - i));

    wdat = (data >> (7 - i)) & 0x01;
    if (wdat) {
      *regGPIO_MOSI |= CY_U3P_LPP_GPIO_OUT_VALUE;
    } else {
      *regGPIO_MOSI &= ~CY_U3P_LPP_GPIO_OUT_VALUE;
    }
    
    *regGPIO_CLK |= CY_U3P_LPP_GPIO_OUT_VALUE;
    *regGPIO_CLK &= ~CY_U3P_LPP_GPIO_OUT_VALUE;
  }

  *regGPIO_SS |= CY_U3P_LPP_GPIO_OUT_VALUE;
  
  return value;
}

// SPI send data
uint8_t SPIdata(uint16_t byteCount, uint8_t *data)
{
  uvint32_t * regGPIO_SS = &GPIO->lpp_gpio_simple[SPI_SS];
  uvint32_t * regGPIO_CLK = &GPIO->lpp_gpio_simple[SPI_CLK];
  uvint32_t * regGPIO_MISO = &GPIO->lpp_gpio_simple[SPI_MISO];
  uvint32_t * regGPIO_MOSI = &GPIO->lpp_gpio_simple[SPI_MOSI];
  uint16_t n;
  uint8_t i;
  uint8_t value;
  uint8_t rdat;
  uint8_t wdat;
  
  *regGPIO_SS &= ~CY_U3P_LPP_GPIO_OUT_VALUE;
  *regGPIO_MOSI |= CY_U3P_LPP_GPIO_OUT_VALUE;
  *regGPIO_CLK |= CY_U3P_LPP_GPIO_OUT_VALUE;
  *regGPIO_CLK &= ~CY_U3P_LPP_GPIO_OUT_VALUE;

  for (n = 0; n < (byteCount - 1); n++) {
    for (i = 0; i < 8; i++) {
      wdat = (data[n] >> (7 - i)) & 0x01;
      if (wdat) {
        *regGPIO_MOSI |= CY_U3P_LPP_GPIO_OUT_VALUE;
      } else {
        *regGPIO_MOSI &= ~CY_U3P_LPP_GPIO_OUT_VALUE;
      }
    
      *regGPIO_CLK |= CY_U3P_LPP_GPIO_OUT_VALUE;
      *regGPIO_CLK &= ~CY_U3P_LPP_GPIO_OUT_VALUE;
    }
  }

  value = 0;  
  for (i = 0; i < 8; i++) {
    rdat = ((*regGPIO_MISO) & CY_U3P_LPP_GPIO_IN_VALUE) >> 1;
    value |= (rdat << (7 - i));

    wdat = (data[byteCount - 1] >> (7 - i)) & 0x01;
    if (wdat) {
      *regGPIO_MOSI |= CY_U3P_LPP_GPIO_OUT_VALUE;
    } else {
      *regGPIO_MOSI &= ~CY_U3P_LPP_GPIO_OUT_VALUE;
    }
    
    *regGPIO_CLK |= CY_U3P_LPP_GPIO_OUT_VALUE;
    *regGPIO_CLK &= ~CY_U3P_LPP_GPIO_OUT_VALUE;
  }

  *regGPIO_SS |= CY_U3P_LPP_GPIO_OUT_VALUE;

  return value;
}

// initialize FPGA
uint8_t fpgaInit(void) 
{
  CyU3PGpioSimpleConfig_t gpioConfig;
  uint8_t init;
  uint8_t downdone;
  uint8_t done;
  uint8_t sid[3];
  uint8_t j;
  uint8_t k;
  uint8_t send_bit;

  // Configure GPIO 25 FPGA_RESET as output
  gpioConfig.outValue    = CyFalse;
  gpioConfig.inputEn     = CyFalse;
  gpioConfig.driveLowEn  = CyTrue;
  gpioConfig.driveHighEn = CyTrue;
  gpioConfig.intrMode    = CY_U3P_GPIO_NO_INTR;
  CyU3PGpioSetSimpleConfig(FPGA_RESET, &gpioConfig);

  /* Configure GPIO 50 output(FPGA_MIDSCK) */
  gpioConfig.outValue = CyFalse;
  gpioConfig.inputEn = CyFalse;
  gpioConfig.driveLowEn = CyTrue;
  gpioConfig.driveHighEn = CyTrue;
  gpioConfig.intrMode = CY_U3P_GPIO_NO_INTR;
  CyU3PGpioSetSimpleConfig(FPGA_MIDSCK, &gpioConfig);

  /* Configure GPIO 51 output(FPGA_MIDSDI) */
  gpioConfig.outValue = CyFalse;
  gpioConfig.inputEn = CyFalse;
  gpioConfig.driveLowEn = CyTrue;
  gpioConfig.driveHighEn = CyTrue;
  gpioConfig.intrMode = CY_U3P_GPIO_NO_INTR;
  CyU3PGpioSetSimpleConfig(FPGA_MIDSDI, &gpioConfig);

  // set prog low
  SPIcommand(0x04);

  // set prog high
  SPIcommand(0x00);
  
  // wait INIT high
  init = 0;
  while (!init)
    init = SPIcommand(0x00) & 0x02;

  // start download
  SPIcommand(0x08);
  
  // wait for download
  downdone = 0;
  while (!downdone)
    downdone = SPIcommand(0x00) & 0x01;
  
  // check FPGA DONE
  done = SPIcommand(0x00) & 0x04;

  if (done)
	  download_CAL();

  // read SID
  sid[0] = 0xAA;
  sid[1] = FLASHread(0, 0, 0);
  sid[2] = 0xDC;

  for (j = 0; j < 3; j++) {
    for (k = 0; k < 8; k++) {
      send_bit = (sid[j] >> (7 - k)) & 0x1;

      if (send_bit)
        CyU3PGpioSimpleSetValue(FPGA_MIDSDI, CyTrue);
      else              
        CyU3PGpioSimpleSetValue(FPGA_MIDSDI, CyFalse);
            
        CyU3PGpioSimpleSetValue(FPGA_MIDSCK, CyTrue);
        CyU3PGpioSimpleSetValue(FPGA_MIDSCK, CyFalse);
    }
  }

  CyU3PGpioSimpleSetValue(FPGA_MIDSCK, CyTrue);
  CyU3PGpioSimpleSetValue(FPGA_MIDSCK, CyFalse);

  return done;
}

// start FPGA-USB function
CyU3PReturnStatus_t fpgaStart(void)
{
  CyU3PGpioSimpleSetValue(FPGA_RESET, CyTrue);

  return 0;
}

// stop FPGA-USB function
CyU3PReturnStatus_t fpgaStop(void)
{
  CyU3PGpioSimpleSetValue(FPGA_RESET, CyFalse);

  return 0;
}














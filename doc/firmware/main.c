#include "cyu3system.h"
#include "cyu3os.h"
#include "cyu3dma.h"
#include "cyu3error.h"
#include "cyu3usb.h"
#include "cyu3utils.h"
#include "cyu3gpif.h"
#include "cyu3pib.h"
#include "cyu3types.h"
#include "cyu3usbconst.h"
#include "pib_regs.h"
#include "gpio_regs.h"
#include "gpif2.h"
#include "description.h"
#include "peripheral.h"
#include "user_code.h"

CyU3PThread appThread; 
CyBool_t glIsApplnActive = CyFalse;
CyU3PDmaChannel glChHandleSlFifoUtoP; 
CyU3PDmaMultiChannel glChHandleSlFifoPtoU;

// function prototype
void appThread_Entry(uint32_t input);
CyU3PReturnStatus_t appInit();
CyBool_t myUSBSetupCB(uint32_t setupdat0, uint32_t setupdat1);
void myUSBEventCB(CyU3PUsbEventType_t evtype, uint16_t evdata);
CyBool_t myUSBLPMRqtCB(CyU3PUsbLinkPowerMode mode);

// main function
int main(void) 
{
  CyU3PIoMatrixConfig_t io_cfg;
  CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

  // set clock and initialize FX3
  CyU3PSysClockConfig_t clkCfg = {CyTrue, 2, 2, 2, CyFalse, CY_U3P_SYS_CLK};
  status = CyU3PDeviceInit(&clkCfg);
  if (status != CY_U3P_SUCCESS) 
    goto handle_fatal_error;

  // set cache  
  status = CyU3PDeviceCacheControl(CyTrue, CyFalse, CyFalse);
  if (status != CY_U3P_SUCCESS) 
    goto handle_fatal_error;

  // set GPIO
  io_cfg.isDQ32Bit = CyTrue;
  io_cfg.useUart = CyFalse;
  io_cfg.useI2C = CyTrue;
  io_cfg.useI2S = CyFalse;
  io_cfg.useSpi = CyFalse;
  io_cfg.lppMode = CY_U3P_IO_MATRIX_LPP_DEFAULT;
  io_cfg.gpioSimpleEn[0] = FPGA_SIMPLE_GPIO_L | SPI_SIMPLE_GPIO_L;
  io_cfg.gpioSimpleEn[1] = FPGA_SIMPLE_GPIO_H | SPI_SIMPLE_GPIO_H;
  io_cfg.gpioComplexEn[0] = 0;
  io_cfg.gpioComplexEn[1] = 0;
  status = CyU3PDeviceConfigureIOMatrix(&io_cfg);
  if (status != CY_U3P_SUCCESS) 
    goto handle_fatal_error;

  // run OS
  CyU3PKernelEntry();

  return 0;

  handle_fatal_error: while (1) {;}
}

// Application define function which creates the threads
void CyFxApplicationDefine(void) 
{
  void *ptr = NULL;
  uint32_t status = CY_U3P_SUCCESS;
  
  ptr = CyU3PMemAlloc(0x4000);
  
  status = CyU3PThreadCreate(&appThread, "21:AppThread", appThread_Entry, 0, ptr, 0x4000, 8, 8, CYU3P_NO_TIME_SLICE, CYU3P_AUTO_START);

  if (status != 0) {
    while (1) {;}
  }
}

// Thread entry function
void appThread_Entry(uint32_t input) {
  // initialize routine
  appInit();

  // infinite loop
  while (1) {;}
//    CyU3PThreadSleep(1000);
}

// Initialize routine
CyU3PReturnStatus_t appInit() {
  CyU3PReturnStatus_t status = CY_U3P_SUCCESS;

  // initialize GPIO
  initGPIO();

  // initialize I2C
  i2cInit();

  // initialize SPI
  spiInit();

  // initialize FPGA
  fpgaInit();

  // initialize slaveFIFO
  fifoInit();

  // start USB
  status = CyU3PUsbStart();
  if (status != CY_U3P_SUCCESS) 
    return status;

  // register USB setup interrupt routine
  CyU3PUsbRegisterSetupCallback(myUSBSetupCB, CyTrue);

  // register USB event interrupt routine
  CyU3PUsbRegisterEventCallback(myUSBEventCB);

  // register USB power interrupt routine
  CyU3PUsbRegisterLPMRequestCallback(myUSBLPMRqtCB);

  // set USB device descriptor
  status = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_DEVICE_DESCR, 0, (uint8_t *) myUSB30DeviceDscr);
  status = CyU3PUsbSetDesc(CY_U3P_USB_SET_HS_DEVICE_DESCR, 0, (uint8_t *) myUSB20DeviceDscr);
  status = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_BOS_DESCR, 0, (uint8_t *) myUSBBOSDscr);
  status = CyU3PUsbSetDesc(CY_U3P_USB_SET_DEVQUAL_DESCR, 0, (uint8_t *) myUSBDeviceQualDscr);
  status = CyU3PUsbSetDesc(CY_U3P_USB_SET_SS_CONFIG_DESCR, 0, (uint8_t *) myUSBSSConfigDscr);
  status = CyU3PUsbSetDesc(CY_U3P_USB_SET_HS_CONFIG_DESCR, 0, (uint8_t *) myUSBHSConfigDscr);
  status = CyU3PUsbSetDesc(CY_U3P_USB_SET_FS_CONFIG_DESCR, 0, (uint8_t *) myUSBFSConfigDscr);
  status = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 0, (uint8_t *) myUSBStringLangIDDscr);
  status = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 1, (uint8_t *) myUSBManufactureDscr);
  status = CyU3PUsbSetDesc(CY_U3P_USB_SET_STRING_DESCR, 2, (uint8_t *) myUSBProductDscr);

  // connect as USB3
  status = CyU3PConnectState(CyTrue, CyTrue);

  return status;
}

// routine deals with setup packet
CyBool_t myUSBSetupCB(uint32_t setupdat0, uint32_t setupdat1) 
{
  uint8_t bRequest, bReqType;
  uint8_t bType, bTarget;
  uint16_t wValue, wIndex, wLength;
  CyBool_t isHandled = CyFalse;

  // get USB reuqest variables
  bReqType = (setupdat0 & CY_U3P_USB_REQUEST_TYPE_MASK);
  bType = (bReqType & CY_U3P_USB_TYPE_MASK);
  bTarget = (bReqType & CY_U3P_USB_TARGET_MASK);
  bRequest = ((setupdat0 & CY_U3P_USB_REQUEST_MASK) >> CY_U3P_USB_REQUEST_POS);
  wValue = ((setupdat0 & CY_U3P_USB_VALUE_MASK) >> CY_U3P_USB_VALUE_POS);
  wIndex = ((setupdat1 & CY_U3P_USB_INDEX_MASK) >> CY_U3P_USB_INDEX_POS);
  wLength = ((setupdat1 & CY_U3P_USB_LENGTH_MASK) >> CY_U3P_USB_LENGTH_POS);

  // for set or clear feature command, just send ACK 
  if (bType == CY_U3P_USB_STANDARD_RQT) {
    if ((bTarget == CY_U3P_USB_TARGET_INTF)
     && ((bRequest == CY_U3P_USB_SC_SET_FEATURE) || (bRequest == CY_U3P_USB_SC_CLEAR_FEATURE))
     && (wValue == 0)) {
      if (glIsApplnActive) 
        CyU3PUsbAckSetup();
      else
        CyU3PUsbStall(0, CyTrue, CyFalse);

      isHandled = CyTrue;
    }

    // for endpoint clear command, clear end points
    if ((bTarget == CY_U3P_USB_TARGET_ENDPT)
     && (bRequest == CY_U3P_USB_SC_CLEAR_FEATURE)
     && (wValue == CY_U3P_USBX_FS_EP_HALT)) {
      if (glIsApplnActive) {
        isHandled = fifoClear(wValue, wIndex);
  	return isHandled;
      }
    }
  }
  
  // for vendor specific request
  if (bType == CY_U3P_USB_VENDOR_RQT) 
    isHandled = myVendorRequest(bRequest, wValue, wIndex, wLength);

  return isHandled;
}

// routine deals with USB events
void myUSBEventCB(CyU3PUsbEventType_t evtype, uint16_t evdata) 
{
  switch (evtype) {
    // for set config command, start FPGA and FIFO
    // if they are already started, stop and restart them
    case CY_U3P_USB_EVENT_SETCONF:
      if (glIsApplnActive) {
        fpgaStop();
        fifoStop();
	i2cReset();
      }

      fifoStart();
      fpgaStart();
      glIsApplnActive = CyTrue;
      break;

    // for reset or disconnect commands, stop FPGA and FIFO        
    case CY_U3P_USB_EVENT_RESET:
    case CY_U3P_USB_EVENT_DISCONNECT:
      if (glIsApplnActive) {
        fpgaStop();
        fifoStop();
 	i2cReset();
	glIsApplnActive = CyFalse;
      }
      break;

    default:
      break;
  }
}

// routine deals with USB power management
CyBool_t myUSBLPMRqtCB(CyU3PUsbLinkPowerMode link_mode) 
{
  return CyTrue;
}

// initialize SlaveFIFO
CyU3PReturnStatus_t fifoInit(void) 
{
  CyU3PPibClock_t pibClock;
  CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;

  pibClock.clkDiv = 2;
  pibClock.clkSrc = CY_U3P_SYS_CLK;
  pibClock.isHalfDiv = CyFalse;
  pibClock.isDllEnable = CyFalse;
  CyU3PPibInit(CyTrue, &pibClock);

  CyU3PGpifLoad(&myGpifConfig);

  CyU3PGpifSMStart(myFIFO_RESET, myFIFO_ALPHA_RESET);
  
  return apiRetStatus;
}

CyU3PReturnStatus_t fifoStart(void) 
{
  uint16_t size = 0;
  CyU3PEpConfig_t epCfg;
  CyU3PDmaChannelConfig_t dmaCfg;
  CyU3PDmaMultiChannelConfig_t dmaMultiChannelCfg;
  CyU3PReturnStatus_t apiRetStatus = CY_U3P_SUCCESS;
  CyU3PUSBSpeed_t usbSpeed;

  // get USB speed
  usbSpeed = CyU3PUsbGetSpeed();
  switch (usbSpeed) {
    case CY_U3P_FULL_SPEED:
      size = 64;
      break;
    case CY_U3P_HIGH_SPEED:
      size = 512;
      break;
    case CY_U3P_SUPER_SPEED:
      size = 1024;
      break;
    default:
      break;
  }

  // configure OUT endpoint
  CyU3PMemSet((uint8_t *) &epCfg, 0, sizeof(epCfg));
  epCfg.enable = CyTrue;
  epCfg.epType = CY_U3P_USB_EP_BULK;
  epCfg.burstLen = 1;
  epCfg.streams = 0;
  epCfg.pcktSize = size;
  apiRetStatus = CyU3PSetEpConfig(myEP_PRODUCER, &epCfg);
  
  // configure IN endpoint
  epCfg.burstLen = myBURST_LENGTH;
  apiRetStatus = CyU3PSetEpConfig(myEP_CONSUMER, &epCfg);

  // configure USB write DMA channel
  dmaCfg.size = size;
  dmaCfg.count = 1;
  dmaCfg.prodSckId = myEP_PRODUCER_SOCKET;
  dmaCfg.consSckId = CY_U3P_PIB_SOCKET_3;
  dmaCfg.dmaMode = CY_U3P_DMA_MODE_BYTE;
  dmaCfg.notification = CY_U3P_DMA_CB_PROD_EVENT;
  dmaCfg.cb = myUSBwriteEP6;
  dmaCfg.prodHeader = 0;
  dmaCfg.prodFooter = 0;
  dmaCfg.consHeader = 0;
  dmaCfg.prodAvailCount = 0;
  apiRetStatus = CyU3PDmaChannelCreate(&glChHandleSlFifoUtoP, CY_U3P_DMA_TYPE_MANUAL, &dmaCfg);

  // configure USB read DMA channel
  dmaMultiChannelCfg.size = size * myBURST_LENGTH;
  dmaMultiChannelCfg.count = 1;
  dmaMultiChannelCfg.validSckCount = 2;
  dmaMultiChannelCfg.prodSckId[0] = CY_U3P_PIB_SOCKET_0;
  dmaMultiChannelCfg.prodSckId[1] = CY_U3P_PIB_SOCKET_1;
  dmaMultiChannelCfg.consSckId[0] = myEP_CONSUMER_SOCKET;
  dmaMultiChannelCfg.dmaMode = CY_U3P_DMA_MODE_BYTE;
  dmaMultiChannelCfg.notification = 0;
  dmaMultiChannelCfg.cb = NULL;
  dmaMultiChannelCfg.prodHeader = 0;
  dmaMultiChannelCfg.prodFooter = 0;
  dmaMultiChannelCfg.consHeader = 0;
  dmaMultiChannelCfg.prodAvailCount = 0;
  apiRetStatus = CyU3PDmaMultiChannelCreate(&glChHandleSlFifoPtoU, CY_U3P_DMA_TYPE_AUTO_MANY_TO_ONE, &dmaMultiChannelCfg);

  CyU3PDmaChannelReset(&glChHandleSlFifoUtoP);
  CyU3PDmaMultiChannelReset(&glChHandleSlFifoPtoU);

  // set transfer size
  apiRetStatus = CyU3PDmaChannelSetXfer(&glChHandleSlFifoUtoP, 0);
  apiRetStatus = CyU3PDmaMultiChannelSetXfer(&glChHandleSlFifoPtoU, 0, 0);
  apiRetStatus = CyU3PDmaMultiChannelSetXfer(&glChHandleSlFifoPtoU, 0, 1);

  // flush endpoints buffer is here
  CyU3PUsbFlushEp(myEP_PRODUCER);
  CyU3PUsbFlushEp(myEP_CONSUMER);

  CyU3PUsbResetEp(myEP_PRODUCER);
  CyU3PUsbResetEp(myEP_CONSUMER);

  return apiRetStatus;
}

void fifoStop(void) 
{
  CyU3PEpConfig_t epCfg;

  CyU3PMemSet((uint8_t *)&epCfg, 0, sizeof (epCfg));
  epCfg.enable = CyFalse;

  CyU3PUsbFlushEp(myEP_PRODUCER);
  CyU3PUsbFlushEp(myEP_CONSUMER);

  CyU3PDmaChannelDestroy(&glChHandleSlFifoUtoP);
  CyU3PDmaMultiChannelDestroy(&glChHandleSlFifoPtoU);

  CyU3PSetEpConfig(myEP_PRODUCER, &epCfg);
  CyU3PSetEpConfig(myEP_CONSUMER, &epCfg);
}

// USB write 
void myUSBwriteEP6(CyU3PDmaChannel *chHandle, CyU3PDmaCbType_t type, CyU3PDmaCBInput_t *input) 
{
  if (type == CY_U3P_DMA_CB_PROD_EVENT) {
    CyU3PDmaMultiChannelReset(&glChHandleSlFifoPtoU);
    CyU3PDmaMultiChannelSetXfer(&glChHandleSlFifoPtoU, 0, 0);
    CyU3PDmaMultiChannelSetXfer(&glChHandleSlFifoPtoU, 0, 1);
//    CyU3PUsbFlushEp(myCONSUMER);
//    CyU3PUsbResetEp(myEP_CONSUMER);
    CyU3PDmaChannelCommitBuffer(chHandle, input->buffer_p.count, 0);
  }
}


CyBool_t fifoClear(uint16_t wValue, uint16_t wIndex) 
{
  if (wIndex == myEP_PRODUCER) {
    CyU3PDmaChannelReset(&glChHandleSlFifoUtoP);
    CyU3PDmaChannelSetXfer(&glChHandleSlFifoUtoP, 0);
    CyU3PUsbStall(wIndex, CyFalse, CyTrue);
    CyU3PUsbFlushEp(myEP_PRODUCER);
    CyU3PUsbResetEp(myEP_PRODUCER);
    return CyTrue;
  }

  if (wIndex == myEP_CONSUMER) {
    CyU3PDmaMultiChannelReset(&glChHandleSlFifoPtoU);
    CyU3PDmaMultiChannelSetXfer(&glChHandleSlFifoPtoU, 0, 0);
    CyU3PDmaMultiChannelSetXfer(&glChHandleSlFifoPtoU, 0, 1);
    CyU3PUsbStall(wIndex, CyFalse, CyTrue);
    CyU3PUsbFlushEp(myEP_CONSUMER);
    CyU3PUsbResetEp(myEP_CONSUMER);
    return CyTrue;
  }

  return CyFalse;
}

void myVendorReset(void)
{
  fpgaStop();
  fpgaStart();
}

















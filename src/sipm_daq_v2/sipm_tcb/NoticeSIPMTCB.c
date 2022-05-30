#include "NoticeSIPMTCB.h"

enum EManipInterface {kInterfaceClaim, kInterfaceRelease};

struct dev_open {
   libusb_device_handle *devh;
   uint16_t vendor_id;
   uint16_t product_id;
   int serial_id;
   struct dev_open *next;
} *ldev_open = 0;

// internal functions *********************************************************************************
static int is_device_open(libusb_device_handle *devh);
static unsigned char get_serial_id(libusb_device_handle *devh);
static void add_device(struct dev_open **list, libusb_device_handle *tobeadded,
                       uint16_t vendor_id, uint16_t product_id, int sid);
static int handle_interface_id(struct dev_open **list, uint16_t vendor_id, uint16_t product_id,
                               int sid, int interface, enum EManipInterface manip_type);
static void remove_device_id(struct dev_open **list, uint16_t vendor_id, uint16_t product_id, int sid);
libusb_device_handle* nkusb_get_device_handle(uint16_t vendor_id, uint16_t product_id, int sid);
int TCBWrite(int sid, uint32_t mid, uint32_t addr, uint32_t data);
int TCBRead(int sid, uint32_t mid, uint32_t count, uint32_t addr, unsigned char *data);
unsigned int TCBReadReg(int sid, uint32_t mid, uint32_t addr);
void SIPMTCBsetup_DRAM(int sid, unsigned long mid);
int SIPMTCBread_ADC_BIT_ALIGN(int sid, unsigned long mid, int ch);
int SIPMTCBread_ADC_WORD_ALIGN(int sid, unsigned long mid, int ch);
void SIPMTCBwrite_DRAM_TEST(int sid, unsigned long mid, int data);
int SIPMTCBread_DRAM_ALIGN(int sid, unsigned long mid, int ch);
void SIPMTCBreset_REF_CLK(int sid, unsigned long mid);
void SIPMTCBreset_ADC(int sid, unsigned long mid);
void SIPMTCBsetup_ADC(int sid, unsigned long mid, int addr, int data);
void SIPMTCBwrite_ADC_DLY(int sid, unsigned long mid, int ch, int data);
void SIPMTCBwrite_ADC_BITSLIP(int sid, unsigned long mid, int ch, int data);
void SIPMTCBwrite_DRAM_DLY(int sid, unsigned long mid, int ch, int data);
void SIPMTCBwrite_DRAM_BITSLIP(int sid, unsigned long mid, int ch);

static int is_device_open(libusb_device_handle *devh)
{
// See if the device handle "devh" is on the open device list

  struct dev_open *curr = ldev_open;
  libusb_device *dev, *dev_curr;
  int bus, bus_curr, addr, addr_curr;

  while (curr) {
    dev_curr = libusb_get_device(curr->devh);
    bus_curr = libusb_get_bus_number(dev_curr);
    addr_curr = libusb_get_device_address(dev_curr);

    dev = libusb_get_device(devh);
    bus = libusb_get_bus_number(dev);
    addr = libusb_get_device_address(dev);

    if (bus == bus_curr && addr == addr_curr) return 1;
    curr = curr->next;
  }

  return 0;
}

static unsigned char get_serial_id(libusb_device_handle *devh)
{
// Get serial id of device handle devh. devh may or may not be on open device list 'ldev_open'.
// Returns 0 if error.
  int ret;
  if (!devh) {
    return 0;
  }
  unsigned char data[1];
  ret = libusb_control_transfer(devh, LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_ENDPOINT_IN, 0xD2, 0, 0, data, 1, 1000);

  if (ret < 0) {
    fprintf(stdout, "Warning: get_serial_id: Could not get serial id.\n");
    return 0;
  }

  return data[0];
}

static void add_device(struct dev_open **list, libusb_device_handle *tobeadded,
                       uint16_t vendor_id, uint16_t product_id, int sid)
{
// Add device to the open device list

  struct dev_open *curr;

  curr = (struct dev_open *)malloc(sizeof(struct dev_open));
  curr->devh = tobeadded;
  curr->vendor_id = vendor_id;
  curr->product_id = product_id;
  curr->serial_id = sid;
  curr->next  = *list;
  *list = curr;
}

static int handle_interface_id(struct dev_open **list, uint16_t vendor_id, uint16_t product_id,
                               int sid, int interface, enum EManipInterface manip_type)
{
// Manipulate interface on the device with specified vendor id, product id and serial id
// from open device list. Claim interface if manip_type == kInterfaceClaim, release interface
// if manip_type == kInterfaceRelease. If sid == NK_SID_ANY, all devices with given vendor id
// and product id are handled.

  int ret = 0;
  if (!*list) {
    ret = -1;
    return ret;
  }

  struct dev_open *curr = *list;
  struct libusb_device_descriptor desc;
  libusb_device *dev;

  while (curr) {
    dev =libusb_get_device(curr->devh);
    if (libusb_get_device_descriptor(dev, &desc) < 0) {
      // Ignore with message
      fprintf(stdout, "Warning: remove_device: could not get device device descriptior."
                          " Ignoring.\n");
      continue;
    }
    if (desc.idVendor == vendor_id && desc.idProduct == product_id
    && (sid == 0xFF || sid == get_serial_id(curr->devh))) { 
      // Match.
      if (manip_type == kInterfaceClaim) {
        if ((ret = libusb_claim_interface(curr->devh, interface)) < 0) {
          fprintf(stdout, "Warning: handle_interface_id: Could not claim interface (%d) on device (%u, %u, %u)\n",
                  interface, vendor_id, product_id, 
sid);
        }
      }
      else if (manip_type == kInterfaceRelease) {
        if ((ret =libusb_release_interface(curr->devh, interface)) < 0) {
          fprintf(stdout, "Warning: handle_interface_id: Could not release interface (%d) on device (%u, %u, %u)\n",
                  interface, vendor_id, product_id, sid);
        }
      }
      else {
        fprintf(stderr, "Error: handle_interface_id: Unknown interface handle request: %d\n.",
                manip_type);
              
        ret = -1;
        return ret;
      }
    }
    // Move forward
    curr = curr->next;
  }

  return ret;
}

static void remove_device_id(struct dev_open **list, uint16_t vendor_id, uint16_t product_id, int sid)
{
// Close and remove device with specified vendor id, product id and serial id
// from open device list. If sid == NK_SID_ANY, all devices with given vendor id
// and product id are removed.

  if (!*list) return;

  struct dev_open *curr = *list;
  struct dev_open *prev = 0;
  struct libusb_device_descriptor desc;
  libusb_device *dev;

  while (curr) {
    dev =libusb_get_device(curr->devh);
    if (libusb_get_device_descriptor(dev, &desc) < 0) {
      // Ignore with message
      fprintf(stdout, "Warning, remove_device: could not get device device descriptior." " Ignoring.\n");
      continue;
    }
    if (desc.idVendor == vendor_id && desc.idProduct == product_id
    && (sid == 0xFF || sid == get_serial_id(curr->devh))) { 
      // Match.
      if (*list == curr) { 
        // Update head, remove current element and move cursor forward.
        *list = curr->next;
        libusb_close(curr->devh);
        free(curr); 
        curr = *list;
      }
      else {
        // Update link, remove current element and move cursor forward.
        prev->next = curr->next;
        libusb_close(curr->devh);
        free(curr); 
        curr = prev->next;
      }
    }
    else {
      // No match. Move cursor forward.
      prev = curr;
      curr = curr->next;
    }    
  }
}

libusb_device_handle* nkusb_get_device_handle(uint16_t vendor_id, uint16_t product_id, int sid) 
{
// Get open device handle with given vendor id, product id and serial id.
// Return first found device handle if sid == NK_SID_ANY.

  struct dev_open *curr = ldev_open;
  while (curr) {
    if (curr->vendor_id == vendor_id && curr->product_id == product_id) {
      if (sid == 0xFF)
        return curr->devh;
      else if (curr->serial_id == sid)
        return curr->devh;
    }

    curr = curr->next;
  }

  return 0;
}

int TCBWrite(int sid, uint32_t mid, uint32_t addr, uint32_t data)
{
  int transferred = 0;  
  const unsigned int timeout = 1000;
  //int length = 8;
  int length = 12;
  unsigned char *buffer;
  int stat = 0;
  
  if (!(buffer = (unsigned char *)malloc(length))) {
    fprintf(stderr, "TCBWrite: Could not allocate memory (size = %d\n)", length);
    return -1;
  }
  
  buffer[0] = data & 0xFF;
  buffer[1] = (data >> 8)  & 0xFF;
  buffer[2] = (data >> 16)  & 0xFF;
  buffer[3] = (data >> 24)  & 0xFF;
  
  buffer[4] = addr & 0xFF;
  buffer[5] = (addr >> 8)  & 0xFF;
  buffer[6] = (addr >> 16)  & 0xFF;
  buffer[7] = (addr >> 24)  & 0x7F;

  buffer[8] = mid & 0xFF;
  buffer[9] = (mid >> 8) & 0xFF;
  buffer[10] = (mid >> 16) & 0xFF;
  buffer[11] = (mid >> 24) & 0xFF;
  
  libusb_device_handle *devh = nkusb_get_device_handle(SIPMTCB_VENDOR_ID, SIPMTCB_PRODUCT_ID, sid);
  if (!devh) {
    fprintf(stderr, "TCBWrite: Could not get device handle for the device.\n");
    return -1;
  }
  
  if ((stat = libusb_bulk_transfer(devh, USB3_SF_WRITE, buffer, length, &transferred, timeout)) < 0) {
    fprintf(stderr, "TCBWrite: Could not make write request; error = %d\n", stat);
    free(buffer);
    return stat;
  }
  
  free(buffer);

  usleep(1000);

  return stat;
}

int TCBRead(int sid, uint32_t mid, uint32_t count, uint32_t addr, unsigned char *data)
{
  const unsigned int timeout = 1000; // Wait forever
  //int length = 8;
  int length = 12;
  int transferred;
  unsigned char *buffer;
  int stat = 0;
  int nbulk;
  int remains;
  int loop;
  int size = 16384; // 16 kB

  nbulk = count / 4096;
  remains = count % 4096;

  if (!(buffer = (unsigned char *)malloc(size))) {
    fprintf(stderr, "TCBRead: Could not allocate memory (size = %d\n)", size);
    return -1;
  }
  
  buffer[0] = count & 0xFF;
  buffer[1] = (count >> 8)  & 0xFF;
  buffer[2] = (count >> 16)  & 0xFF;
  buffer[3] = (count >> 24)  & 0xFF;
  
  buffer[4] = addr & 0xFF;
  buffer[5] = (addr >> 8)  & 0xFF;
  buffer[6] = (addr >> 16)  & 0xFF;
  buffer[7] = (addr >> 24)  & 0x7F;
  buffer[7] = buffer[7] | 0x80;

  buffer[8] = mid & 0xFF;
  buffer[9] = (mid >> 8) & 0xFF;
  buffer[10] = (mid >> 16) & 0xFF;
  buffer[11] = (mid >> 24) & 0xFF;

  libusb_device_handle *devh = nkusb_get_device_handle(SIPMTCB_VENDOR_ID, SIPMTCB_PRODUCT_ID, sid);
  if (!devh) {
    fprintf(stderr, "TCBRead: Could not get device handle for the device.\n");
    return -1;
  }

  if ((stat = libusb_bulk_transfer(devh, USB3_SF_WRITE, buffer, length, &transferred, timeout)) < 0) {
    fprintf(stderr, "TCBRead: Could not make write request; error = %d\n", stat);
    free(buffer);
    return stat;
  }

  for (loop = 0; loop < nbulk; loop++) {
    if ((stat = libusb_bulk_transfer(devh, USB3_SF_READ, buffer, size, &transferred, timeout)) < 0) {
      fprintf(stderr, "TCBRead: Could not make read request; error = %d\n", stat);
      return 1;
    }
    memcpy(data + loop * size, buffer, size);
  }

  if (remains) {
    if ((stat = libusb_bulk_transfer(devh, USB3_SF_READ, buffer, remains * 4, &transferred, timeout)) < 0) {
      fprintf(stderr, "TCBRead: Could not make read request; error = %d\n", stat);
      return 1;
    }

    memcpy(data + nbulk * size, buffer, remains * 4);
  }

  free(buffer);
  
  return 0;
}

unsigned int TCBReadReg(int sid, uint32_t mid, uint32_t addr)
{
  unsigned char data[4];
  unsigned int value;
  unsigned int tmp;

  TCBRead(sid, mid, 1, addr, data);

  value = data[0] & 0xFF;
  tmp = data[1] & 0xFF;
  value = value + (unsigned int)(tmp << 8);
  tmp = data[2] & 0xFF;
  value = value + (unsigned int)(tmp << 16);
  tmp = data[3] & 0xFF;
  value = value + (unsigned int)(tmp << 24);

  return value;
}  

// turn on DRAM
void SIPMTCBsetup_DRAM(int sid, unsigned long mid)
{
  unsigned long status;

  // check DRAM is on
  status = TCBReadReg(sid, mid, 0x20000001);
  
  // when DRAM is on now, turn it off
  if (status) 
    TCBWrite(sid, mid, 0x20000001, 0);

  // turn on DRAM
  TCBWrite(sid, mid, 0x20000001, 1);

  // wait for DRAM ready
  status = 0;
  while (!status) 
    status = TCBReadReg(sid, mid, 0x20000001);
}

// read ADC bit alignment
int SIPMTCBread_ADC_BIT_ALIGN(int sid, unsigned long mid, int ch)
{
  int data;
  int value;

  data = TCBReadReg(sid, mid, 0x2000000A);
  value = (data >> (ch - 1)) & 0x1;
  
  return value;
}

// read ADC word alignment
int SIPMTCBread_ADC_WORD_ALIGN(int sid, unsigned long mid, int ch)
{
  int data;
  int value;

  data = TCBReadReg(sid, mid, 0x2000000B);
  value = (data >> (ch - 1)) & 0x1;

  return value;
}

// write DRAM test mode
void SIPMTCBwrite_DRAM_TEST(int sid, unsigned long mid, int data)
{
  TCBWrite(sid, mid, 0x2000000C, data);
}

// read DRAM alignment
int SIPMTCBread_DRAM_ALIGN(int sid, unsigned long mid, int ch)
{
  int addr;

  addr = 0x2000000C + ((ch & 0xFF) << 16);
  return TCBReadReg(sid, mid, addr);
}

// reset delay reference clock
void SIPMTCBreset_REF_CLK(int sid, unsigned long mid)
{
  TCBWrite(sid, mid, 0x20000010, 0);
}

// reset ADC
void SIPMTCBreset_ADC(int sid, unsigned long mid)
{
  TCBWrite(sid, mid, 0x20000011, 0);
}

// setup ADC
void SIPMTCBsetup_ADC(int sid, unsigned long mid, int addr, int data)
{
  int value;

  value = (addr << 8) | (data & 0xFF);
  TCBWrite(sid, mid, 0x20000012, value);
}

// write ADC input delay
void SIPMTCBwrite_ADC_DLY(int sid, unsigned long mid, int ch, int data)
{

  int addr;

  addr = 0x20000013 + (((ch - 1) & 0xFF) << 16);
  TCBWrite(sid, mid, addr, data);
}

// write ADC input bitslip
void SIPMTCBwrite_ADC_BITSLIP(int sid, unsigned long mid, int ch, int data)
{
  int addr;

  addr = 0x20000014 + (((ch - 1) & 0xFF) << 16);
  TCBWrite(sid, mid, addr, data);
}

// write DRAM input delay
void SIPMTCBwrite_DRAM_DLY(int sid, unsigned long mid, int ch, int data)
{
  int addr;

  addr = 0x20000015 + ((ch & 0xFF) << 16);
  TCBWrite(sid, mid, addr, data);
}

// write DRAM input bitslip
void SIPMTCBwrite_DRAM_BITSLIP(int sid, unsigned long mid, int ch)
{
  int addr;

  addr = 0x20000016 + ((ch & 0xFF) << 16);
  TCBWrite(sid, mid, addr, 0);
}

// ******************************************************************************************************

// initialize libusb library
void USB3Init(void)
{
  if (libusb_init(0) < 0) {
    fprintf(stderr, "Failed to initialise LIBUSB\n");
    exit(1);
  }
}

// de-initialize libusb library
void USB3Exit(void)
{
  libusb_exit(0); 
}

// open SIPMTCB
int SIPMTCBopen(int sid)
{
  struct libusb_device **devs;
  struct libusb_device *dev;
  struct libusb_device_handle *devh;
  size_t i = 0;
  int nopen_devices = 0; //number of open devices
  int r;
  int interface = 0;
  int sid_tmp;
  int speed;

  if (libusb_get_device_list(0, &devs) < 0) 
    fprintf(stderr, "Error: open_device: Could not get device list\n");

  fprintf(stdout, "Info: open_device: opening device Vendor ID = 0x%X, Product ID = 0x%X, Serial ID = %u\n",
                   SIPMTCB_VENDOR_ID, SIPMTCB_PRODUCT_ID, sid);

  while ((dev = devs[i++])) {
    struct libusb_device_descriptor desc;
    r = libusb_get_device_descriptor(dev, &desc);
    if (r < 0) {
      fprintf(stdout, "Warning, open_device: could not get device device descriptior." " Ignoring.\n");
      continue;
    }

    if (desc.idVendor == SIPMTCB_VENDOR_ID && desc.idProduct == SIPMTCB_PRODUCT_ID)  {
      r = libusb_open(dev, &devh);
      if (r < 0) {
        fprintf(stdout, "Warning, open_device: could not open device." " Ignoring.\n");
        continue;
      }

      // do not open twice
      if (is_device_open(devh)) {
        fprintf(stdout, "Info, open_device: device already open." " Ignoring.\n");
        libusb_close(devh);
        continue;
      }

      // See if sid matches
      // Assume interface 0
      if (libusb_claim_interface(devh, interface) < 0) {
        fprintf(stdout, "Warning, open_device: could not claim interface 0 on the device." " Ignoring.\n");
        libusb_close(devh);
        continue;
      }

      sid_tmp = get_serial_id(devh);

      if (sid == 0xFF || sid == sid_tmp) {
        add_device(&ldev_open, devh, SIPMTCB_VENDOR_ID, SIPMTCB_PRODUCT_ID, sid_tmp);
        nopen_devices++;
  
        // Print out the speed of just open device 
        speed = libusb_get_device_speed(dev);
        switch (speed) {
          case 4:
            fprintf(stdout, "Info: open_device: super speed device opened");
            break;
          case 3:
            fprintf(stdout, "Info: open_device: high speed device opened");
            break;
          case 2:
            fprintf(stdout, "Info: open_device: full speed device opened");
            break;
          case 1:
            fprintf(stdout, "Info: open_device: low speed device opened");
            break;
          case 0:
            fprintf(stdout, "Info: open_device: unknown speed device opened");
            break;
        }
        
        fprintf(stdout, " (bus = %d, address = %d, serial id = %u).\n",
                    libusb_get_bus_number(dev), libusb_get_device_address(dev), sid_tmp);
        libusb_release_interface(devh, interface);
        break;
      }
      else {
        libusb_release_interface(devh, interface);
        libusb_close(devh);
      }
    }
  }

  libusb_free_device_list(devs, 1);

  // claim interface
  handle_interface_id(&ldev_open, SIPMTCB_VENDOR_ID, SIPMTCB_PRODUCT_ID, sid, 0, kInterfaceClaim);

  if (!nopen_devices)
    return -1;

  devh = nkusb_get_device_handle(SIPMTCB_VENDOR_ID, SIPMTCB_PRODUCT_ID, sid);
  if (!devh) {
    fprintf(stderr, "Could not get device handle for the device.\n");
    return -1;
  }

  return 0;
}

// close SIPMTCB
void SIPMTCBclose(int sid)
{
  handle_interface_id(&ldev_open, SIPMTCB_VENDOR_ID, SIPMTCB_PRODUCT_ID, sid, 0, kInterfaceRelease);
  remove_device_id(&ldev_open, SIPMTCB_VENDOR_ID, SIPMTCB_PRODUCT_ID, sid);
}

// reset 
void SIPMTCBreset(int sid)
{
  TCBWrite(sid, 0, 0x20000000, 0x04);
}

// start DAQ
void SIPMTCBstart_DAQ(int sid)
{
  TCBWrite(sid, 0, 0x20000000, 0x08);
}

// start DAQ
void SIPMTCBstop_DAQ(int sid)
{
  TCBWrite(sid, 0, 0x20000000, 0x20);
}

// send software trigger
void SIPMTCBsend_TRIG(int sid)
{
  TCBWrite(sid, 0, 0x20000000, 0x10);
}

// read DAQ status
unsigned long SIPMTCBread_RUN(int sid)
{
  return TCBReadReg(sid, 0, 0x20000000);
}

// write # of frames, 1 ~ 1,000,000
void SIPMTCBwrite_FRAME(int sid, unsigned long data)
{
  TCBWrite(sid, 0, 0x20000001, data);
}

// read # of frames
unsigned long SIPMTCBread_FRAME(int sid)
{
  return TCBReadReg(sid, 0, 0x20000001);
}

// write frame scan time in ms, 1 ~ 65535
void SIPMTCBwrite_SCAN_TIME(int sid, unsigned long data)
{
  TCBWrite(sid, 0, 0x20000002, data);
}

// read frame time
unsigned long SIPMTCBread_SCAN_TIME(int sid)
{
  return TCBReadReg(sid, 0, 0x20000002);
}

// write trigger mode, 0 = not use external trigger, 1 = use it
void SIPMTCBwrite_TRIGGER_MODE(int sid, unsigned long data)
{
  TCBWrite(sid, 0, 0x20000003, data);
}

// read trigger mode
unsigned long SIPMTCBread_TRIGGER_MODE(int sid)
{
  return TCBReadReg(sid, 0, 0x20000003);
}

// read DAQ link status
void SIPMTCBread_LINK(int sid, unsigned long *data)
{
  data[0] = TCBReadReg(sid, 0, 0x20000005);
  data[1] = TCBReadReg(sid, 0, 0x20000006);
}

// read mids ; TCB
void SIPMTCBread_MID(int sid, unsigned long *data)
{
  int i;

  for (i = 0; i < 40; i ++) 
    data[i] = TCBReadReg(sid, 0, 0x20000007 + i);
}

// read data size, data size = # of frames, 1 frame = 4 kbyte
unsigned long SIPMTCBread_DATASIZE(int sid)
{
  return TCBReadReg(sid, 0, 0x30000000);
}

// read data
void SIPMTCBread_DATA(int sid, unsigned long data_size, char* data)
{
  int count;

  count = data_size * 256;
  TCBRead(sid, 0, count, 0x40000000, data);
}

// write high voltage, 0 ~ 60 V
void SIPMTCBwrite_HV(int sid, unsigned long mid, unsigned long ch, float data)
{
  float fval;
  int value;
  unsigned long addr = 0x20000002;
  addr += ((ch - 1) & 0xFF) << 16;

  fval = 4.49 * (data - 3.2);
  value = (int)(fval);
  if (value > 254)
    value = 254;
  else if (value < 0)
    value = 0;

  TCBWrite(sid, mid, addr, value);
}

// read high voltage
float SIPMTCBread_HV(int sid, unsigned long mid, unsigned long ch)
{
  unsigned long data;
  float value;
  unsigned long addr = 0x20000002;
  addr += ((ch - 1) & 0xFF) << 16;

  data = TCBReadReg(sid, mid, addr);
  value = data;
  value = value / 4.49 + 3.2;

  return value;
}

// read temperature
float SIPMTCBread_TEMP(int sid, unsigned long mid, unsigned long ch)
{
  unsigned long data;
  int value;
  int sign;
  float fval;
  unsigned long addr = 0x20000003;
  addr += ((ch - 1) & 0xFF) << 16;

  data = TCBReadReg(sid, mid, addr);

  value = data & 0x7FF;
  sign = data & 0x800;

  if (sign)
    value = (0xFFFFFFFF - value) & 0x7FF;

  fval = value;
  fval = fval / 16.0;

  return fval;
}

// read pedestal
unsigned long SIPMTCBread_PED(int sid, unsigned long mid, unsigned long ch)
{
  unsigned long addr = 0x20000004;
  addr += ((ch - 1) & 0xFF) << 16;

  return TCBReadReg(sid, mid, addr);
}

// write threshold, 1 ~ 16383
void SIPMTCBwrite_THR(int sid, unsigned long mid, unsigned long ch, unsigned long data)
{
  unsigned long addr = 0x20000005;
  addr += ((ch - 1) & 0xFF) << 16;

  TCBWrite(sid, mid, addr, data);
}

// read threshold
unsigned long SIPMTCBread_THR(int sid, unsigned long mid, unsigned long ch)
{
  unsigned long addr = 0x20000005;
  addr += ((ch - 1) & 0xFF) << 16;

  return TCBReadReg(sid, mid, addr);
}

// write pulse width, 8 ~ 2040 ns
void SIPMTCBwrite_PSW(int sid, unsigned long mid, unsigned long data)
{
  TCBWrite(sid, mid, 0x20000006, data);
}

// read pulse width
unsigned long SIPMTCBread_PSW(int sid, unsigned long mid)
{
  return TCBReadReg(sid, mid, 0x20000006);
}

// write pulse risetime, 8 ~ 120 ns
void SIPMTCBwrite_RISETIME(int sid, unsigned long mid, unsigned long data)
{
  TCBWrite(sid, mid, 0x20000007, data);
}

// read pulse risetime
unsigned long SIPMTCBread_RISETIME(int sid, unsigned long mid)
{
  return TCBReadReg(sid, mid, 0x20000007);
}

// write PSD delay, 0 ~ 504 ns
void SIPMTCBwrite_PSD_DLY(int sid, unsigned long mid, unsigned long data)
{
  TCBWrite(sid, mid, 0x20000008, data);
}

// read PSD delay
unsigned long SIPMTCBread_PSD_DLY(int sid, unsigned long mid)
{
  return TCBReadReg(sid, mid, 0x20000008);
}

// write PSD threshold
void SIPMTCBwrite_PSD_THR(int sid, unsigned long mid, unsigned long ch, float data)
{
  unsigned long addr = 0x20000009;
  unsigned long value;
  float fval;

  addr += (ch & 0xFF) << 16;
  fval = data * 1024.0;
  value = (unsigned long)(fval);

  TCBWrite(sid, mid, addr, value);
}

// read PSD threshold
float SIPMTCBread_PSD_THR(int sid, unsigned long mid, unsigned long ch)
{
  unsigned long addr = 0x20000009;
  float fval;
  unsigned long data;

  addr += (ch & 0xFF) << 16;
  
  data = TCBReadReg(sid, mid, addr);
  fval = data;
  fval = fval / 1024.0;

  return fval;
}

// align ADC for SiPMDAQ
void SIPMTCBalign_ADC(int sid, unsigned long mid)
{
  int ch;
  int dly;
  int bit_okay;
  int word_okay;
  int flag;
  int gdly;
  int bitslip;
  int gbitslip;
  int start;
  int stop;
  int count;
  int gstart;
  int gstop;
  int gcount;
  int fail;
  int okay;
  int i;

  SIPMTCBreset_ADC(sid, mid);
  usleep(1000000);
  SIPMTCBreset_REF_CLK(sid, mid);

  // ADC initialization codes
  SIPMTCBsetup_ADC(sid, mid, 0x0009, 0x02);
  SIPMTCBsetup_ADC(sid, mid, 0x070A, 0x01);

  for (ch = 1; ch <= 32; ch++) {
    // set deskew pattern
    SIPMTCBsetup_ADC(sid, mid, 0x0006, 0x02);
    SIPMTCBsetup_ADC(sid, mid, 0x000A, 0x33);
    SIPMTCBsetup_ADC(sid, mid, 0x000B, 0x33);

    // bitslip = 0;
    SIPMTCBwrite_ADC_BITSLIP(sid, mid, ch, 0);

    gbitslip = 0;
    start = 0;
    stop = 0;
    count = 0;
    gstart = 0;
    gstop = 0;
    gcount = 0;
    fail = 1;
    flag = 0;
  
    for(dly = 0; dly < 32; dly++) {
      // set ADC delay
      SIPMTCBwrite_ADC_DLY(sid, mid, ch, dly);

      // check word alignment
      okay = 1;
      for (i = 0; i < 10; i++) {
        bit_okay = SIPMTCBread_ADC_BIT_ALIGN(sid, mid, ch);
        if (!bit_okay)
          okay = 0;
      }

      if (okay) {
        if (fail) 
          start = dly;
        count = count + 1;
        fail = 0;
      }
      else {
        if (!fail) {
          stop = dly - 1;
          if (count > gcount) {
            gcount = count;
            gstart = start;
            gstop = stop;
          }
        }
        count = 0;
        fail = 1;
      }
    }
    
    gdly = (gstart + gstop) / 2;
    if (gdly)
      flag = flag + 1;
    
    // set good delay
    SIPMTCBwrite_ADC_DLY(sid, mid, ch, gdly);

    // set sync pattern
    SIPMTCBsetup_ADC(sid, mid, 0x000E, 0x81);
    SIPMTCBsetup_ADC(sid, mid, 0x000F, 0x00);
    SIPMTCBsetup_ADC(sid, mid, 0x000A, 0x55);
    SIPMTCBsetup_ADC(sid, mid, 0x000B, 0x55);

    for(bitslip = 0; bitslip < 7; bitslip++) {
      // set bitslip
      SIPMTCBwrite_ADC_BITSLIP(sid, mid, ch, bitslip);
  
      // check word alignment
      word_okay = SIPMTCBread_ADC_WORD_ALIGN(sid, mid, ch);

      if(word_okay) {
        flag = flag + 1;
        gbitslip = bitslip;
        bitslip = 7;
      }
    }

    if (flag > 1) 
      printf("ADC(%d) is aligned, delay = %d, bitslip = %d\n", ch, gdly, gbitslip);
    else 
      printf("Fail to align ADC(%d)!\n", ch);
  }
  
  //set ADC normal operation
  SIPMTCBsetup_ADC(sid, mid, 0x0122, 0x02);
  SIPMTCBsetup_ADC(sid, mid, 0x0222, 0x02);
  SIPMTCBsetup_ADC(sid, mid, 0x0422, 0x02);
  SIPMTCBsetup_ADC(sid, mid, 0x0522, 0x02);

  SIPMTCBsetup_ADC(sid, mid, 0x0009, 0x01);
  SIPMTCBsetup_ADC(sid, mid, 0x0006, 0x00);
  SIPMTCBsetup_ADC(sid, mid, 0x000A, 0x00);
  SIPMTCBsetup_ADC(sid, mid, 0x000B, 0x00);
}

// align DRAM
void SIPMTCBalign_DRAM(int sid, unsigned long mid)
{
  int ch;
  int dly;
  int value;
  int flag;
  int count;
  int sum;
  int aflag;
  int gdly;
  int bitslip;
  int gbitslip;

  // turn on DRAM    
  SIPMTCBsetup_DRAM(sid, mid);

  // enter DRAM test mode
  SIPMTCBwrite_DRAM_TEST(sid, mid, 1);

  // send reset to iodelay  
  SIPMTCBreset_REF_CLK(sid, mid);

  // fill DRAM test pattern
  SIPMTCBwrite_DRAM_TEST(sid, mid, 2);

  for (ch = 0; ch < 8; ch++) {
    count = 0;
    sum = 0;
    flag = 0;

    // search delay
    for (dly = 0; dly < 32; dly++) {
      // set delay
      SIPMTCBwrite_DRAM_DLY(sid, mid, ch, dly);

      // read DRAM test pattern
      SIPMTCBwrite_DRAM_TEST(sid, mid, 3);
      value = SIPMTCBread_DRAM_ALIGN(sid, mid, ch);

      aflag = 0;
      if (value == 0xFFAA5500)
        aflag = 1;
      else if (value == 0xAA5500FF)
        aflag = 1;
      else if (value == 0x5500FFAA)
        aflag = 1;
      else if (value == 0x00FFAA55)
        aflag = 1;
    
      if (aflag) {
        count = count + 1;
        sum = sum + dly;
        if (count > 4)
          flag = 1; 
      }
      else {
        if (flag)
          dly = 32;
        else {
          count = 0;
          sum = 0;
        }
      }
    }

    // get bad delay center
    if (count)
      gdly = sum / count;
    else
      gdly = 9;

    // set delay
    SIPMTCBwrite_DRAM_DLY(sid, mid, ch, gdly);
  
    // get bitslip
    for (bitslip = 0; bitslip < 4; bitslip++) {
      // read DRAM test pattern
      SIPMTCBwrite_DRAM_TEST(sid, mid, 3);
      value = SIPMTCBread_DRAM_ALIGN(sid, mid, ch);

      if (value == 0xFFAA5500) {
        aflag = 1;
        gbitslip = bitslip;
        bitslip = 4;
      }
      else {
        aflag = 0;
        SIPMTCBwrite_DRAM_BITSLIP(sid, mid, ch);
      }
    }

    if (aflag)
      printf("DRAM(%d) is aligned, delay = %d, bitslip = %d\n", ch, gdly, gbitslip);
    else
      printf("Fail to align DRAM(%d)!\n", ch);
  }
   
  // exit DRAM test mode
  SIPMTCBwrite_DRAM_TEST(sid, mid, 0);
}


















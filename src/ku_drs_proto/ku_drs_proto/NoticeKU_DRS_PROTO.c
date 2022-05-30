#include "NoticeKU_DRS_PROTO.h"

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
int USB3WriteControl(uint16_t vendor_id, uint16_t product_id, int sid, uint8_t bRequest, uint16_t wValue,
		       uint16_t wIndex, unsigned char *data, uint16_t wLength);
int USB3ReadControl(uint16_t vendor_id, uint16_t product_id, int sid, uint8_t bRequest, uint16_t wValue, uint16_t wIndex, unsigned char *data, uint16_t wLength);
void USB3Reset(uint16_t vendor_id, uint16_t product_id, int sid);
void USB3ReadCAL(uint16_t vendor_id, uint16_t product_id, int sid, int page, char *data);
int USB3Read(uint16_t vendor_id, uint16_t product_id, int sid, uint32_t count, 
             uint32_t addr, char *data);
libusb_device_handle* nkusb_get_device_handle(uint16_t vendor_id, uint16_t product_id, int sid);
int USB3WriteReg(uint16_t vendor_id, uint16_t product_id, int sid, uint32_t addr, uint32_t data);
int USB3ReadReg(uint16_t vendor_id, uint16_t product_id, int sid, uint32_t addr);
void USB3ReadBlk(uint16_t vendor_id, uint16_t product_id, int sid, int buf_cnt, char *data);
int KU_DRS_PROTOread_PLL_LOCK(int sid);
void KU_DRS_PROTOwrite_DRS_ON(int sid, int data);
void KU_DRS_PROTOwrite_ROFS(int sid, int data);
int KU_DRS_PROTOread_ROFS(int sid);
void KU_DRS_PROTOwrite_OOFS(int sid, int data);
int KU_DRS_PROTOread_OOFS(int sid);
void KU_DRS_PROTOset_ADC(int sid, int addr, int data);
void KU_DRS_PROTOwrite_CAL(int sid);
int KU_DRS_PROTOinit(int sid);

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
                  interface, vendor_id, product_id, sid);
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

int USB3WriteControl(uint16_t vendor_id, uint16_t product_id, int sid, uint8_t bRequest, uint16_t wValue,
		       uint16_t wIndex, unsigned char *data, uint16_t wLength)
{
  const unsigned int timeout = 1000;
  int stat = 0;
  
  libusb_device_handle *devh = nkusb_get_device_handle(vendor_id, product_id, sid);
  if (!devh) {
    fprintf(stderr, "USB3Write: Could not get device handle for the device.\n");
    return -1;
  }
  
  if ((stat = libusb_control_transfer(devh, LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_ENDPOINT_OUT, bRequest, wValue, wIndex, data, wLength, timeout)) < 0) {
    fprintf(stderr, "USB3WriteControl:  Could not make write request; error = %d\n", stat);
    return stat;
  }
  
  return stat;
}

int USB3ReadControl(uint16_t vendor_id, uint16_t product_id, int sid, uint8_t bRequest, uint16_t wValue, uint16_t wIndex, unsigned char *data, uint16_t wLength)
{
  const unsigned int timeout = 1000;
  int stat = 0;
  
  libusb_device_handle *devh = nkusb_get_device_handle(vendor_id, product_id, sid);
  if (!devh) {
    fprintf(stderr, "USB3ReadControl: Could not get device handle for the device.\n");
    return -1;
  }
  
  if ((stat = libusb_control_transfer(devh, LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_ENDPOINT_IN, bRequest, wValue, wIndex, data, wLength, timeout)) < 0) {
    fprintf(stderr, "USB3ReadControl: Could not make read request; error = %d\n", stat);
    return stat;
  }

  return 0;
}

void USB3Reset(uint16_t vendor_id, uint16_t product_id, int sid)
{
  unsigned char data;

  USB3WriteControl(vendor_id, product_id, sid, 0xD6, 0, 0, &data, 0);
}

void USB3ReadCAL(uint16_t vendor_id, uint16_t product_id, int sid, int page, char *data)
{
  USB3ReadControl(vendor_id, product_id, sid, 0xD7, page, 0, data, 256);
}

int USB3Read(uint16_t vendor_id, uint16_t product_id, int sid, uint32_t count, 
             uint32_t addr, char *data)
{
  const unsigned int timeout = 1000; 
  int length = 8;
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
    fprintf(stderr, "USB3Read: Could not allocate memory (size = %d\n)", size);
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

  libusb_device_handle *devh = nkusb_get_device_handle(vendor_id, product_id, sid);
  if (!devh) {
    fprintf(stderr, "USB3Write: Could not get device handle for the device.\n");
    return -1;
  }

  if ((stat = libusb_bulk_transfer(devh, USB3_SF_WRITE, buffer, length, &transferred, timeout)) < 0) {
    fprintf(stderr, "USB3Read: Could not make write request; error = %d\n", stat);
    USB3Reset(vendor_id, product_id, sid);
    free(buffer);
    return stat;
  }

  for (loop = 0; loop < nbulk; loop++) {
    if ((stat = libusb_bulk_transfer(devh, USB3_SF_READ, buffer, size, &transferred, timeout)) < 0) {
      fprintf(stderr, "USB3Read: Could not make read request; error = %d\n", stat);
      USB3Reset(vendor_id, product_id, sid);
      return 1;
    }
    memcpy(data + loop * size, buffer, size);
  }

  if (remains) {
    if ((stat = libusb_bulk_transfer(devh, USB3_SF_READ, buffer, remains * 4, &transferred, timeout)) < 0) {
      fprintf(stderr, "USB3Read: Could not make read request; error = %d\n", stat);
      USB3Reset(vendor_id, product_id, sid);
      return 1;
    }
    memcpy(data + nbulk * size, buffer, remains * 4);
  }

  free(buffer);
  
  return 0;
}

int USB3WriteReg(uint16_t vendor_id, uint16_t product_id, int sid, uint32_t addr, uint32_t data)
{
  int transferred = 0;  
  const unsigned int timeout = 1000;
  //int length = 8;
  int length = 8;
  unsigned char *buffer;
  int stat = 0;
  
  if (!(buffer = (unsigned char *)malloc(length))) {
    fprintf(stderr, "USB3TCBWrite: Could not allocate memory (size = %d\n)", length);
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

  libusb_device_handle *devh = nkusb_get_device_handle(vendor_id, product_id, sid);
  if (!devh) {
    fprintf(stderr, "USB3TCBWrite: Could not get device handle for the device.\n");
    return -1;
  }
  
  if ((stat = libusb_bulk_transfer(devh, USB3_SF_WRITE, buffer, length, &transferred, timeout)) < 0) {
    fprintf(stderr, "USB3TCBWrite: Could not make write request; error = %d\n", stat);
    free(buffer);
    return stat;
  }
  
  free(buffer);

  usleep(1000);

  return stat;
}

int USB3ReadReg(uint16_t vendor_id, uint16_t product_id, int sid, uint32_t addr)
{
  char data[4];
  unsigned int value;
  unsigned int tmp;

  USB3Read(vendor_id, product_id, sid, 1, addr, data);

  value = data[0] & 0xFF;
  tmp = data[1] & 0xFF;
  value = value + (unsigned int)(tmp << 8);
  tmp = data[2] & 0xFF;
  value = value + (unsigned int)(tmp << 16);
  tmp = data[3] & 0xFF;
  value = value + (unsigned int)(tmp << 24);

  return value;
}  

void USB3ReadBlk(uint16_t vendor_id, uint16_t product_id, int sid, int buf_cnt, char *data)
{
  USB3Read(vendor_id, product_id, sid, buf_cnt * 8192, 0, data);
}

// read PLL lock status
int KU_DRS_PROTOread_PLL_LOCK(int sid)
{
  return USB3ReadReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2004);
}

// write DRS ON
void KU_DRS_PROTOwrite_DRS_ON(int sid, int data)
{
  USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2008, data);
}

// write DRS ROFS
void KU_DRS_PROTOwrite_ROFS(int sid, int data)
{
  USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2006, data);
}

// read DRS ROFS
int KU_DRS_PROTOread_ROFS(int sid)
{
  return USB3ReadReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2006);
}

// write DRS OOFS
void KU_DRS_PROTOwrite_OOFS(int sid, int data)
{
  USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2007, data);
}

// read DRS OOFS
int KU_DRS_PROTOread_OOFS(int sid)
{
  return USB3ReadReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2007);
}

// write ADC setup
void KU_DRS_PROTOset_ADC(int sid, int addr, int data)
{
  int value;

  value = ((addr & 0xFF) << 8) | (data & 0xFF);
  USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x200A, value);
}

// write calibration table
void KU_DRS_PROTOwrite_CAL(int sid)
{
  int status;
  int page;
  char data[256];
  int i;
  int addr;
  int value;

  USB3ReadControl(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0xD9, 0, 0, data, 1);
  status = data[0] & 0xFF;

  if (!status) {
    for (page = 0; page < 64; page++) {
      USB3ReadCAL(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, page, data);

      for (i = 0; i < 64; i++) {
        addr = 0x3000 + page * 64 + i;
        value = ((data[4 * i + 3] & 0xFF) << 24) | ((data[4 * i + 2] & 0xFF) << 16)
              | ((data[4 * i + 1] & 0xFF) << 8) | (data[4 * i] & 0xFF);   
        USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, addr, value);
      }
    }

    data[0] = 1;    
    USB3WriteControl(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0xD8, 0, 0, data, 1);
  }
}

// initialize DRS
int KU_DRS_PROTOinit(int sid)
{
  int buf_cnt;
  char data[32768];
  int plllock = 0;
  int ntries = 0;

  // turn off and on DRS DENABLE
  KU_DRS_PROTOwrite_DRS_ON(sid, 0);
  usleep(100000);
  KU_DRS_PROTOwrite_DRS_ON(sid, 1);
  usleep(100000);

  // check DRS PLL locked
  while (((plllock = KU_DRS_PROTOread_PLL_LOCK(sid)) == 0) && (ntries++ < 100)) {
     usleep(10000); 
  }

  // set ADC
  KU_DRS_PROTOset_ADC(sid, 0x0D, 0x00);
  KU_DRS_PROTOset_ADC(sid, 0xFF, 0x01);

  // DRS rofs to 3100 (~ 1.56 V)
  KU_DRS_PROTOwrite_ROFS(sid, 3075);
 
  // DRS o-ofs to 2400 (~ 1.17 V)
  KU_DRS_PROTOwrite_OOFS(sid, 2400);

  // download calibration data
  KU_DRS_PROTOwrite_CAL(sid);

  // calibration off
  KU_DRS_PROTOwrite_CALMODE(sid, 0);

  // start DAQ
  KU_DRS_PROTOstart(sid);

  buf_cnt = 0;
  while(!buf_cnt) {
    KU_DRS_PROTOsend_TRIG(sid);
    KU_DRS_PROTOsend_TRIG(sid);
    buf_cnt = KU_DRS_PROTOread_DATASIZE(sid);
  }

  KU_DRS_PROTOread_DATA(sid, 1, data);
  KU_DRS_PROTOread_DATA(sid, 1, data);

  // reset 
  KU_DRS_PROTOreset(sid);

  return 1;
}

// ******************************************************************************************************

// open KU_DRS_PROTO
int KU_DRS_PROTOopen(int sid)
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

  if (libusb_init(0) < 0) {
    fprintf(stderr, "failed to initialise libusb\n");
    exit(1);
  }

  if (libusb_get_device_list(0, &devs) < 0) 
    fprintf(stderr, "Error: open_device: Could not get device list\n");

  fprintf(stdout, "Info: open_device: opening device Vendor ID = 0x%X, Product ID = 0x%X, Serial ID = %u\n",
                   KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid);

  while ((dev = devs[i++])) {
    struct libusb_device_descriptor desc;
    r = libusb_get_device_descriptor(dev, &desc);
    if (r < 0) {
      fprintf(stdout, "Warning, open_device: could not get device device descriptior." " Ignoring.\n");
      continue;
    }

    if (desc.idVendor == KU_DRS_PROTO_VENDOR_ID && desc.idProduct == KU_DRS_PROTO_PRODUCT_ID)  {
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
        add_device(&ldev_open, devh, KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid_tmp);
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
  handle_interface_id(&ldev_open, KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0, kInterfaceClaim);

  if (!nopen_devices)
    return -1;

  devh = nkusb_get_device_handle(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid);
  if (!devh) {
    fprintf(stderr, "Could not get device handle for the device.\n");
    return -1;
  }

  // initialize DRS
  if (KU_DRS_PROTOinit(sid))
    printf("DRS is initialized!\n");
  else
    printf("Fail to initialization!\n");

  return 0;
}

// close KU_DRS_PROTO
void KU_DRS_PROTOclose(int sid)
{
  handle_interface_id(&ldev_open, KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0, kInterfaceRelease);
  remove_device_id(&ldev_open, KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid);
  libusb_exit(0); 
}

// read raw peak data
// data are character array which should be managed offline
void KU_DRS_PROTOread_DATA(int sid, int buf_cnt, char *data)
{
  USB3ReadBlk(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, buf_cnt, data);  
}

// reset DAQ
void KU_DRS_PROTOreset(int sid)
{
  USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2000, 0);
} 

// start data acquisition
void KU_DRS_PROTOstart(int sid)
{
  USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2001, 1);
}

// stop data acquisition
void KU_DRS_PROTOstop(int sid)
{
  USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2001, 0);
}

// read DAQ status
// return 1 when run
int KU_DRS_PROTOread_RUN(int sid)
{
  return USB3ReadReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2001);
}

// read filled data size
int KU_DRS_PROTOread_DATASIZE(int sid)
{
  return USB3ReadReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2002);
}

// write delay
void KU_DRS_PROTOwrite_TRIG_DLY(int sid, int data)
{
  int value;

  value = data / 10;

  USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2003, value);
}

// read delay
int KU_DRS_PROTOread_TRIG_DLY(int sid)
{   
  int data;
  int value;

  value = USB3ReadReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2003);
  data = value * 10;

  return data;
}

// write DRS calibration mode
void KU_DRS_PROTOwrite_CALMODE(int sid, int data)
{
  USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2005, data);
}

// read DRS calibration mode
int KU_DRS_PROTOread_CALMODE(int sid)
{
  return USB3ReadReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2005);
}

// send software trigger
void KU_DRS_PROTOsend_TRIG(int sid)
{
  USB3WriteReg(KU_DRS_PROTO_VENDOR_ID, KU_DRS_PROTO_PRODUCT_ID, sid, 0x2009, 0);
}


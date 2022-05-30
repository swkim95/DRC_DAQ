#include "NoticeSIPMDAQ.h"

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
int USB3WriteControl(int sid, uint8_t bRequest, uint16_t wValue, uint16_t wIndex, unsigned char *data, uint16_t wLength);
void USB3Reset(int sid);
int USB3Read(int sid, uint32_t count, uint32_t addr, char *data);
int USB3ReadReg(int sid, uint32_t addr);

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

int USB3WriteControl(int sid, uint8_t bRequest, uint16_t wValue, uint16_t wIndex, unsigned char *data, uint16_t wLength)
{
  const unsigned int timeout = 1000;
  int stat = 0;
  
  libusb_device_handle *devh = nkusb_get_device_handle(SIPMDAQ_VENDOR_ID, SIPMDAQ_PRODUCT_ID, sid);
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

void USB3Reset(int sid)
{
  unsigned char data;

  USB3WriteControl(sid, 0xD6, 0, 0, &data, 0);
}

int USB3Read(int sid, uint32_t count, uint32_t addr, char *data)
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

  libusb_device_handle *devh = nkusb_get_device_handle(SIPMDAQ_VENDOR_ID, SIPMDAQ_PRODUCT_ID, sid);
  if (!devh) {
    fprintf(stderr, "USB3Write: Could not get device handle for the device.\n");
    return -1;
  }

  if ((stat = libusb_bulk_transfer(devh, USB3_SF_WRITE, buffer, length, &transferred, timeout)) < 0) {
    fprintf(stderr, "USB3Read: Could not make write request; error = %d\n", stat);
    USB3Reset(sid);
    free(buffer);
    return stat;
  }

  for (loop = 0; loop < nbulk; loop++) {
    if ((stat = libusb_bulk_transfer(devh, USB3_SF_READ, buffer, size, &transferred, timeout)) < 0) {
      fprintf(stderr, "USB3Read: Could not make read request; error = %d\n", stat);
      USB3Reset(sid);
      return 1;
    }
    memcpy(data + loop * size, buffer, size);
  }

  if (remains) {
    if ((stat = libusb_bulk_transfer(devh, USB3_SF_READ, buffer, remains * 4, &transferred, timeout)) < 0) {
      fprintf(stderr, "USB3Read: Could not make read request; error = %d\n", stat);
      USB3Reset(sid);
      return 1;
    }
    memcpy(data + nbulk * size, buffer, remains * 4);
  }

  free(buffer);
  
  return 0;
}

int USB3ReadReg(int sid, uint32_t addr)
{
  char data[4];
  unsigned int value;
  unsigned int tmp;

  USB3Read(sid, 1, addr, data);

  value = data[0] & 0xFF;
  tmp = data[1] & 0xFF;
  value = value + (unsigned int)(tmp << 8);
  tmp = data[2] & 0xFF;
  value = value + (unsigned int)(tmp << 16);
  tmp = data[3] & 0xFF;
  value = value + (unsigned int)(tmp << 24);

  return value;
}  

// ******************************************************************************************************

// open SIPMDAQ
int SIPMDAQopen(int sid)
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
                   SIPMDAQ_VENDOR_ID, SIPMDAQ_PRODUCT_ID, sid);

  while ((dev = devs[i++])) {
    struct libusb_device_descriptor desc;
    r = libusb_get_device_descriptor(dev, &desc);
    if (r < 0) {
      fprintf(stdout, "Warning, open_device: could not get device device descriptior." " Ignoring.\n");
      continue;
    }

    if (desc.idVendor == SIPMDAQ_VENDOR_ID && desc.idProduct == SIPMDAQ_PRODUCT_ID)  {
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
        add_device(&ldev_open, devh, SIPMDAQ_VENDOR_ID, SIPMDAQ_PRODUCT_ID, sid_tmp);
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
  handle_interface_id(&ldev_open, SIPMDAQ_VENDOR_ID, SIPMDAQ_PRODUCT_ID, sid, 0, kInterfaceClaim);

  if (!nopen_devices)
    return -1;

  devh = nkusb_get_device_handle(SIPMDAQ_VENDOR_ID, SIPMDAQ_PRODUCT_ID, sid);
  if (!devh) {
    fprintf(stderr, "Could not get device handle for the device.\n");
    return -1;
  }

  return 0;
}

// close SIPMDAQ
void SIPMDAQclose(int sid)
{
  handle_interface_id(&ldev_open, SIPMDAQ_VENDOR_ID, SIPMDAQ_PRODUCT_ID, sid, 0, kInterfaceRelease);
  remove_device_id(&ldev_open, SIPMDAQ_VENDOR_ID, SIPMDAQ_PRODUCT_ID, sid);
}


// read charge data size, data size = # of events, 1 event = 16 byte
unsigned long SIPMDAQread_DATASIZE(int sid)
{
  return USB3ReadReg(sid, 0x30000000);
}

// read FADC data size, data size = kbytes
unsigned long SIPMDAQread_FADC_DATASIZE(int sid)
{
  return USB3ReadReg(sid, 0x30001000);
}

// read RUN
unsigned long SIPMDAQread_RUN(int sid)
{
  return USB3ReadReg(sid, 0x30002000);
}

// read charge data
void SIPMDAQread_DATA(int sid, unsigned long data_size, char *data)
{
  int count;

  count = data_size * 4;

  USB3Read(sid, count, 0x40000000, data);  
}

// read FADC data
void SIPMDAQread_FADC_DATA(int sid, unsigned long data_size, char *data)
{
  int count;

  count = data_size * 256;

  USB3Read(sid, count, 0x40001000, data);  
}



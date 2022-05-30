#include "cyu3error.h"
#include "cyu3system.h"
#include "cyu3os.h"
#include "cyu3types.h"

#define EP0_BUFF_SIZE 4096
#define SPI_SIMPLE_GPIO_H  0x01E00000
#define SPI_SIMPLE_GPIO_L  0x00000000
#define SPI_CLK             (53) 
#define SPI_SS              (54) 
#define SPI_MISO            (55) 
#define SPI_MOSI            (56) 
#define FPGA_SIMPLE_GPIO_L 0x02000000
#define FPGA_SIMPLE_GPIO_H 0x000C0000
#define FPGA_RESET      (25)
#define FPGA_MIDSCK	(50)
#define FPGA_MIDSDI	(51)

extern uint16_t glI2cPageSize; 

// GPIO function
CyU3PReturnStatus_t initGPIO(void);

// I2C functions
CyU3PReturnStatus_t i2cInit(void);
CyU3PReturnStatus_t i2cWrite(uint8_t *buffer);
void i2cReset(void);

// SPI functions
CyU3PReturnStatus_t spiInit(void);
uint8_t SPIcommand(uint8_t data);
uint8_t SPIdata(uint16_t byteCount, uint8_t *data);

// FPGA functions
uint8_t fpgaInit(void);
CyU3PReturnStatus_t fpgaStart(void);
CyU3PReturnStatus_t fpgaStop(void);

// from main function
CyU3PReturnStatus_t fifoInit(void);
CyU3PReturnStatus_t fifoStart(void); 
void fifoStop(void); 
void myUSBwriteEP6(CyU3PDmaChannel *chHandle, CyU3PDmaCbType_t type, CyU3PDmaCBInput_t *input); 
CyBool_t fifoClear(uint16_t wValue, uint16_t wIndex);








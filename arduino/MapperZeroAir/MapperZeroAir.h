/* MapperZeroAir powered by ESP32 DevKitC */
/* $Id: MapperZeroAir.h 1561 2023-12-17 03:00:37Z sow $ */

/* Address Map and Others */
#define SECTOR_SIZE            (512)
#define ADDR_DECODE_POS        (15)
#define ADDR_DECODE_ACTIVE     (0xF8000)
#define ADDR_DECODE(addr)      (((addr) & ADDR_DECODE_ACTIVE) >> ADDR_DECODE_POS)
#define COMMAND_SERIAL_ENABLE  (0x15)
#define COMMAND_READ_A_BYTE    (0x16)
#define COMMAND_WRITE_A_BYTE   (0x17)
#define COMMAND_WRITE_A_SECTOR (0x18)
#define COMMAND_TEST_SRAM      (0x19)
#define COMMAND_TOGGLE_IRQ     (0x1A)
#define COMMAND_SET_H_MIRROR   (0x1B)
#define COMMAND_SET_V_MIRROR   (0x1C)
#define COMMAND_SPI_ENABLE     (0x1D)
#define COMMAND_SPI_DISABLE    (0x1E)
#define COMMAND_BLANK_FUNCTION (0x1F)


/* MapperZeroAir powered by ESP32 DevKitC */
/* $Id: MapperZeroAir.ino 1561 2023-12-17 03:00:37Z sow $ */
/*

                           +--------------+
          |-        |3p3V  |              |GND   |-        |
          |-        |EN    |     ESP32    |GPIO23|-        |D0
          |-        |GPI36 |              |GPIO22|-        |D1
          |-        |GPI39 |              |GPIO1 |-        |
          |-        |GPI34 |              |GPIO3 |-        |
          |-        |GPI35 |              |GPIO21|-        |D2
IRQx      |-        |GPIO32|              |GND   |-        |
VMIRRORx  |-        |GPIO33|              |GPIO19|-        |D3
WEx       |-        |GPIO25|              |GPIO18|-        |D4
EX_ADRENx |-        |GPIO26| ESP32DevKitC |GPIO5 |-        |D5
OEx       |-        |GPIO27|              |GPIO17|-        |D6
SPI_SCK   |HSPI CLK |GPIO14|              |GPIO16|-        |D7
          |HSPI MISO|GPIO12|              |GPIO4 |-        |FC_ADRENx
          |-        |GND   |              |GPIO0 |-        |ADRCKH
SPI_MOSI  |HSPI MOSI|GPIO13|              |GPIO2 |-        |ADRCHL
          |-        |GPIO9 |              |GPIO15|HSPI SS  |SPI_SSx
          |-        |GPIO10|              |GPIO8 |-        |
          |-        |GPIO11|              |GPIO7 |-        |
          |-        |5V    |      USB     |GPIO6 |-        |
                           +--------------+
*/

#include <stdint.h>
#include <string.h>
#include "MapperZeroAir.h"

#define APP_NAME              "MapperZeroAir.ino"
#define DEFAULT_SERIAL_ENABLE (0)
#define DEBUG_MODE            (0) /* COMMAND Interpreter via Bluetooth */
#define DEBUG_LEVEL           (LOW)

#include "driver/spi_slave.h"
#include <Arduino.h>
#include <SPI.h>
#include "BluetoothSerial.h"
BluetoothSerial bts;

/* Connect between Serial and printf */
#define PRINTF_BUFF_SIZE (128)
#define Serial_printf(...) do{\
  if(isSerialEnabled){\
    char buff[PRINTF_BUFF_SIZE] = {0}; \
    sprintf(buff, __VA_ARGS__); \
    buff[PRINTF_BUFF_SIZE-1] = 0; \
    Serial.print(buff); \
  }\
}while(0)
static boolean isSerialEnabled = false;

/* I/O Definition */
#define D0        (23)
#define D1        (22)
#define D2        (21)
#define D3        (19)
#define D4        (18)
#define D5        (5)
#define D6        (17)
#define D7        (16)
#define WEx       (25)
#define OEx       (27)
#define ADRCKL    (2)
#define ADRCKH    (0)
#define EX_ADRENx (26)
#define FC_ADRENx (4)
#define IRQx      (32)
#define VMIRRORx  (33)
#define SPI_SSx   (15)
#define SPI_SCK   (14)
#define SPI_MOSI  (13)

/* Not Connected */
#define NC        (99)

/* Receive Buffer Size */
#define RCV_BUFF_SIZE (4)

/* For Iterations */
#define CONTROL_PIN_NUM     (sizeof(controlPinList)/sizeof(OUT_PIN_DEF_T))
#define CONTROL_PIN_NUM_MAX (CONTROL_PIN_NUM - 1)
#define DATA_PIN_NUM        (sizeof(dataPinList)/sizeof(int))
#define DATA_PIN_NUM_MAX    (DATA_PIN_NUM - 1)

/* I/O Control Macro */
#define ASSERT_ADRCKL()      digitalWrite(ADRCKL,    HIGH);delayMicroseconds(1);
#define DEASSERT_ADRCKL()    digitalWrite(ADRCKL,    LOW); delayMicroseconds(1);
#define ASSERT_ADRCKH()      digitalWrite(ADRCKH,    HIGH);delayMicroseconds(1);
#define DEASSERT_ADRCKH()    digitalWrite(ADRCKH,    LOW); delayMicroseconds(1);
#define ASSERT_EX_ADRENx()   digitalWrite(EX_ADRENx, LOW); delayMicroseconds(1);
#define DEASSERT_EX_ADRENx() digitalWrite(EX_ADRENx, HIGH);delayMicroseconds(1);
#define ASSERT_FC_ADRENx()   digitalWrite(FC_ADRENx, LOW); delayMicroseconds(1);
#define DEASSERT_FC_ADRENx() digitalWrite(FC_ADRENx, HIGH);delayMicroseconds(1);
#define ASSERT_WEx()         digitalWrite(WEx,       LOW); delayMicroseconds(1);
#define DEASSERT_WEx()       digitalWrite(WEx,       HIGH);delayMicroseconds(1);
#define ASSERT_OEx()         digitalWrite(OEx,       LOW); delayMicroseconds(1);
#define DEASSERT_OEx()       digitalWrite(OEx,       HIGH);delayMicroseconds(1);
#define ASSERT_IRQx()        digitalWrite(IRQx,      LOW); delayMicroseconds(1);
#define DEASSERT_IRQx()      digitalWrite(IRQx,      HIGH);delayMicroseconds(1);
#define ASSERT_MIRROR()      digitalWrite(VMIRRORx,  LOW); delayMicroseconds(1);
#define DEASSERT_MIRROR()    digitalWrite(VMIRRORx,  HIGH);delayMicroseconds(1);
#define IRQx_PULSE_WIDTH_US  (100)
#define TOGGLE_ADRCKL()      ASSERT_ADRCKL();  DEASSERT_ADRCKL()
#define TOGGLE_ADRCKH()      ASSERT_ADRCKH();  DEASSERT_ADRCKH()
#define TOGGLE_WEx()         ASSERT_WEx();     DEASSERT_WEx()
#define TOGGLE_IRQx()        ASSERT_IRQx(); delayMicroseconds(IRQx_PULSE_WIDTH_US); DEASSERT_IRQx()

/* Receive Resource */
static uint8_t spi_slave_rx_buf;
static boolean volatile spi_slave_is_queueing;
static boolean spi_slave_is_received;
static boolean spi_slave_bridge_enable;

/* HSPI(SPI Slave) */
static const uint8_t SPI_SLAVE_CS   = SPI_SSx;
static const uint8_t SPI_SLAVE_CLK  = SPI_SCK;
static const uint8_t SPI_SLAVE_MOSI = SPI_MOSI;
static spi_slave_transaction_t      spi_slave_trans;
static spi_slave_interface_config_t spi_slave_cfg;
static spi_bus_config_t             spi_slave_bus;
void spi_slave_trans_done(spi_slave_transaction_t* trans)
{
  spi_slave_is_queueing = false;
  spi_slave_is_received = true;
}
void spi_slave_init()
{
  spi_slave_is_queueing = false;
  spi_slave_is_received = false;
  spi_slave_rx_buf = 0;
  spi_slave_bridge_enable = false;
  spi_slave_trans.length        = 8; /* bit */
  spi_slave_trans.rx_buffer     = &spi_slave_rx_buf;
  spi_slave_trans.tx_buffer     = NULL;
  spi_slave_cfg.spics_io_num    = SPI_SLAVE_CS;
  spi_slave_cfg.flags           = 0;
  spi_slave_cfg.queue_size      = 1;
  spi_slave_cfg.mode            = SPI_MODE1; /* SPI_MODE1(CPOL=positive, CPHA=posgedge) */
  spi_slave_cfg.post_setup_cb   = NULL;
  spi_slave_cfg.post_trans_cb   = spi_slave_trans_done;
  spi_slave_bus.sclk_io_num     = SPI_SLAVE_CLK;
  spi_slave_bus.mosi_io_num     = SPI_SLAVE_MOSI;
  spi_slave_bus.miso_io_num     = -1;
  spi_slave_bus.quadwp_io_num   = -1;
  spi_slave_bus.quadhd_io_num   = -1;
  ESP_ERROR_CHECK(
    spi_slave_initialize(HSPI_HOST, &spi_slave_bus, &spi_slave_cfg, SPI_DMA_DISABLED)
  );
}

typedef struct outPinDef{
  int pin;
  int defOut;
} OUT_PIN_DEF_T;

const OUT_PIN_DEF_T controlPinList[] = {
  {OEx,       HIGH},
  {WEx,       HIGH},
  {ADRCKL,    LOW},
  {ADRCKH,    LOW},
  {EX_ADRENx, HIGH},
  {FC_ADRENx, LOW},
  {IRQx,      HIGH},
  {VMIRRORx,  HIGH}, /* LOW='V-MIRROR' / HIGH='H-MIRROR' */
};

const int dataPinList[] = {
  D0,
  D1,
  D2,
  D3,
  D4,
  D5,
  D6,
  D7,
};

const int addrListL[] = {
  11, /* D0 : A11 */
  9,  /* D1 : A9  */
  8,  /* D2 : A8  */
  13, /* D3 : A13 */
  14, /* D4 : A14 */
  12, /* D5 : A12 */
  7,  /* D6 : A7  */
  6,  /* D7 : A6  */
};

const int addrListH[] = {
  0,  /* D0 : A0  */
  1,  /* D1 : A1  */
  2,  /* D2 : A2  */
  3,  /* D3 : A3  */
  4,  /* D4 : A4  */
  5,  /* D5 : A5  */
  10, /* D6 : A10 */
  NC, /* D7 : -   */
};

void setData(uint8_t data){
  int i;
  for(i = 0; i < DATA_PIN_NUM; i++){
    digitalWrite(dataPinList[i], ((data >> i) & 1));
  }
}

void setAddr(uint32_t addr, uint8_t hl){
  int i;
  const int *addrList;
  addrList = (hl == LOW) ? addrListL : addrListH;
  for(i = 0; i < DATA_PIN_NUM; i++){
    if(addrList[i] != NC){
      digitalWrite(dataPinList[i], ((addr >> addrList[i]) & 1));
    }
  }
}

void setDataDirection(int direction){
  int pin;
  for(pin = DATA_PIN_NUM_MAX; pin >= 0; pin--){
    pinMode(dataPinList[pin], direction);
  }
}

void writeToSram(uint32_t addr, uint8_t data){
  DEASSERT_FC_ADRENx();
    setDataDirection(OUTPUT);
    setAddr(addr, LOW);
    TOGGLE_ADRCKL();
    setAddr(addr, HIGH);
    TOGGLE_ADRCKH();
    ASSERT_EX_ADRENx();
      setData(data);
      TOGGLE_WEx();
    DEASSERT_EX_ADRENx();
    setDataDirection(INPUT);
  ASSERT_FC_ADRENx();
}

void writeToSramSector(uint32_t addr){
  uint32_t a;
  uint8_t v;
  uint8_t sum;
  sum = 0;
  for(a = addr; a < addr + SECTOR_SIZE; a++){
    while(1){
      if(bts.available()){
        v = bts.read();
        writeToSram(a, v);
        if(DEBUG_LEVEL == HIGH){Serial_printf("writeToSramSector(0x%05X, 0x%02X)\n", a, v);}
        break;
      }
    }
    sum = sum + v;
  }
  bts.write(sum);
}

/* Test SRAM */
#define FILL_PATTERN_1 (0x55)
#define FILL_PATTERN_2 (0xAA)
#define NUM_OF_DATA_LINE (8)
#define NUM_OF_ADDR_LINE (15)
int testSram(void){
  int isFailed = false;
  int isMatched = false;
  uint32_t addr;
  uint32_t targetAddr;
  uint8_t ref;
  uint8_t data;
  int8_t bitPos;
  int8_t targetBitPos;
  /* test data lines */
  addr = 0x0000;
  for(bitPos = 0; bitPos < NUM_OF_DATA_LINE; bitPos++){
    ref = 1 << bitPos;
    writeToSram(addr, ref);
    readFromSram(addr, &data);
    isMatched = (ref == data) ? true : false;
    Serial_printf("testSram(): addr=0x%04X ref=0x%02X data=0x%02X ... %s\n",
                               addr,       ref,       data, (isMatched) ? "PASS" : "FAILED");
    if(isMatched == false){
      isFailed = true;
    }
  }
  /* test addr lines */
  for(bitPos = 0; bitPos < NUM_OF_ADDR_LINE; bitPos++){
    targetAddr = 1 << bitPos;
    writeToSram(targetAddr, FILL_PATTERN_1);
  }
  for(targetBitPos = 0; targetBitPos < NUM_OF_ADDR_LINE; targetBitPos++){
    targetAddr = 1 << targetBitPos;
    writeToSram(targetAddr, FILL_PATTERN_2);
    for(bitPos = 0; bitPos < NUM_OF_ADDR_LINE; bitPos++){
      addr = 1 << bitPos;
      ref = (addr  == targetAddr) ? FILL_PATTERN_2 : FILL_PATTERN_1;
      readFromSram(addr, &data);
      isMatched = (ref == data) ? true : false;
      Serial_printf("testSram(): addr=0x%04X ref=0x%02X data=0x%02X ... %s\n",
                                 addr,       ref,       data, (isMatched) ? "PASS" : "FAILED");
      if(isMatched == false){
        isFailed = true;
      }
    }
    writeToSram(targetAddr, FILL_PATTERN_1);
  }
  return isFailed;
}

void getData(uint8_t *data){
  int i;
  *data = 0;
  for(i = 0; i < DATA_PIN_NUM; i++){
    *data |= ((digitalRead(dataPinList[i]) == LOW) ? 0 : 1) << i;
  }
}

void readFromSram(uint32_t addr, uint8_t *data){
  DEASSERT_FC_ADRENx();
    setDataDirection(OUTPUT);
    setAddr(addr, LOW);
    TOGGLE_ADRCKL();
    setAddr(addr, HIGH);
    TOGGLE_ADRCKH();
    ASSERT_EX_ADRENx();
    setDataDirection(INPUT);
    ASSERT_OEx();
    getData(data);
    DEASSERT_OEx();
    DEASSERT_EX_ADRENx();
  ASSERT_FC_ADRENx();
}

void toggleIRQ(void){
  TOGGLE_IRQx();
}

/* Ring Buffer */
/*
 * 1st Byte ... {1'b1, ADR[6:0]
 * 2nd Byte ... {1'b1, ADR[13:7]
 * 3rd Byte ... {1'b1, DATA[0], ADR[19:14]
 * 4th Byte ... {1^b0, DATA[7:1]}
 */
#define PROTOCOL_MASK              (0x80)
#define PROTOCOL_MASKED_REF_4TH    (0x00)
#define PROTOCOL_MASKED_REF_OTHERS (0x80)
#define RING_BUFF_SIZE (4)
#define ringBuffIncIdx() (ringBuffIdx = (((ringBuffIdx + 1) == sizeof(ringBuff)/sizeof(uint8_t)) ? 0 : (ringBuffIdx + 1)))
uint8_t ringBuff[RING_BUFF_SIZE];
uint8_t ringBuffIdx;
boolean establishedProtocl(void){
  int i;
  int ref;
  for(i = 0; i < RING_BUFF_SIZE; i++){
    switch(i){
      case 3:
        ref = PROTOCOL_MASKED_REF_4TH;
        break;
      case 2: /* As same as default */
      case 1: /* As same as default */
      default:
        ref = PROTOCOL_MASKED_REF_OTHERS;
        break;
    }
    if((ringBuff[(ringBuffIdx + i) % RING_BUFF_SIZE] & PROTOCOL_MASK) != ref){
      return false;
    }
  }
  return true;
}
void ringBuffDecode(uint32_t *addr, uint8_t *data){
  *addr = 0;
  *addr |= (ringBuff[(ringBuffIdx + 0) % RING_BUFF_SIZE] & 0x7F) << 0;
  *addr |= (ringBuff[(ringBuffIdx + 1) % RING_BUFF_SIZE] & 0x7F) << 7;
  *addr |= (ringBuff[(ringBuffIdx + 2) % RING_BUFF_SIZE] & 0x3F) << 14;
  *data = 0;
  *data |= (ringBuff[(ringBuffIdx + 2) % RING_BUFF_SIZE] & 0x40) >> 6;
  *data |= (ringBuff[(ringBuffIdx + 3) % RING_BUFF_SIZE] & 0x7F) << 1;
}
boolean isProtocolReset(void){
  int i;
  for(i = 0; i < RING_BUFF_SIZE; i++){
    if(!(ringBuff[(ringBuffIdx + i) % RING_BUFF_SIZE] & PROTOCOL_MASK)){
      return false;
    }
  }
  return true;
}

void serialEnable(){
  if(!isSerialEnabled){
    Serial.begin(9600);
    Serial.println();
    isSerialEnabled = true;
  }
  /* Show Revision */
  char versionString[] = "$Rev: 1561 $";
  versionString[strlen(versionString)-1] = 0;
  Serial_printf("%s %s\n----\n", APP_NAME, &versionString[1]);
}

void setup(){
  int pin;
  for(pin = CONTROL_PIN_NUM_MAX; pin >= 0; pin--){
    pinMode(controlPinList[pin].pin, OUTPUT);
    digitalWrite(controlPinList[pin].pin, controlPinList[pin].defOut);
  }
  setDataDirection(INPUT);

  /* Initialize Parameters */
  for(ringBuffIdx = sizeof(ringBuff)/sizeof(uint8_t); ringBuffIdx > 0; ringBuffIdx--){
    ringBuff[ringBuffIdx - 1] = 0;
  }

  /* Initialize Bluetooth */
  bts.begin("MapperZeroAir");

#if DEFAULT_SERIAL_ENABLE
  serialEnable();
#endif /* DEFAULT_SERIAL_ENABLE */

  /* Initialize SPI Slave */
  spi_slave_init();
}

#if DEBUG_MODE
#define COMMAND_BUFF_SIZE (64)
#define STRLEN_XETXXXX             (strlen("XetXXXX"))
#define STRLEN_XETXXXX_0xXXXX      (strlen("XetXXXX(0xXXXX"))
#define STRLEN_XETXXXX_0xXXXX_HIGH (strlen("XetXXXX(0xXXXX, HIGH"))
#define STRLEN_XETXXXX_0xXXXX_LOW  (strlen("XetXXXX(0xXXXX, LOW"))
#define STRLEN_XETXXXX_0xXX        (strlen("XetXXXX(0xXX"))
#define ARGPOS_XETXXXX_1ST         (strlen("XetXXXX("))
#define ARGPOS_XETXXXX_0xXXXX_2ND  (strlen("XetXXXX(0xXXXX, "))
char command_buff[COMMAND_BUFF_SIZE];
char single_char_buff;
int command_buff_idx;
void loop(){
  /* Bluetooth loop function */
  if(bts.available()){
    single_char_buff = bts.read();
    if(DEBUG_LEVEL == HIGH){Serial_printf("Received: %02X\n", single_char_buff);}
    if(single_char_buff == 0x0D){
      /* There is no action */
    }else
    if(single_char_buff == 0x0A){
      int execute = 0;
      command_buff[command_buff_idx] = 0;
      command_buff_idx = 0;
      if(DEBUG_LEVEL == HIGH){Serial_printf("LINE: %s\n", command_buff);}
      do{ /* Control via Bluetooth by Command string */
        if(strcmp(command_buff, "ASSERT_ADRCKL")            == 0){Serial_printf("%s\n", command_buff); execute = 1; ASSERT_ADRCKL();          break;}
        if(strcmp(command_buff, "DEASSERT_ADRCKL")          == 0){Serial_printf("%s\n", command_buff); execute = 1; DEASSERT_ADRCKL();        break;}
        if(strcmp(command_buff, "ASSERT_ADRCKH")            == 0){Serial_printf("%s\n", command_buff); execute = 1; ASSERT_ADRCKH();          break;}
        if(strcmp(command_buff, "DEASSERT_ADRCKH")          == 0){Serial_printf("%s\n", command_buff); execute = 1; DEASSERT_ADRCKH();        break;}
        if(strcmp(command_buff, "ASSERT_EX_ADRENx")         == 0){Serial_printf("%s\n", command_buff); execute = 1; ASSERT_EX_ADRENx();       break;}
        if(strcmp(command_buff, "DEASSERT_EX_ADRENx")       == 0){Serial_printf("%s\n", command_buff); execute = 1; DEASSERT_EX_ADRENx();     break;}
        if(strcmp(command_buff, "ASSERT_FC_ADRENx")         == 0){Serial_printf("%s\n", command_buff); execute = 1; ASSERT_FC_ADRENx();       break;}
        if(strcmp(command_buff, "DEASSERT_FC_ADRENx")       == 0){Serial_printf("%s\n", command_buff); execute = 1; DEASSERT_FC_ADRENx();     break;}
        if(strcmp(command_buff, "ASSERT_OEx")               == 0){Serial_printf("%s\n", command_buff); execute = 1; ASSERT_OEx();             break;}
        if(strcmp(command_buff, "DEASSERT_OEx")             == 0){Serial_printf("%s\n", command_buff); execute = 1; DEASSERT_OEx();           break;}
        if(strcmp(command_buff, "ASSERT_WEx")               == 0){Serial_printf("%s\n", command_buff); execute = 1; ASSERT_WEx();             break;}
        if(strcmp(command_buff, "DEASSERT_WEx")             == 0){Serial_printf("%s\n", command_buff); execute = 1; DEASSERT_WEx();           break;}
        if(strcmp(command_buff, "setDataDirection(OUTPUT)") == 0){Serial_printf("%s\n", command_buff); execute = 1; setDataDirection(OUTPUT); break;}
        if(strcmp(command_buff, "setDataDirection(INPUT)")  == 0){Serial_printf("%s\n", command_buff); execute = 1; setDataDirection(INPUT);  break;}
        if(strcmp(command_buff, "serialEnable()")           == 0){Serial_printf("%s\n", command_buff); execute = 1; serialEnable();           break;}
        command_buff[STRLEN_XETXXXX] = 0;             /* setAddr, setData, getData */
        command_buff[STRLEN_XETXXXX_0xXXXX] = 0;      /* terminate of 1st argument */
        command_buff[STRLEN_XETXXXX_0xXXXX_HIGH] = 0; /* terminate of 2nd argument */
        if(strcmp(command_buff, "setAddr") == 0){     /* setAddr(0x****, <HIGH|LOW>) */
          uint32_t addr;
          addr = strtol(&command_buff[ARGPOS_XETXXXX_1ST], NULL, 16);
          if(strcmp(&command_buff[ARGPOS_XETXXXX_0xXXXX_2ND], "HIGH") == 0){
            Serial_printf("setAddr(0x%04X, HIGH)\n", addr);
            execute = 1;
            setAddr(addr, HIGH);
            break;
          }
          command_buff[STRLEN_XETXXXX_0xXXXX_LOW] = 0;
          addr = strtol(&command_buff[ARGPOS_XETXXXX_1ST], NULL, 16);
          if(strcmp(&command_buff[ARGPOS_XETXXXX_0xXXXX_2ND], "LOW") == 0){
            Serial_printf("setAddr(0x%04X, LOW)\n", addr);
            execute = 1;
            setAddr(addr, LOW);
            break;
          }
        }
        if(strcmp(command_buff, "setData") == 0){ /* setData(0x**) */
          uint8_t data;
          command_buff[STRLEN_XETXXXX_0xXX] = 0; /* terminate of 1st argument */
          data = strtol(&command_buff[ARGPOS_XETXXXX_1ST], NULL, 16);
          Serial_printf("setData(0x%02X)\n", data);
          execute = 1;
          setData(data);
          break;
        }
        if(strcmp(command_buff, "getData") == 0){ /* getData() */
          uint8_t data;
          getData(&data);
          execute = 1;
          Serial_printf("getData(data)\n");
          Serial_printf("*data is 0x%02X.\n", data);
          break;
        }
      }while(0);
      if(execute == 0){
        Serial_printf("A command was ignored.\n");
      }
    }else{
      command_buff[command_buff_idx] = single_char_buff;
      command_buff_idx++;
    }
  }
}

#else /* DEBUG_MODE */
void loop(){
  /* SPI Slave loop function */
  if(!spi_slave_is_queueing){
    if(spi_slave_is_received){
      Serial_printf("%c", spi_slave_rx_buf);
      if(spi_slave_bridge_enable){
        bts.write(spi_slave_rx_buf);
      }
    }
    spi_slave_is_queueing = true;
    ESP_ERROR_CHECK(
      spi_slave_queue_trans(HSPI_HOST, &spi_slave_trans, portMAX_DELAY)
    );
  }

  /* Bluetooth loop function */
  if(bts.available()){
    ringBuff[ringBuffIdx] = bts.read();
    if(DEBUG_LEVEL == HIGH){Serial_printf("Received: %02X\n", ringBuff[ringBuffIdx]);}
    ringBuffIncIdx();
    if(establishedProtocl()){
      uint32_t addr;
      uint8_t data;
      ringBuffDecode(&addr, &data);
      if(DEBUG_LEVEL == HIGH){
        Serial_printf(
          "Decoded: %02X %02X %02X %02X : %08X %02X\n",
          ringBuff[0], ringBuff[1], ringBuff[2], ringBuff[3], addr, data
        );
      }
      Serial_printf("DECODED(addr) is 0x%02X\n", ADDR_DECODE(addr));
      switch(ADDR_DECODE(addr)){
        case COMMAND_READ_A_BYTE:
          readFromSram(addr, &data);
          Serial_printf("readFromSram(0x%05X, &data), data is 0x%02X\n", addr, data);
          break;
        case COMMAND_WRITE_A_BYTE:
          bts.write(data);
          writeToSram(addr, data);
          Serial_printf("writeToSram(0x%05X, 0x%02X)\n", addr, data);
          break;
        case COMMAND_WRITE_A_SECTOR:
          bts.write(COMMAND_WRITE_A_SECTOR);
          writeToSramSector(addr);
          break;
        case COMMAND_TEST_SRAM:
          Serial_printf("testSram()\n");
          bts.write(testSram() ? ~COMMAND_TEST_SRAM : COMMAND_TEST_SRAM);
          break;
        case COMMAND_TOGGLE_IRQ:
          Serial_printf("toggleIRQ(0x%02X)\n", COMMAND_TOGGLE_IRQ);
          bts.write(COMMAND_TOGGLE_IRQ);
          toggleIRQ();
          break;
        case COMMAND_SET_V_MIRROR:
          Serial_printf("setVMirror(0x%02X)\n", COMMAND_SET_V_MIRROR);
          bts.write(COMMAND_SET_V_MIRROR);
          ASSERT_MIRROR();
          break;
        case COMMAND_SET_H_MIRROR:
          Serial_printf("setHMirror(0x%02X)\n", COMMAND_SET_H_MIRROR);
          bts.write(COMMAND_SET_H_MIRROR);
          DEASSERT_MIRROR();
          break;
        case COMMAND_BLANK_FUNCTION:
          Serial_printf("blankFunction(0x%02X)\n", COMMAND_BLANK_FUNCTION);
          bts.write(COMMAND_BLANK_FUNCTION);
          break;
        case COMMAND_SPI_ENABLE:
          Serial_printf("spiEnable(0x%02X)\n", COMMAND_SPI_ENABLE);
          bts.write(COMMAND_SPI_ENABLE);
          spi_slave_bridge_enable = true;
          break;
        case COMMAND_SPI_DISABLE:
          Serial_printf("spiDisable(0x%02X)\n", COMMAND_SPI_DISABLE);
          bts.write(COMMAND_SPI_DISABLE);
          spi_slave_bridge_enable = false;
          break;
        case COMMAND_SERIAL_ENABLE:
          Serial_printf("serialEnable(0x%02X)\n", COMMAND_SERIAL_ENABLE);
          bts.write(COMMAND_SERIAL_ENABLE);
          serialEnable();
          break;
        default:
          Serial_printf("0x%05X is unmapped address.\n", addr);
          break;
      }
    }
  }
}

#endif /* DEBUG_MODE */

/* $Id: MapperZeroAir.c 2169 2025-11-02 22:20:38Z sow $ */

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <conio.h>
#include <MapperZeroAir.h>

/* CONFIG */
#define APP_NAME         "MapperZeroAir.exe"
#define DCB_DEBUG        FALSE
#define DCB_BAUDRATE     115200
#define DCB_BYTESIZE     8
#define DCB_STOPBITS     TWOSTOPBITS        
#define DCB_PARITY       EVENPARITY
#define DCB_FOUTXCTSFLOW FALSE
#define DCB_FOUTXDSRFLOW FALSE
#define DCB_FRTSCONTROL  RTS_CONTROL_ENABLE
#define DCB_FDTRCONTROL  DTR_CONTROL_ENABLE

/* FOR BCD DEBUG */
#define DCB_PARITY2STRING(val) \
  (val == NOPARITY)   ? "NOPARITY" : \
  (val == EVENPARITY) ? "EVENPARITY" : \
  (val == ODDPARITY)  ? "ODDPARITY" : \
                        "UNKNOWN"
#define DCB_FOUTXCTSFLOW2STRING(val) \
  (val == TRUE)  ? "TRUE" : \
  (val == FALSE) ? "FALSE" : \
                   "UNKNOWN"
#define DCB_FOUTXDSRFLOW2STRING(val) \
  (val == TRUE)  ? "TRUE" : \
  (val == FALSE) ? "FALSE" : \
                   "UNKNOWN"
#define DCB_FRTSCONTROL2STRING(val) \
  (val == RTS_CONTROL_ENABLE)  ? "RTS_CONTROL_ENABLE" : \
  (val == RTS_CONTROL_DISABLE) ? "RTS_CONTROL_DISABLE" : \
                                 "UNKNOWN"
#define DCB_FDTRCONTROL2STRING(val) \
  (val == DTR_CONTROL_ENABLE)  ? "DTR_CONTROL_ENABLE" : \
  (val == DTR_CONTROL_DISABLE) ? "DTR_CONTROL_DISABLE" : \
                                 "UNKNOWN"
void printDCB(DCB *dcb){
  printf("dcb.BaudRate     = %lu\n", dcb->BaudRate);
  printf("dcb.ByteSize     = %d\n",  dcb->ByteSize);
  printf("dcb.StopBits     = %d\n",  dcb->StopBits);
  printf("dcb.Parity       = %s\n",  DCB_PARITY2STRING(dcb->Parity));
  printf("dcb.fOutxCtsFlow = %s\n",  DCB_FOUTXCTSFLOW2STRING(dcb->fOutxCtsFlow));
  printf("dcb.fOutxDsrFlow = %s\n",  DCB_FOUTXDSRFLOW2STRING(dcb->fOutxDsrFlow));
  printf("dcb.fRtsControl  = %s\n",  DCB_FRTSCONTROL2STRING(dcb->fRtsControl));
  printf("dcb.fDtrControl  = %s\n",  DCB_FDTRCONTROL2STRING(dcb->fDtrControl));
  fflush(stdout);
}

/* Methods */
uint8_t sendByte(const HANDLE hComm, const char sendData){
  DWORD RWNUM;
  WriteFile(
    hComm,            /* hFile */
    &sendData,        /* lpBuffer */
    sizeof(sendData), /* nNumberOfBytesToWrite */
    &RWNUM,           /* lpNumberOfBytesWritten */
    NULL              /* lpOverlapped */
  );
  if(RWNUM != sizeof(sendData)){
    printf("ERROR: WriteFile()'s lpNumberOfBytesWritten didn't match expectation. (in %s)\n", __func__);
    return EXIT_FAILURE;
  }else{
    return EXIT_SUCCESS;
  }
}
uint8_t sendSector(const HANDLE hComm, const uint8_t *sendData){
  DWORD RWNUM;
  WriteFile(
    hComm,       /* hFile */
    sendData,    /* lpBuffer */
    SECTOR_SIZE, /* nNumberOfBytesToWrite */
    &RWNUM,      /* lpNumberOfBytesWritten */
    NULL         /* lpOverlapped */
  );
  if(RWNUM != SECTOR_SIZE){
    printf("ERROR: WriteFile()'s lpNumberOfBytesWritten didn't match expectation. (in %s)\n", __func__);
    return EXIT_FAILURE;
  }else{
    return EXIT_SUCCESS;
  }
}
uint8_t writeByte(const HANDLE hComm, const uint32_t addr, const uint8_t data){
  char buff;
  int i;
  for(i = 0; i < 4; i++){
    switch(i){
      case  0: buff = 0x80 | ((addr >>  0) & 0x7F); break;
      case  1: buff = 0x80 | ((addr >>  7) & 0x7F); break;
      case  2: buff = 0x80 | ((addr >> 14) & 0x3F) | ((data << 6) & 0x40); break;
      default: buff = data >> 1; break;
    }
    if(sendByte(hComm, buff) == EXIT_FAILURE){
      return EXIT_FAILURE;
    }
  }
  return EXIT_SUCCESS;
}
void receiveByteSynchronous(const HANDLE hComm, char * const receiveData){
  DWORD dwErrors;
  COMSTAT ComStat;
  DWORD RWNUM;
  while(1){
    ClearCommError(hComm, &dwErrors, &ComStat);
    if(ComStat.cbInQue){
      ReadFile(
        hComm,       /* hFile */
        receiveData, /* lpBuffer */
        1,           /* nNumberOfBytesToRead */
        &RWNUM,      /* lpNumberOfBytesRead */
        NULL         /* lpOverlapped */
      );
      if(RWNUM != 1){
        printf("ERROR: ReadFile()'s lpNumberOfBytesRead didn't match expectation. (in %s)\n", __func__);
      }
      break;
    }
  }
}
uint8_t receiveByteAsynchronous(const HANDLE hComm, char * const receiveData){
  DWORD dwErrors;
  COMSTAT ComStat;
  DWORD RWNUM;
  ClearCommError(hComm, &dwErrors, &ComStat);
  if(ComStat.cbInQue){
    ReadFile(
      hComm,       /* hFile */
      receiveData, /* lpBuffer */
      1,           /* nNumberOfBytesToRead */
      &RWNUM,      /* lpNumberOfBytesRead */
      NULL         /* lpOverlapped */
    );
    if(RWNUM != 1){
      printf("ERROR: ReadFile()'s lpNumberOfBytesRead didn't match expectation. (in %s)\n", __func__);
      return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
  }
  return EXIT_FAILURE;
}
uint8_t protocolReset(const HANDLE hComm){
  uint8_t sdata[SECTOR_SIZE];
  uint8_t data;
  uint32_t addr;
  char buff;
  memset(sdata, 0xFF, SECTOR_SIZE);
  if(sendSector(hComm, sdata) == EXIT_FAILURE){
    return EXIT_FAILURE;
  }
  addr = COMMAND_BLANK_FUNCTION << ADDR_DECODE_POS;
  data = 0x00; /* Don't care */
  if(writeByte(hComm, addr, data) == EXIT_FAILURE){
    return EXIT_FAILURE;
  }
  do{
    receiveByteSynchronous(hComm, &buff);
  }while(COMMAND_BLANK_FUNCTION != buff);
  return EXIT_SUCCESS;
}

/* BinUtil */
#define ROM_ADDR_OFFSET (0x8000)
#define mapperHL2mapper(H,L) (((H)&0xF0)|(((L)&0xF0)>>4))
#define mapperL2mirror(L)    ((L)&0x01)
typedef struct struct_tag{
  uint8_t nes[4];
  uint8_t prg_num_of_16k;
  uint8_t chr_num_of_8k;
  uint8_t mapperL_and_mirror;
  uint8_t mapperH;
  uint8_t ignore[8];
} ines_header_t;
int readInesHeader(char *fname, uint8_t *header, uint8_t *prgKb, uint8_t *chrKb, uint8_t *mapper, uint8_t *isVmirror){
  ines_header_t *ines_header = (ines_header_t *)header;
  if( (ines_header->nes[0] != 'N') ||
      (ines_header->nes[1] != 'E') ||
      (ines_header->nes[2] != 'S') ||
      (ines_header->nes[3] != 0x1A) ){
    printf("ERROR: '%s' is not a nes file.\n", fname);
    return EXIT_FAILURE;
  }
  *prgKb = ines_header->prg_num_of_16k * 16;
  *chrKb = ines_header->chr_num_of_8k * 8;
  *mapper = mapperHL2mapper(ines_header->mapperH, ines_header->mapperL_and_mirror);
  *isVmirror = mapperL2mirror(ines_header->mapperL_and_mirror);
  return EXIT_SUCCESS;
}
void printNesHeaderSummary(uint8_t prgKb, uint8_t chrKb, uint8_t mapper, uint8_t isVmirror){
  printf("NES PRG-ROM size = %d[KB]\n", prgKb);
  printf("NES CHR-ROM size = %d[KB]\n", chrKb);
  printf("NES Mapper       = #%d\n", mapper);
  printf("NES Mirror       = %c\n", (isVmirror) ? 'V' : 'H');
}
int loadNesFile(char *fname, char *prg, char *chr, uint8_t *chrKb, uint8_t *isVmirror){
  FILE *fi;
  uint32_t fname_length;
  /* Confirm the file name */
  fname_length = strlen(fname);
  if(fname_length < strlen(".nes")){
    printf("ERROR: File '%s' is too short. The file extension must be '.nes'.\n", fname);
    return EXIT_FAILURE;
  }
  if(_stricmp(&fname[fname_length-strlen(".nes")], ".nes") != 0){
    printf("ERROR: The file extension must be '.nes'. ('%s' didn't matched.)\n", fname);
    return EXIT_FAILURE;
  }
  /* fopen() */
  fi = fopen(fname, "rb");
  if(fi == NULL){
    printf("ERROR: Can't open a file '%s'.\n", fname);
    return EXIT_FAILURE;
  }
  {
    uint8_t header[sizeof(ines_header_t)];
    uint8_t prgKb;
    uint8_t mapper;
    /* Confirm header */
    if(fread(header, sizeof(ines_header_t), 1 ,fi) != 1){
      printf("ERROR: Failed to read nes header from '%s'.\n", fname);
      fclose(fi);
      return EXIT_FAILURE;
    }
    if(readInesHeader(fname, header, &prgKb, chrKb, &mapper, isVmirror)){
      fclose(fi);
      return EXIT_FAILURE;
    }
    printNesHeaderSummary(prgKb, *chrKb, mapper, *isVmirror);
    if((mapper != 0) && (mapper != 2)){
      printf("ERROR: mapper #%d in NES file header is not supported.\n", mapper);
      fclose(fi);
      return EXIT_FAILURE;
    }
    if((prgKb != 16) && (prgKb != 32)){
      printf("ERROR: PRG-ROM size %d[KB] in NES file header is not supported.\n", prgKb);
      fclose(fi);
      return EXIT_FAILURE;
    }
    if(!(((mapper == 2) && (*chrKb == 0)) || ((mapper == 0) && (*chrKb == 8)))){
      printf("ERROR: CHR-ROM size %d[KB] in NES file header is not supported for mapper #%d.\n", *chrKb, mapper);
      fclose(fi);
      return EXIT_FAILURE;
    }
    /* Load PRG-ROM */
    {
      if(fread(prg,  1024, prgKb ,fi) != prgKb){
        printf("ERROR: Failed to read PRG-ROM image from '%s'.\n", fname);
        fclose(fi);
        return EXIT_FAILURE;
      }
      if(prgKb == 16){
        memcpy(&prg[prgKb * 1024], prg, prgKb * 1024);
      }
      if(*chrKb != 0){
        if(fread(chr,  1024, *chrKb ,fi) != *chrKb){
          printf("ERROR: Failed to read CHR-ROM image from '%s'.\n", fname);
          fclose(fi);
          return EXIT_FAILURE;
        }
      }
    }
  }
  fclose(fi);
  return EXIT_SUCCESS;
}

/* CHR-ROM Loader */
const char loaderBin[] = {
                    /*      ; $Id: MapperZeroAir.c 2169 2025-11-02 22:20:38Z sow $ */
                    /*      ;---------------------------------------------------- */
                    /*      ; INES HEADER                                         */
                    /*       .inesprg 2 ; PRG-ROM size (16kByte x n)              */
                    /*       .ineschr 0 ; CHR-ROM size (8kByte x n)               */
                    /*       .inesmir 0 ; 0:H-Mirror 1:V-Mirror                   */
                    /*       .inesmap 2 ; Mapper#2                                */
                    /*                                                            */
                    /*      ; HARDWARE REGISTER                                   */
                    /*      ; ----                                                */
                    /*      PPUCNT0     EQU $2000                                 */
                    /*      PPUCNT1     EQU $2001                                 */
                    /*      PPUSTAT     EQU $2002                                 */
                    /*      PPUADDR     EQU $2006                                 */
                    /*      PPUIO       EQU $2007                                 */
                    /*      DMC_FLAGS   EQU $4010                                 */
                    /*      SPECIO2     EQU $4017                                 */
                    /*                                                            */
                    /*      ; BIT FIELDS                                          */
                    /*      ; ----                                                */
                    /*      SelectNameTable0 EQU $00 ; PPUCNT0                    */
                    /*      PpuAddrIncSize1  EQU $00 ; PPUCNT0                    */
                    /*      SprPatTblAdr0000 EQU $00 ; PPUCNT0                    */
                    /*      ScrPatTblAdr0000 EQU $00 ; PPUCNT0                    */
                    /*      SprSize8x8       EQU $00 ; PPUCNT0                    */
                    /*      DisNmiAtHitSpr0  EQU $00 ; PPUCNT0                    */
                    /*      DisNmiAtVBlank   EQU $00 ; PPUCNT0                    */
                    /*      EnaNmiAtVBlank   EQU $80 ; PPUCNT0                    */
                    /*      Color            EQU $00 ; PPUCNT1                    */
                    /*      DisBgClip        EQU $02 ; PPUCNT1                    */
                    /*      DisSprClip       EQU $04 ; PPUCNT1                    */
                    /*      DisBgDisplay     EQU $00 ; PPUCNT1                    */
                    /*      EnaBgDisplay     EQU $08 ; PPUCNT1                    */
                    /*      DisSprDisplay    EQU $00 ; PPUCNT1                    */
                    /*      EnaSprDisplay    EQU $10 ; PPUCNT1                    */
                    /*      BgColorGray      EQU $00 ; PPUCNT1                    */
                    /*      BgColorRed       EQU $80 ; PPUCNT1                    */
                    /*      DisDmaIrq        EQU $00 ; DMC_FLAGS                  */
                    /*      DisFrameCountIrq EQU $C0 ; SPECIO2                    */
                    /*                                                            */
                    /*      ; USER DEFINE                                         */
                    /*      DisNMI           EQU (DisNmiAtVBlank | DisNmiAtHitSpr0 | SprSize8x8 | ScrPatTblAdr0000 | SprPatTblAdr0000 | PpuAddrIncSize1 | SelectNameTable0) */
                    /*      EnaNMI           EQU (EnaNmiAtVBlank | DisNmiAtHitSpr0 | SprSize8x8 | ScrPatTblAdr0000 | SprPatTblAdr0000 | PpuAddrIncSize1 | SelectNameTable0) */
                    /*      DisDisplay       EQU (BgColorGray | DisSprDisplay | DisBgDisplay | DisSprClip | DisBgClip | Color) */
                    /*      EnaDisplay       EQU (BgColorRed  | EnaSprDisplay | EnaBgDisplay | DisSprClip | DisBgClip | Color) */
                    /*      TurnOffLED       EQU $FE                              */
                    /*      TurnOnLED        EQU $FF                              */
                    /*                                                            */
                    /*      ; USER MEMORY                                         */
                    /*      ZP_ADDR          EQU $00                              */
                    /*      ZP_ADDR_L        EQU $00                              */
                    /*      ZP_ADDR_H        EQU $01                              */
                    /*      ZP_BACKUP_L      EQU $01C0                            */
                    /*      ZP_BACKUP_H      EQU $01C1                            */
                    /*      WORK_L           EQU $01C2                            */
                    /*      WORK_M           EQU $01C3                            */
                    /*      WORK_H           EQU $01C4                            */
                    /*      RAM_PRG_ADDR     EQU $01D0                            */
                    /*      LED_PORT         EQU $6000                            */
                    /*                                                            */
                    /*      ; CHR-ROM                                             */
                    /*          .bank 0                                           */
                    /*          .org $8000                                        */
                    /*      CHR_BIN:                                              */
                    /*                                                            */
                    /*      ; PRG-ROM                                             */
                    /*          .bank 3                                           */
                    /*          .org $FF3E                                        */
                    /*      IRQ_VEC:                                              */
                    /*      RST_VEC:                                              */
  0x78,             /* FF3E:    sei                                               */
  0xD8,             /* FF3F:    cld                                               */
  0xA2, 0xFF,       /* FF40:    ldx #$FF                                          */
  0x9A,             /* FF42:    txs                                               */
  0x20, 0xC7, 0xFF, /* FF43:    jsr WAIT_NEXT_VBLANK                              */
  0xA9, 0x00,       /* FF46:    lda #DisNMI                                       */
  0x8D, 0x00, 0x20, /* FF48:    sta PPUCNT0                                       */
  0xA9, 0x06,       /* FF4B:    lda #DisDisplay                                   */
  0x8D, 0x01, 0x20, /* FF4D:    sta PPUCNT1                                       */
                    /*      LED_OFF:                                              */
  0xA9, 0xFE,       /* FF50:    lda #TurnOffLED                                   */
  0x8D, 0x00, 0x60, /* FF52:    sta LED_PORT                                      */
                    /*      BACKUP_ZP:                                            */
  0xA5, 0x00,       /* FF55:    lda <ZP_ADDR_L                                    */
  0x8D, 0xC0, 0x01, /* FF57:    sta ZP_BACKUP_L                                   */
  0xA5, 0x01,       /* FF5A:    lda <ZP_ADDR_H                                    */
  0x8D, 0xC1, 0x01, /* FF5C:    sta ZP_BACKUP_H                                   */
                    /*      FILL_CHR_ROM                                          */
  0xA9, 0x00,       /* FF5F:    lda #low(CHR_BIN)                                 */
  0x85, 0x00,       /* FF61:    sta <ZP_ADDR_L                                    */
  0xA9, 0x80,       /* FF63:    lda #high(CHR_BIN)                                */
  0x85, 0x01,       /* FF65:    sta <ZP_ADDR_H                                    */
  0xA0, 0x00,       /* FF67:    ldy #$00                                          */
  0xA2, 0x00,       /* FF69:    ldx #$00                                          */
                    /*      FILL_CHR_ROM_0:                                       */
  0x20, 0xC7, 0xFF, /* FF6B:    jsr WAIT_NEXT_VBLANK                              */
  0x8E, 0x06, 0x20, /* FF6E:    stx PPUADDR                                       */
  0x8C, 0x06, 0x20, /* FF71:    sty PPUADDR                                       */
                    /*      FILL_CHR_ROM_1:                                       */
  0xB1, 0x00,       /* FF74:    lda [ZP_ADDR],y                                   */
  0x8D, 0x07, 0x20, /* FF76:    sta PPUIO                                         */
  0xC8,             /* FF79:    iny                                               */
  0x98,             /* FF7A:    tya                                               */
  0x29, 0x3F,       /* FF7B:    and #$3F                                          */
  0xD0, 0xF5,       /* FF7D:    bne FILL_CHR_ROM_1                                */
  0x98,             /* FF7F:    tya                                               */
  0xD0, 0xE9,       /* FF80:    bne FILL_CHR_ROM_0                                */
  0xE6, 0x01,       /* FF82:    inc <ZP_ADDR_H                                    */
  0xE8,             /* FF84:    inx                                               */
  0xE0, 0x20,       /* FF85:    cpx #$20                                          */
  0xD0, 0xE2,       /* FF87:    bne FILL_CHR_ROM_0                                */
  0x20, 0xC7, 0xFF, /* FF89:    jsr WAIT_NEXT_VBLANK                              */
                    /*      STORE_ZP:                                             */
  0xAD, 0xC0, 0x01, /* FF8C:    lda ZP_BACKUP_L                                   */
  0x85, 0x00,       /* FF8F:    sta <ZP_ADDR_L                                    */
  0xAD, 0xC1, 0x01, /* FF91:    lda ZP_BACKUP_H                                   */
  0x85, 0x01,       /* FF94:    sta <ZP_ADDR_H                                    */
                    /*      COPY_WAIT_AND_RESET:                                  */
  0xA0, 0x25,       /* FF96:    ldy #$25 ; Size of WAIT_AND_RESET                 */
  0xA2, 0x00,       /* FF98:    ldx #$00                                          */
                    /*      COPY_WAIT_AND_RESET_LOOP:                             */
  0xBD, 0xD4, 0xFF, /* FF9A:    lda WAIT_AND_RESET,x                              */
  0x9D, 0xD0, 0x01, /* FF9D:    sta RAM_PRG_ADDR,x                                */
  0xE8,             /* FFA0:    inx                                               */
  0x88,             /* FFA1:    dey                                               */
  0xD0, 0xF6,       /* FFA2:    bne COPY_WAIT_AND_RESET_LOOP                      */
                    /*      LED_ON:                                               */
  0xA9, 0xFF,       /* FFA4:    lda #TurnOnLED                                    */
  0x8D, 0x00, 0x60, /* FFA6:    sta LED_PORT                                      */
                    /*      MAIN_CLOSING:                                         */
  0xA9, 0x00,       /* FFA9:    lda #$00                                          */
  0x8D, 0xC2, 0x01, /* FFAB:    sta WORK_L                                        */
  0x8D, 0xC3, 0x01, /* FFAE:    sta WORK_M                                        */
  0x8D, 0xC4, 0x01, /* FFB1:    sta WORK_H                                        */
  0xA9, 0x9E,       /* FFB4:    lda #EnaDisplay                                   */
  0x8D, 0x01, 0x20, /* FFB6:    sta PPUCNT1                                       */
  0xA9, 0x00,       /* FFB9:    lda #DisDmaIrq                                    */
  0x8D, 0x10, 0x40, /* FFBB:    sta DMC_FLAGS                                     */
  0xA9, 0xC0,       /* FFBE:    lda #DisFrameCountIrq                             */
  0x8D, 0x17, 0x40, /* FFC0:    sta SPECIO2                                       */
  0x58,             /* FFC3:    cli                                               */
  0x4C, 0xD0, 0x01, /* FFC4:    jmp RAM_PRG_ADDR                                  */
                    /*                                                            */
                    /*      WAIT_NEXT_VBLANK:                                     */
  0x48,             /* FFC7:    pha                                               */
                    /*      WAIT_NEXT_VBLANK_0:                                   */
  0xAD, 0x02, 0x20, /* FFC8:    lda PPUSTAT                                       */
  0x10, 0xFB,       /* FFCB:    bpl WAIT_NEXT_VBLANK_0                            */
                    /*      WAIT_NEXT_VBLANK_1:                                   */
  0xAD, 0x02, 0x20, /* FFCD:    lda PPUSTAT                                       */
  0x30, 0xFB,       /* FFD0:    bmi WAIT_NEXT_VBLANK_1                            */
  0x68,             /* FFD2:    pla                                               */
  0x60,             /* FFD3:    rts                                               */
                    /*                                                            */
                    /*      WAIT_AND_RESET:                                       */
  0x18,             /* FFD4:    clc                                               */
  0xA9, 0x01,       /* FFD5:    lda #$01                                          */
  0x6D, 0xC2, 0x01, /* FFD7:    adc WORK_L                                        */
  0x8D, 0xC2, 0x01, /* FFDA:    sta WORK_L                                        */
  0xA9, 0x00,       /* FFDD:    lda #$00                                          */
  0x6D, 0xC3, 0x01, /* FFDF:    adc WORK_M                                        */
  0x8D, 0xC3, 0x01, /* FFE2:    sta WORK_M                                        */
  0xA9, 0x00,       /* FFE5:    lda #$00                                          */
  0x6D, 0xC4, 0x01, /* FFE7:    adc WORK_H                                        */
  0x8D, 0xC4, 0x01, /* FFEA:    sta WORK_H                                        */
  0xC9, 0x0E,       /* FFED:    cmp #$0E                                          */
  0xD0, 0xE3,       /* FFEF:    bne WAIT_AND_RESET                                */
  0xA9, 0xFE,       /* FFF1:    lda #TurnOffLED                                   */
  0x8D, 0x00, 0x60, /* FFF3:    sta LED_PORT                                      */
  0x6C, 0xFC, 0xFF, /* FFF6:    jmp [RST_VECTOR]                                  */
                    /*                                                            */
                    /*      NMI_VEC:                                              */
  0x40,             /* FFF9:    rti                                               */
                    /*          .bank 3                                           */
                    /*          .org $FFFA                                        */
                    /*      NMI_VECOTR:                                           */
  0xF9, 0xFF,       /* FFFA:    .dw NMI_VEC                                       */
                    /*      RST_VECTOR:                                           */
  0x3E, 0xFF,       /* FFFC:    .dw RST_VEC                                       */
                    /*      IRQ_VECTOR:                                           */
  0x3E, 0xFF,       /* FFFE:    .dw IRQ_VEC                                       */
};

/* MapperZeroAirUtil */
int MapperZeroAir_Send32Kb(HANDLE hComm, char *buff32Kb){
  uint32_t addr;
  uint8_t data;
  uint8_t *sdata;
  char buff;
  uint8_t sum;
  int i;
  int j;

  addr = COMMAND_WRITE_A_SECTOR << ADDR_DECODE_POS;
  data = 0x00;
  for(j = 0; j < 32 * 1024; j += SECTOR_SIZE){
    sdata = (uint8_t *)&buff32Kb[j];

    /* Send Command */
    if(writeByte(hComm, addr, data) == EXIT_FAILURE){
      printf("ERROR: Failed to Sector Write.\n");
      return EXIT_FAILURE;
    }else{
      do{
        receiveByteSynchronous(hComm, &buff);
      }while(COMMAND_WRITE_A_SECTOR != buff);
    }
  
    /* Send Raw Data */
    if(sendSector(hComm, sdata) == EXIT_FAILURE){
      printf("ERROR: Failed to Write sector datas.\n");
      return EXIT_FAILURE;
    }else{
      sum = 0;
      for(i = 0; i < SECTOR_SIZE; i++){
        sum += sdata[i];
      }
      receiveByteSynchronous(hComm, &buff);
      if(sum != (uint8_t)buff){
        printf("Received checksum 0x%02X is not equal 0x%02X.\n", (uint8_t)buff, sum);
        fflush(stdout);
        return EXIT_FAILURE;
      }else{
        printf("Successed to write from 0x%04X to 0x%04X.\r",
          (addr & 0x7FFF) + 0x8000,
          (addr & 0x7FFF) + 0x8000 + SECTOR_SIZE - 1);
        fflush(stdout);
      }
    }
  
    addr += SECTOR_SIZE;
  }
  printf("Successed to write from 0x8000 to 0xFFFF.\n");
  fflush(stdout);
  return EXIT_SUCCESS;
}

/* ComUtil */
int setupCommHundler(HANDLE *hComm, char *com){
  #define BUFF_SIZE 16
  char dev_name[(BUFF_SIZE)];
  char dev_prefix[] = "\\\\.\\";
  DCB dcb;

  /* Generate Device Name */
  if(sizeof(dev_prefix) + strlen(com) > (BUFF_SIZE)){
    printf("ERROR: COM port '%s' is too long.\n", com);
    return EXIT_FAILURE;
  }
  if(sprintf(dev_name, "%s%s", dev_prefix, com) < 0){
    printf("ERROR: sprintf() return a value less than zero.\n");
    return EXIT_FAILURE;
  }

  /* Open a Device */
  *hComm = CreateFile(
    dev_name,                     /* lpFileName */
    GENERIC_READ | GENERIC_WRITE, /* dwDesiredAccess */
    0,                            /* dwShareMode */
    NULL,                         /* lpSecurityAttributes */
    OPEN_EXISTING,                /* dwCreationDisposition */
    FILE_ATTRIBUTE_NORMAL,        /* dwFlagsAndAttributes */
    NULL                          /* hTemplateFile */
  ); 
  if(INVALID_HANDLE_VALUE == *hComm){
    printf("ERROR: CreateFile() return INVALID_HANDLE_VALUE.\n");
    return EXIT_FAILURE;
  }
  
  /* Device configuration */
  GetCommState(*hComm, &dcb);
  dcb.BaudRate     = DCB_BAUDRATE;
  dcb.ByteSize     = DCB_BYTESIZE;
  dcb.StopBits     = DCB_STOPBITS;
  dcb.Parity       = DCB_PARITY;
  dcb.fOutxCtsFlow = DCB_FOUTXCTSFLOW;
  dcb.fOutxDsrFlow = DCB_FOUTXDSRFLOW;
  dcb.fRtsControl  = DCB_FRTSCONTROL;
  dcb.fDtrControl  = DCB_FDTRCONTROL;
  SetCommState(*hComm, &dcb);
#if DCB_DEBUG
  printDCB(&dcb);
#endif /* DCB_DEBUG */

  return EXIT_SUCCESS;
}

/* ApplicationUtil */
void showUsage(void){
  printf("Usage1 : %s <COMn> <FILE> [--irq]\n", APP_NAME);
  printf("Usage2 : %s <COMn> --spi\n", APP_NAME);
  printf("    COMn ... Bluetooth COM port for connecting to MapperZeroAir.\n");
  printf("    FILE ... .nes file formated as mapper #0 or #2.\n");
}

/* Applications */
int execDownload(int argc, char *argv[]){
  uint8_t irqEnable;
  HANDLE hComm;
  char buff;
  uint32_t addr;
  uint8_t data;
  char *buff32Kb;
  char *buff8Kb;
  uint8_t chrKb;
  uint8_t isVmirror;

  /* Confirm Arguments */
  irqEnable = 0;
  if(argc == 4){
    if(strcmp(argv[3], "--irq") == 0){
      irqEnable = 1;
    }else{
      printf("ERROR: Unknown option '%s'.\n", argv[3]);
      return EXIT_FAILURE;
    }
  }

  /* Malloc for PRG-ROM */
  buff32Kb = (char *)malloc(32 * 1024);
  if(buff32Kb == NULL){
    printf("ERROR: Failed to malloc(%d) for PRG-ROM.\n", 32 * 1024);
    return EXIT_FAILURE;
  }
  buff8Kb = (char *)malloc(8 * 1024);
  if(buff8Kb == NULL){
    printf("ERROR: Failed to malloc(%d) for CHR-ROM.\n", 8 * 1024);
    free(buff32Kb);
    return EXIT_FAILURE;
  }
  if(loadNesFile(argv[2], buff32Kb, buff8Kb, &chrKb, &isVmirror)){
    free(buff32Kb);
    free(buff8Kb);
    return EXIT_FAILURE;
  }

  /* Open a Device */
  if(setupCommHundler(&hComm, argv[1])){
    free(buff32Kb);
    free(buff8Kb);
    return EXIT_FAILURE;
  }

  /* Protocol Reset */
  if(protocolReset(hComm) == EXIT_FAILURE){
    printf("ERROR: Failed to protocol reset.\n");
    CloseHandle(hComm);
    free(buff32Kb);
    free(buff8Kb);
    return EXIT_FAILURE;
  }else{
    printf("Protocol was reset.\n");
    fflush(stdout);
  }

  /* Send IRQ to Copy Program to SRAM and run Program on SRAM */
  if(irqEnable){
    addr = COMMAND_TOGGLE_IRQ << ADDR_DECODE_POS;
    data = 0x00; /* Don't care */
    if(writeByte(hComm, addr, data) == EXIT_FAILURE){
      printf("ERROR: Failed to toggle IRQ.\n");
      CloseHandle(hComm);
      free(buff32Kb);
      free(buff8Kb);
      return EXIT_FAILURE;
    }else{
      do{
        receiveByteSynchronous(hComm, &buff);
      }while(COMMAND_TOGGLE_IRQ != buff);
      printf("IRQ request was accepted.\n");
      fflush(stdout);
    }
  }

  /* Send buff32Kb for CHR-ROM loader */
  if(chrKb != 0){
    char *buff32Kb_loader;
    buff32Kb_loader = (char *)malloc(32 * 1024);
    if(buff32Kb_loader == NULL){
      printf("ERROR: Failed to malloc(%d) for CHR-ROM loader.\n", 32 * 1024);
      return EXIT_FAILURE;
    }
    memcpy(buff32Kb_loader, buff8Kb, chrKb * 1024);
    memcpy(&buff32Kb_loader[(0xFF3E)-ROM_ADDR_OFFSET], loaderBin, sizeof(loaderBin));
    if(MapperZeroAir_Send32Kb(hComm, buff32Kb_loader) == EXIT_FAILURE){
      CloseHandle(hComm);
      free(buff32Kb_loader);
      free(buff8Kb);
      return EXIT_FAILURE;
    }
  }

  /* Execute CHR-ROM loader */
  if(chrKb != 0){
    int8_t i;
    /* Send IRQ to Execute CHR-ROM loader */
    if(irqEnable){
      addr = COMMAND_TOGGLE_IRQ << ADDR_DECODE_POS;
      data = 0x00; /* Don't care */
      if(writeByte(hComm, addr, data) == EXIT_FAILURE){
        printf("ERROR: Failed to toggle IRQ.\n");
        CloseHandle(hComm);
        free(buff32Kb);
        free(buff8Kb);
        return EXIT_FAILURE;
      }else{
        do{
          receiveByteSynchronous(hComm, &buff);
        }while(COMMAND_TOGGLE_IRQ != buff);
        printf("IRQ request was accepted.\n");
        fflush(stdout);
      }
    }
    /* Request reset to Execute CHR-ROM loader */
    else{
      printf("CAUTION: Please reset Family Computer to run CHR-ROM loader.\n");
      for(i = 3; i >= 0; i--){ 
        printf("Release reset button after %d sec.\r", i);
        fflush(stdout);
        if(i){
          sleep(1);
        }else{
          printf("\n");
        }
      }
    }
    /* Wait to complete loading CHR-ROM */
    for(i = 3; i >= 0; i--){ 
      printf("Waiting rest %d sec to finish loading CHR-ROM.\r", i);
      fflush(stdout);
      if(i){
        sleep(1);
      }else{
        printf("\n");
      }
    }
  }

  /* Send buff32Kb for PRG-ROM */
  if(MapperZeroAir_Send32Kb(hComm, buff32Kb) == EXIT_FAILURE){
    CloseHandle(hComm);
    free(buff32Kb);
    free(buff8Kb);
    return EXIT_FAILURE;
  }

  /* Set V_MIRROR / H_MIRROR */
  if(isVmirror){
    addr = COMMAND_SET_V_MIRROR << ADDR_DECODE_POS;
  }else{
    addr = COMMAND_SET_H_MIRROR << ADDR_DECODE_POS;
  }
  data = 0x00; /* Don't care */
  if(writeByte(hComm, addr, data) == EXIT_FAILURE){
    printf("ERROR: Failed to set V_MIRROR/H_MIRROR.\n");
    CloseHandle(hComm);
    free(buff32Kb);
    free(buff8Kb);
    return EXIT_FAILURE;
  }else{
    do{
      receiveByteSynchronous(hComm, &buff);
    }while((isVmirror ? COMMAND_SET_V_MIRROR : COMMAND_SET_H_MIRROR) != buff);
    printf("%c_MIRROR request was accepted.\n", isVmirror ? 'V' : 'H');
    fflush(stdout);
  }

  /* Send IRQ to Reboot */
  if(irqEnable){
    addr = COMMAND_TOGGLE_IRQ << ADDR_DECODE_POS;
    data = 0x00; /* Don't care */
    if(writeByte(hComm, addr, data) == EXIT_FAILURE){
      printf("ERROR: Failed to toggle IRQ.\n");
      CloseHandle(hComm);
      free(buff32Kb);
      free(buff8Kb);
      return EXIT_FAILURE;
    }else{
      do{
        receiveByteSynchronous(hComm, &buff);
      }while(COMMAND_TOGGLE_IRQ != buff);
      printf("IRQ request was accepted.\n");
      fflush(stdout);
    }
  }

  /* Exit Program */
  CloseHandle(hComm);
  return EXIT_SUCCESS;
}

int execSpi(int argc, char *argv[]){
  HANDLE hComm;
  char buff;
  uint32_t addr;
  uint8_t data;

  /* Show a Message */
  printf("Display data that received via SPI until hit any key.\n");
  fflush(stdout);

  /* Open a Device */
  if(setupCommHundler(&hComm, argv[1])){
    return EXIT_FAILURE;
  }

  /* Send SPI Enable */
  addr = COMMAND_SPI_ENABLE << ADDR_DECODE_POS;
  data = 0x00; /* Don't care */
  if(writeByte(hComm, addr, data) == EXIT_FAILURE){
    printf("ERROR: Failed to SPI Enable.\n");
    CloseHandle(hComm);
    return EXIT_FAILURE;
  }else{
    do{
      receiveByteSynchronous(hComm, &buff);
    }while(COMMAND_SPI_ENABLE != buff);
    printf("SPI Enable was accepted.\n");
    fflush(stdout);
  }

  /* Monitor Mode */
  do{
    if(receiveByteAsynchronous(hComm, &buff) == EXIT_SUCCESS){
      printf("%c", buff);
      fflush(stdout);
    }
  }while(!kbhit());
  getch();

  /* Send SPI Disable */
  addr = COMMAND_SPI_DISABLE << ADDR_DECODE_POS;
  data = 0x00; /* Don't care */
  if(writeByte(hComm, addr, data) == EXIT_FAILURE){
    printf("ERROR: Failed to SPI Disable.\n");
    CloseHandle(hComm);
    return EXIT_FAILURE;
  }else{
    do{
      receiveByteSynchronous(hComm, &buff);
    }while(COMMAND_SPI_DISABLE != buff);
    printf("SPI Disable was accepted.\n");
    fflush(stdout);
  }
  /* Exit Program */
  CloseHandle(hComm);
  return EXIT_SUCCESS;
}

int testSram(int argc, char *argv[]){
  HANDLE hComm;
  uint32_t addr;
  uint8_t data;
  char buff;
  uint8_t testResult;

  /* Show a Message */
  printf("Please install a jumper to connect pin 2 and 3 of J4 on MapperZeroAir for test.\n");
  printf("Then press any key.\n");
  fflush(stdout);
  for(;!kbhit(););
  getch();
  printf("Testing now...\n");
  fflush(stdout);

  /* Open a Device */
  if(setupCommHundler(&hComm, argv[1])){
    return EXIT_FAILURE;
  }

  /* Send a Command to Test Sram */
  addr = COMMAND_TEST_SRAM << ADDR_DECODE_POS;
  data = 0x00; /* Don't care */
  if(writeByte(hComm, addr, data) == EXIT_FAILURE){
    printf("ERROR: Failed to send a command 'sramCheck()'.\n");
    return EXIT_FAILURE;
  }else{
    receiveByteSynchronous(hComm, &buff);
  }
  CloseHandle(hComm);

  /* Report the Result of SRAM Test */
  testResult = (COMMAND_TEST_SRAM != buff) ? EXIT_FAILURE : EXIT_SUCCESS;
  if(testResult == EXIT_SUCCESS){
    printf("testSram() is passed.\n");
  }else{
    printf("testSram() is failed.\n");
  }
  printf("Please install a jumper to connect pin 1 and 2 of J4 on MapperZeroAir as like as default.\n");
  fflush(stdout);
  return testResult;
}

int serialEnable(int argc, char *argv[]){
  HANDLE hComm;
  uint32_t addr;
  uint8_t data;
  char buff;
  /* Open a Device */
  if(setupCommHundler(&hComm, argv[1])){
    return EXIT_FAILURE;
  }
  /* Send a Command to Serial Enable */
  addr = COMMAND_SERIAL_ENABLE << ADDR_DECODE_POS;
  data = 0x00; /* Don't care */
  if(writeByte(hComm, addr, data) == EXIT_FAILURE){
    printf("ERROR: Failed to send a command 'serialEnable()'.\n");
    return EXIT_FAILURE;
  }else{
    do{
      receiveByteSynchronous(hComm, &buff);
    }while(COMMAND_SERIAL_ENABLE != buff);
    printf("Serial Enable was accepted.\n");
    fflush(stdout);
  }
  CloseHandle(hComm);
  return EXIT_SUCCESS;
}

int main(int argc, char *argv[]){
  /* Show Revision */
  char versionString[] = "$Rev: 2169 $";
  versionString[strlen(versionString)-1] = 0;
  printf("%s %s\n----\n", APP_NAME, &versionString[1]);
  fflush(stdout);

  /* Confirm Arguments and Branch Operation */
  if((argc != 3) && (argc != 4)){
    showUsage();
    return EXIT_FAILURE;
  }
  if((argc == 3) && (strcmp(argv[2], "--spi") == 0)){
    return execSpi(argc, argv);
  }else if((argc == 3) && (strcmp(argv[2], "--testSram") == 0)){
    return testSram(argc, argv);
  }else if((argc == 3) && (strcmp(argv[2], "--serialEnable") == 0)){
    return serialEnable(argc, argv);
  }else{
    return execDownload(argc, argv);
  }
}


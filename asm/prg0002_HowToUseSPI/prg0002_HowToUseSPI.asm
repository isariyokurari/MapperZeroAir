; $Id: prg0002_HowToUseSPI.asm 1550 2023-12-16 06:01:32Z sow $

; CONFIG
; ----
FILL_CHR_ROM_EN EQU $01 ; $00...don't fill  $01...fill CHR-ROM
USE_IRQ_LOADER  EQU $01 ; $00...don't use   $01...use
SPI_OUTPUT_EN   EQU $01 ; $00...disable SPI $01...enable SPI

; HEADER
; ----
    .inesprg 1 ; PRG-ROM size (16kByte x n)
    .ineschr 0 ; CHR-ROM size (8kByte x n)
    .inesmir 0 ; 0:H-Mirror 1:V-Mirror
    .inesmap 2 ; Mapper#2

; HARDWARE REGISTER
; ----
PPUCNT0     EQU $2000
PPUCNT1     EQU $2001
PPUSTAT     EQU $2002
SPRADDR     EQU $2003
SPRIO       EQU $2004
BGSCROL     EQU $2005
PPUADDR     EQU $2006
PPUIO       EQU $2007
CH1_REG1    EQU $4000
CH1_REG2    EQU $4001
CH1_REG3    EQU $4002
CH1_REG4    EQU $4003
CH2_REG1    EQU $4004
CH2_REG2    EQU $4005
CH2_REG3    EQU $4006
CH2_REG4    EQU $4007
CH3_REG1    EQU $4008
CH3_REG2    EQU $4009
CH3_REG3    EQU $400A
CH3_REG4    EQU $400B
CH4_REG1    EQU $400C
CH4_REG2    EQU $400D
CH4_REG3    EQU $400E
CH4_REG4    EQU $400F
DMC_FLAGS   EQU $4010
DMC_LOAD    EQU $4011
DMC_ADDR    EQU $4012
DMC_LENGTH  EQU $4013
SPRDMA      EQU $4014
SOUND_ST    EQU $4015
SPECIO1     EQU $4016
SPECIO2     EQU $4017

; BIT FIELDS
; ----
P_Negative  EQU $80
P_Overflow  EQU $40
P_Reserve   EQU $20
P_BRK       EQU $10
P_Decimal   EQU $08
P_DisIRQ    EQU $04
P_Zero      EQU $02
P_Carry     EQU $01
SelectNameTable0 EQU $00 ; PPUCNT0
SelectNameTable1 EQU $01 ; PPUCNT0
SelectNameTable2 EQU $02 ; PPUCNT0
SelectNameTable3 EQU $03 ; PPUCNT0
PpuAddrIncSize1  EQU $00 ; PPUCNT0
PpuAddrIncSize32 EQU $04 ; PPUCNT0
SprPatTblAdr0000 EQU $00 ; PPUCNT0
SprPatTblAdr1000 EQU $08 ; PPUCNT0
ScrPatTblAdr0000 EQU $00 ; PPUCNT0
ScrPatTblAdr1000 EQU $10 ; PPUCNT0
SprSize8x8       EQU $00 ; PPUCNT0
SprSize8x16      EQU $20 ; PPUCNT0
DisNmiAtHitSpr0  EQU $00 ; PPUCNT0
EnaNmiAtHitSpr0  EQU $40 ; PPUCNT0
DisNmiAtVBlank   EQU $00 ; PPUCNT0
EnaNmiAtVBlank   EQU $80 ; PPUCNT0
Color            EQU $00 ; PPUCNT1
Monochrome       EQU $01 ; PPUCNT1
EnaBgClip        EQU $00 ; PPUCNT1
DisBgClip        EQU $02 ; PPUCNT1
EnaSprClip       EQU $00 ; PPUCNT1
DisSprClip       EQU $04 ; PPUCNT1
DisBgDisplay     EQU $00 ; PPUCNT1
EnaBgDisplay     EQU $08 ; PPUCNT1
DisSprDisplay    EQU $00 ; PPUCNT1
EnaSprDisplay    EQU $10 ; PPUCNT1
BgColorGray      EQU $00 ; PPUCNT1
BgColorGreen     EQU $20 ; PPUCNT1
BgColorBlue      EQU $40 ; PPUCNT1
BgColorRed       EQU $80 ; PPUCNT1
InVBlankNow      EQU $80 ; PPUSTAT
SpriteZeroHit    EQU $40 ; PPUSTAT
LineSpriteCount  EQU $20 ; PPUSTAT
PadA             EQU $80 ; SPECIO1 & SPECIO2 (Just for Read)
PadB             EQU $40 ; SPECIO1 & SPECIO2 (Just for Read)
PadSelect        EQU $20 ; SPECIO1 & SPECIO2 (Just for Read)
PadStart         EQU $10 ; SPECIO1 & SPECIO2 (Just for Read)
PadUp            EQU $08 ; SPECIO1 & SPECIO2 (Just for Read)
PadDown          EQU $04 ; SPECIO1 & SPECIO2 (Just for Read)
PadLeft          EQU $02 ; SPECIO1 & SPECIO2 (Just for Read)
PadRight         EQU $01 ; SPECIO1 & SPECIO2 (Just for Read)
EnaDmaIrq        EQU $80 ; DMC_FLAGS
DisDmaIrq        EQU $00 ; DMC_FLAGS
EnaFrameCountIrq EQU $00 ; SPECIO2
DisFrameCountIrq EQU $C0 ; SPECIO2

; USER DEFINE
DisNMI           EQU (DisNmiAtVBlank | DisNmiAtHitSpr0 | SprSize8x8 | ScrPatTblAdr0000 | SprPatTblAdr1000 | PpuAddrIncSize1 | SelectNameTable0)
EnaNMI           EQU (EnaNmiAtVBlank | DisNmiAtHitSpr0 | SprSize8x8 | ScrPatTblAdr0000 | SprPatTblAdr1000 | PpuAddrIncSize1 | SelectNameTable0)
DisDisplay       EQU (BgColorGray | DisSprDisplay | DisBgDisplay | DisSprClip | DisBgClip | Color)
EnaDisplay       EQU (BgColorGray | EnaSprDisplay | EnaBgDisplay | DisSprClip | DisBgClip | Color)

; USER MEMORY
WORK             EQU $00
WORK_L           EQU $00
WORK_H           EQU $01
STACK_ADDR       EQU $0100
SPR_DMA_SRC      EQU $0200
    .if (USE_IRQ_LOADER)   ; USE_IRQ_LOADER
IRQ_SWITCH       EQU $FF   ; USE_IRQ_LOADER
IRQ_PRG_RAM      EQU $0300 ; USE_IRQ_LOADER
    .endif                 ; USE_IRQ_LOADER
SPI_PORT         EQU $6000 ; SPI is assigned to bit [2:0] ([CSx,MOSI,CLK])

; PROGRAM
    .bank 1    ; 2kByte Bank Index Of NES File
    .org $E000 ; 6502 Mapped Address
RST_VEC:
    sei
    cld
    ldx #$FF
    txs
    .if (USE_IRQ_LOADER) ; USE_IRQ_LOADER
    lda #$00             ; USE_IRQ_LOADER
    sta <IRQ_SWITCH      ; USE_IRQ_LOADER
    .endif               ; USE_IRQ_LOADER

    jsr WAIT_NEXT_VBLANK
    lda #DisNMI
    sta PPUCNT0
    lda #DisDisplay
    sta PPUCNT1

; FUNCTION: Copy CHR_BIN to PPU Address $0000-1FFF
    .if (FILL_CHR_ROM_EN)
FILL_CHR_ROM
    lda #low(CHR_BIN)
    sta <WORK_L
    lda #high(CHR_BIN)
    sta <WORK_H
    ldy #$00
    ldx #$00
FILL_CHR_ROM_0:
    jsr WAIT_NEXT_VBLANK
    stx PPUADDR
    sty PPUADDR
FILL_CHR_ROM_1:
    lda [WORK],y
    sta PPUIO
    iny
    tya
    and #$3F
    bne FILL_CHR_ROM_1
    tya
    bne FILL_CHR_ROM_0
    inc <WORK_H
    inx
    cpx #$20
    bne FILL_CHR_ROM_0
    jsr WAIT_NEXT_VBLANK
    .endif

; FUNCTION: Copy PALETTE to PPU Address $3F00-3FFF
LOAD_PALETTE:
    lda #$3F
    sta PPUADDR ; Set VRAM Address HIGH
    lda #$00
    sta PPUADDR ; Set VRAM Address LOW
    ldx #$00
LOAD_PALETTE_LOOP:
    lda PALETTE, x
    sta PPUIO
    inx
    cpx #$20
    bne LOAD_PALETTE_LOOP

; FUNCTION: Fill PPU Address $2000-23BF 
space EQU $20
FILL_NAME_TABLE:
    ldx #$20 ; PPU Address HIGH
    ldy #$00 ; PPU Address LOW
FILL_NAME_TABLE_0:
    tya
    pha
    lda #space ; PPU Write Data
    jsr WAIT_NEXT_VBLANK
    jsr FILL_PPU_64
    pla
    clc
    adc #$40
    tay
    txa
    adc #$00 ; Add carry
    tax
    cpx #$23
    bne FILL_NAME_TABLE_0
    cpy #$C0
    bne FILL_NAME_TABLE_0

; FUNCTION: Fill PPU Address $23C0-23FF 
    ldx #$23 ; Can Comment out if immediately after FILL_NAME_TABLE
    ldy #$C0 ; Can Comment out if immediately after FILL_NAME_TABLE
FILL_ATTRIBUTE_TABLE:
    lda #$00 ; PPU Write Data
    jsr WAIT_NEXT_VBLANK
    jsr FILL_PPU_64

; FUNCTION: Fill 256Byte from SPR_DMA_SRC by #$00
CLEAR_SPR_DMA_SRC:
    ldx #$00
    lda #$FF
CLEAR_SPR_DMA_SRC_LOOP:
    sta SPR_DMA_SRC,x
    inx
    bne CLEAR_SPR_DMA_SRC_LOOP

; FUNCTION: Copy MESSAGE to PPU Address from MsgPpuAddr
MsgPpuAddrFlomH EQU $21
MsgPpuAddrFlomL EQU $C1
DISP_MESSAGE:
    lda #low(MESSAGE)
    sta <WORK_L
    lda #high(MESSAGE)
    sta <WORK_H
DISP_MESSAGE_0:
    jsr WAIT_NEXT_VBLANK
    ldx #MsgPpuAddrFlomH ; PPU ADDR HIGH
    stx PPUADDR
    lda #MsgPpuAddrFlomL ; PPU ADDR LOW
    sta PPUADDR
    ldy #$00
DISP_MESSAGE_1:
    lda [WORK],y
    beq DISP_MESSAGE_END
    sta PPUIO
    iny
    bne DISP_MESSAGE_1
DISP_MESSAGE_END:

MAIN_CLOSING:
    lda #EnaDisplay
    sta PPUCNT1
    lda #EnaNMI
    sta PPUCNT0
    lda #DisDmaIrq
    sta DMC_FLAGS
    lda #DisFrameCountIrq
    sta SPECIO2
    cli
MAIN_INIT:
    lda #$B0
    sta <WORK_L
    lda #$3A
    sta <WORK_H
    jsr SPI_BUS_RESET
MAIN_LOOP:
    jsr SEND_MESSAGE_VIA_SPI
MAIN_LOOP_END:
    jmp MAIN_LOOP

; FUNCTION: Send message 0-9 and 'CR LF' via SPI
; INPUT: WORK_L
; INPUT: WORK_H
; OUTPUT: WORK_L
; OUTPUT: WORK_H
; BROKEN: P A X
; STACK: 2
; CONSTRAINT: WAIT_NEXT_VBLANK and SEND_MESSAGE_EXE are necessary
SEND_MESSAGE_VIA_SPI:
    jsr WAIT_NEXT_VBLANK
    inc <WORK_L
    lda <WORK_L
    lsr a
    lsr a
    lsr a
    lsr a
    and #$0F
    ora #$30
    cmp <WORK_H
    beq SEND_MESSAGE_END
    cmp #$3B
    beq MESSAGE_LOOP
    cmp #$3A
    bne SEND_MESSAGE_EXE
SEND_CR_RL:
    sta <WORK_H
    ldx #$0D
    jsr SPI_SEND_A_BYTE
    ldx #$0A
    jsr SPI_SEND_A_BYTE
    rts
MESSAGE_LOOP:
    lda #$00
    sta <WORK_L
    lda #$30
SEND_MESSAGE_EXE:
    tax
    jsr SPI_SEND_A_BYTE
    sta <WORK_H
SEND_MESSAGE_END:
	rts

    .if (SPI_OUTPUT_EN)                                ; SPI_OUTPUT_EN
SPI_CLK_LOW      EQU %00000000                         ; SPI_OUTPUT_EN
SPI_CLK_HIGH     EQU %00000001                         ; SPI_OUTPUT_EN
SPI_MOSI_LOW     EQU %00000000                         ; SPI_OUTPUT_EN
SPI_MOSI_HIGH    EQU %00000010                         ; SPI_OUTPUT_EN
SPI_CSx_LOW      EQU %00000000                         ; SPI_OUTPUT_EN
SPI_CSx_HIGH     EQU %00000100                         ; SPI_OUTPUT_EN
                                                       ; SPI_OUTPUT_EN
; FUNCTION: SPI Bus Reset                              ; SPI_OUTPUT_EN
; INPUT: None                                          ; SPI_OUTPUT_EN
; OUTPUT: None                                         ; SPI_OUTPUT_EN
; BROKEN: P                                            ; SPI_OUTPUT_EN
; STACK: 1                                             ; SPI_OUTPUT_EN
; CONSTRAINT: None                                     ; SPI_OUTPUT_EN
SPI_BUS_RESET:                                         ; SPI_OUTPUT_EN
    pha                                                ; SPI_OUTPUT_EN
    lda #(SPI_CSx_HIGH + SPI_MOSI_HIGH + SPI_CLK_HIGH) ; SPI_OUTPUT_EN
    sta SPI_PORT                                       ; SPI_OUTPUT_EN
    pla                                                ; SPI_OUTPUT_EN
    rts                                                ; SPI_OUTPUT_EN
                                                       ; SPI_OUTPUT_EN
; FUNCTION: SPI Send a byte                            ; SPI_OUTPUT_EN
; INPUT: X ... Send data                               ; SPI_OUTPUT_EN
; OUTPUT: None                                         ; SPI_OUTPUT_EN
; BROKEN: P                                            ; SPI_OUTPUT_EN
; STACK: 2                                             ; SPI_OUTPUT_EN
; CONSTRAINT: None                                     ; SPI_OUTPUT_EN
SPI_SEND_A_BYTE:                                       ; SPI_OUTPUT_EN
    pha                                                ; SPI_OUTPUT_EN
    txa                                                ; SPI_OUTPUT_EN
    pha                                                ; SPI_OUTPUT_EN
SPI_ITER_INIT:                                         ; SPI_OUTPUT_EN
    lda #$08                                           ; SPI_OUTPUT_EN
    pha                                                ; SPI_OUTPUT_EN
SPI_ASSERT_CS:                                         ; SPI_OUTPUT_EN
    lda #(SPI_CSx_LOW + SPI_MOSI_HIGH + SPI_CLK_HIGH)  ; SPI_OUTPUT_EN
    sta SPI_PORT                                       ; SPI_OUTPUT_EN
SPI_CLK_PRESET:                                        ; SPI_OUTPUT_EN
    and #(SPI_CSx_LOW + SPI_MOSI_HIGH + SPI_CLK_LOW)   ; SPI_OUTPUT_EN
    sta SPI_PORT                                       ; SPI_OUTPUT_EN
    txa                                                ; SPI_OUTPUT_EN
SPI_MOSI_JUDGE:                                        ; SPI_OUTPUT_EN
    and #$80                                           ; SPI_OUTPUT_EN
    beq SPI_MOSI_CLEAR                                 ; SPI_OUTPUT_EN
SPI_MOSI_SET:                                          ; SPI_OUTPUT_EN
    lda #(SPI_CSx_LOW + SPI_MOSI_HIGH + SPI_CLK_LOW)   ; SPI_OUTPUT_EN
    bpl SPI_MOSI_UPDATE                                ; SPI_OUTPUT_EN
SPI_MOSI_CLEAR:                                        ; SPI_OUTPUT_EN
    lda #(SPI_CSx_LOW + SPI_MOSI_LOW  + SPI_CLK_LOW)   ; SPI_OUTPUT_EN
SPI_MOSI_UPDATE:                                       ; SPI_OUTPUT_EN
    sta SPI_PORT                                       ; SPI_OUTPUT_EN
SPI_CLK_SET:                                           ; SPI_OUTPUT_EN
    ora #(SPI_CSx_LOW + SPI_MOSI_LOW  + SPI_CLK_HIGH)  ; SPI_OUTPUT_EN
    sta SPI_PORT                                       ; SPI_OUTPUT_EN
SPI_BIT_LOOP:                                          ; SPI_OUTPUT_EN
    pla                                                ; SPI_OUTPUT_EN
    sec                                                ; SPI_OUTPUT_EN
    sbc #$01                                           ; SPI_OUTPUT_EN
    beq SPI_DEASSERT_CS                                ; SPI_OUTPUT_EN
    pha                                                ; SPI_OUTPUT_EN
    txa                                                ; SPI_OUTPUT_EN
    rol a                                              ; SPI_OUTPUT_EN
    tax                                                ; SPI_OUTPUT_EN
    jmp SPI_CLK_PRESET                                 ; SPI_OUTPUT_EN
SPI_DEASSERT_CS:                                       ; SPI_OUTPUT_EN
    lda #(SPI_CSx_HIGH + SPI_MOSI_HIGH + SPI_CLK_HIGH) ; SPI_OUTPUT_EN
    sta SPI_PORT                                       ; SPI_OUTPUT_EN
    pla                                                ; SPI_OUTPUT_EN
    tax                                                ; SPI_OUTPUT_EN
    pla                                                ; SPI_OUTPUT_EN
    rts                                                ; SPI_OUTPUT_EN
    .else                                              ; SPI_OUTPUT_EN
SPI_BUS_RESET:
    rts
SPI_SEND_A_BYTE:
    rts
    .endif                                             ; SPI_OUTPUT_EN

NMI_VEC:
    pha
    txa
    pha
    tya
    pha
    lda #DisNMI
    sta PPUCNT0
    lda #DisDisplay
    sta PPUCNT1

    lda #high(SPR_DMA_SRC)
    sta SPRDMA

    lda #$00
    sta BGSCROL
    sta BGSCROL

    lda #EnaDisplay
    sta PPUCNT1
    lda #EnaNMI
    sta PPUCNT0

    pla
    tay
    pla
    tax
    pla
    rti

; FUNCTION: Wait next VBLANK
; INPUT: None
; OUTPUT: None
; BROKEN: P
; STACK: 1
; CONSTRAINT: None
; DEPEND: None
; END: rts
WAIT_NEXT_VBLANK:
    pha
WAIT_NEXT_VBLANK_0:
    lda PPUSTAT
    bpl WAIT_NEXT_VBLANK_0
WAIT_NEXT_VBLANK_1:
    lda PPUSTAT
    bmi WAIT_NEXT_VBLANK_1
    pla
    rts

; FUNCTION: Fill 64 Byte in PPU memory mapped
; INPUT: X ... PPU Address HIGH
; INPUT: Y ... PPU Address LOW
; INPUT: A ... PPU Write Data
; OUTPUT: None
; BROKEN: P Y
; STACK: 3
; CONSTRAINT: Execute while VBlank
; DEPEND: None
; END: rts
FILL_PPU_64:
    pha
    txa
    sta PPUADDR
    tya
    sta PPUADDR
    pla
    ldy #$00
FILL_PPU_64_LOOP:
    sta PPUIO
    iny
    cpy #$40
    bne FILL_PPU_64_LOOP
    rts

PALETTE:
black EQU $1d
white EQU $30
blue  EQU $12
red   EQU $16
green EQU $1A
    db red,   green, blue,  white ; Pallet0
    db red,   red,   red,   black ; Pallet1
    db red,   red,   red,   black ; Pallet2
    db red,   red,   red,   black ; Pallet3
    db black, red,   red,   black ; Pallet4
    db red,   red,   red,   black ; Pallet5
    db red,   red,   red,   black ; Pallet6
    db red,   red,   red,   black ; Pallet7

MESSAGE:
    db "Send message to HOST via SPI.", $00

    .if (USE_IRQ_LOADER)       ; USE_IRQ_LOADER
IRQ_VEC:                       ; USE_IRQ_LOADER
    sei                        ; USE_IRQ_LOADER
    cld                        ; USE_IRQ_LOADER
    jsr WAIT_NEXT_VBLANK       ; USE_IRQ_LOADER
    lda #DisNMI                ; USE_IRQ_LOADER
    sta PPUCNT0                ; USE_IRQ_LOADER
    lda #DisDisplay            ; USE_IRQ_LOADER
    sta PPUCNT1                ; USE_IRQ_LOADER
    lda <IRQ_SWITCH            ; USE_IRQ_LOADER
    beq IRQ_VEC_COPY_LOOP_INIT ; USE_IRQ_LOADER
    jmp [RST_VECTOR]           ; USE_IRQ_LOADER
IRQ_VEC_COPY_LOOP_INIT:        ; USE_IRQ_LOADER
    lda #$01                   ; USE_IRQ_LOADER
    sta <IRQ_SWITCH            ; USE_IRQ_LOADER
    ldy #$05 ; 58 A9 00 F0 FE  ; USE_IRQ_LOADER
    ldx #$00                   ; USE_IRQ_LOADER
IRQ_VEC_COPY_LOOP:             ; USE_IRQ_LOADER
    lda WAIT_IRQ,x             ; USE_IRQ_LOADER
    sta IRQ_PRG_RAM,x          ; USE_IRQ_LOADER
    inx                        ; USE_IRQ_LOADER
    dey                        ; USE_IRQ_LOADER
    bne IRQ_VEC_COPY_LOOP      ; USE_IRQ_LOADER
    jmp IRQ_PRG_RAM            ; USE_IRQ_LOADER
WAIT_IRQ:             ;        ; USE_IRQ_LOADER
    cli               ; 58     ; USE_IRQ_LOADER
    lda #$00          ; A9 00  ; USE_IRQ_LOADER
WAIT_IRQ_LOOP         ;        ; USE_IRQ_LOADER
    beq WAIT_IRQ_LOOP ; F0 FE  ; USE_IRQ_LOADER
    .endif                     ; USE_IRQ_LOADER

    .bank 0    ; 2kByte Bank Index Of NES File
    .org $C000 ; 6502 Mapped Address
CHR_BIN:
    .org $C200 ; 6502 Mapped Address
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; (space)
    db $30, $30, $30, $30, $00, $30, $30, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ! 
    db $28, $28, $28, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; " 
    db $28, $28, $fe, $28, $fe, $28, $28, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; # 
    db $28, $fe, $a8, $fe, $2a, $fe, $28, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; $ 
    db $e2, $a4, $e8, $10, $2e, $4a, $8e, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; % 
    db $78, $48, $6a, $12, $6a, $44, $7a, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; & 
    db $30, $10, $20, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ' 
    db $0c, $10, $20, $20, $20, $10, $0c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ( 
    db $30, $08, $04, $04, $04, $08, $30, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ) 
    db $92, $54, $38, $10, $38, $54, $92, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; * 
    db $10, $10, $10, $fe, $10, $10, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; + 
    db $00, $00, $00, $00, $30, $10, $20, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; , 
    db $00, $00, $00, $fe, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; - 
    db $00, $00, $00, $00, $00, $30, $30, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; . 
    db $02, $04, $08, $10, $20, $40, $80, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; / 
    db $7c, $82, $82, $00, $82, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 0 
    db $10, $30, $10, $00, $10, $10, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 1 
    db $7c, $02, $02, $7c, $80, $80, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 2 
    db $7c, $82, $02, $7c, $02, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 3 
    db $04, $84, $84, $84, $7e, $04, $04, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 4 
    db $fc, $80, $80, $7c, $02, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 5 
    db $7c, $80, $80, $7c, $82, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 6 
    db $fc, $82, $02, $0c, $10, $10, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 7 
    db $7c, $82, $82, $7c, $82, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 8 
    db $7c, $82, $82, $7c, $02, $02, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 9 
    db $00, $30, $30, $00, $30, $30, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; : 
    db $00, $30, $30, $00, $30, $10, $20, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ; 
    db $08, $10, $20, $40, $20, $10, $08, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; < 
    db $00, $00, $7c, $00, $7c, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; = 
    db $20, $10, $08, $04, $08, $10, $20, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; > 
    db $3c, $42, $42, $1c, $18, $00, $18, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ? 
    db $7c, $82, $9a, $aa, $bc, $80, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; @
    db $7c, $82, $82, $fe, $82, $82, $82, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; A
    db $fc, $82, $82, $fc, $82, $82, $fc, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; B
    db $7c, $82, $80, $80, $80, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; C
    db $f8, $84, $82, $82, $82, $84, $f8, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; D
    db $fe, $80, $80, $fc, $80, $80, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; E
    db $fe, $80, $80, $fc, $80, $80, $80, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; F
    db $7c, $82, $80, $8e, $82, $82, $7e, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; G
    db $82, $82, $82, $fe, $82, $82, $82, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; H
    db $fe, $10, $10, $10, $10, $10, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; I
    db $7e, $04, $04, $04, $04, $84, $78, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; J
    db $82, $8c, $b0, $c0, $b0, $8c, $82, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; K
    db $40, $40, $40, $40, $40, $40, $7e, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; L
    db $82, $c6, $aa, $aa, $92, $92, $82, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; M
    db $82, $c2, $a2, $92, $92, $8a, $86, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; N
    db $7c, $82, $82, $82, $82, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; O
    db $fc, $82, $82, $82, $fc, $80, $80, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; P
    db $7c, $82, $82, $92, $8a, $84, $7a, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; Q
    db $fc, $82, $82, $fc, $82, $82, $82, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; R
    db $7c, $80, $80, $7c, $02, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; S
    db $fe, $10, $10, $10, $10, $10, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; T
    db $82, $82, $82, $82, $82, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; U
    db $82, $82, $82, $82, $44, $28, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; V
    db $82, $82, $92, $92, $92, $aa, $44, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; W
    db $82, $44, $28, $10, $28, $44, $82, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; X
    db $82, $44, $28, $10, $10, $10, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; Y
    db $fe, $04, $08, $10, $20, $40, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; Z
    db $1e, $10, $10, $10, $10, $10, $1e, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; [
    db $6c, $28, $7c, $10, $7c, $10, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; \
    db $f0, $10, $10, $10, $10, $10, $f0, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ]
    db $10, $28, $44, $82, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ^
    db $00, $00, $00, $00, $00, $00, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; _
    db $20, $10, $08, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; `
    db $00, $00, $fe, $02, $fe, $82, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; a
    db $80, $80, $fe, $82, $82, $82, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; b
    db $00, $00, $fe, $80, $80, $80, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; c
    db $02, $02, $fe, $82, $82, $82, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; d
    db $00, $00, $fe, $82, $fe, $80, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; e
    db $1e, $10, $fe, $10, $10, $10, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; f
    db $00, $00, $fe, $82, $fe, $02, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; g
    db $80, $80, $fe, $82, $82, $82, $82, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; h
    db $10, $00, $10, $10, $10, $10, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; i
    db $02, $00, $02, $02, $02, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; j
    db $80, $80, $86, $98, $e0, $98, $86, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; k
    db $10, $10, $10, $10, $10, $10, $18, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; l
    db $00, $00, $ec, $92, $92, $92, $92, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; m
    db $00, $00, $fc, $82, $82, $82, $82, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; n
    db $00, $00, $7c, $82, $82, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; o
    db $00, $00, $fc, $82, $fc, $80, $80, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; p
    db $00, $00, $7c, $82, $92, $8a, $7e, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; q
    db $00, $00, $8e, $b0, $c0, $80, $80, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; r
    db $00, $00, $fe, $80, $fe, $02, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; s
    db $40, $40, $fe, $40, $40, $40, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; t
    db $00, $00, $82, $82, $82, $82, $7c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; u
    db $00, $00, $82, $82, $44, $28, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; v
    db $00, $00, $92, $92, $92, $92, $6c, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; w
    db $00, $00, $c6, $28, $10, $28, $c6, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; x
    db $00, $00, $82, $82, $7e, $02, $7e, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; y
    db $00, $00, $fe, $0c, $30, $c0, $fe, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; z
    db $06, $08, $08, $10, $08, $08, $06, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; {
    db $10, $10, $10, $00, $10, $10, $10, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; |
    db $c0, $20, $20, $10, $20, $20, $c0, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; }
    db $22, $54, $88, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; ~

; VECTORS
; ----
    .bank 1    ; 2kByte Bank Index Of NES File
    .org $FFFA ; 6502 Mapped Address
NMI_VECOTR:
    .dw NMI_VEC
RST_VECTOR:
    .dw RST_VEC
IRQ_VECTOR:
    .if (USE_IRQ_LOADER) ; USE_IRQ_LOADER
    .dw IRQ_VEC          ; USE_IRQ_LOADER
    .else                ; USE_IRQ_LOADER
    .dw RST_VEC
    .endif               ; USE_IRQ_LOADER


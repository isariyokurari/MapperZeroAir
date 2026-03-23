; $Id: prg0004_WebSwitch.asm 2263 2026-03-23 13:24:31Z sow $

; CONFIG
; ----
FILL_CHR_ROM_EN EQU $01 ; $00...don't fill $01...fill CHR-ROM
USE_IRQ_LOADER  EQU $00 ; $00...don't use  $01...use
SPI_OUTPUT_EN   EQU $01 ; $00...disable SPI $01...enable SPI

; HEADER
; ----
    .inesprg 1 ; PRG-ROM size (16kByte x n)
    .ineschr 0 ; CHR-ROM size (8kByte x n)
    .inesmir 1 ; 0:H-Mirror 1:V-Mirror
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
UpdateSwitch     EQU $30
LedUpdateCycle   EQU $40
BgScrolX         EQU $00 ; BGSCROL
BgScrolY         EQU $E8 ; BGSCROL

; USER MEMORY
WORK             EQU $00
WORK_L           EQU $00
WORK_H           EQU $01
V_BLANK_COUNTER  EQU $02
PAD1_CURRENT     EQU $03
PAD1_CODE        EQU $04
AUTO_RELOAD_EN   EQU $05
LED_PALETTE_EN   EQU $06
LED_STATUS       EQU $07
STACK_ADDR       EQU $0100
SPR_DMA_SRC      EQU $0200
    .if (USE_IRQ_LOADER)   ; USE_IRQ_LOADER
IRQ_SWITCH       EQU $FF   ; USE_IRQ_LOADER
IRQ_PRG_RAM      EQU $0300 ; USE_IRQ_LOADER
    .else
IRQ_SWITCH       EQU $08
    .endif                 ; USE_IRQ_LOADER
PAD1_OLD         EQU $09
PAD1_PRESS       EQU $0A
PAD1_RELEASE     EQU $0B
LOOP_ON_RAM_ADDR EQU $20
SPI_PORT         EQU $6000 ; SPI is assigned to bit [2:0] ([CSx,MOSI,CLK])
SWITCH_STATUS    EQU $FFF8

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
    .else
    lda #$01
    sta <IRQ_SWITCH
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

DRAW_LED:
    ldy (PTN_LED1+0) ; PPU ADDR LOW
    ldx (PTN_LED1+1) ; PPU ADDR HIGH
    sty <WORK_L
    stx <WORK_H
    jsr WAIT_NEXT_VBLANK
    stx PPUADDR       ; PPU ADDR HIGH
    sty PPUADDR       ; PPU ADDR LOW
    ldy #$00
DRAW_LED_LOOP:
    lda PTN_LED1+2,y
    beq DRAW_LED_END
    pha
    sta PPUIO
    iny
    tya
    and #$07
    beq DRAW_LED_SKIP
    pla
    clc
    bcc DRAW_LED_LOOP
DRAW_LED_SKIP:
    lda <WORK_L
    clc
    adc #$20
    sta <WORK_L
    bcc DRAW_LED_SKIP_END
    lda <WORK_H
    adc #$00
    sta <WORK_H
DRAW_LED_SKIP_END:
    tya
    pha
    ldy <WORK_L
    ldx <WORK_H
    stx PPUADDR       ; PPU ADDR HIGH
    sty PPUADDR       ; PPU ADDR LOW
    pla
    tay
    pla
    clc
    bcc DRAW_LED_LOOP
DRAW_LED_END:

DRAW_RELOAD:
    ldy (PTN_RELOAD+0) ; PPU ADDR LOW
    ldx (PTN_RELOAD+1) ; PPU ADDR HIGH
    jsr WAIT_NEXT_VBLANK
    stx PPUADDR       ; PPU ADDR HIGH
    sty PPUADDR       ; PPU ADDR LOW
    ldy #$00
DRAW_RELOAD_LOOP:
    lda PTN_RELOAD+2,y ; y work as lindex
    beq DRAW_RELOAD_END
    sta PPUIO
    iny
    bne DRAW_RELOAD_LOOP
DRAW_RELOAD_END:

DRAW_UASGE:
    ldy (PTN_USAGE+0) ; PPU ADDR LOW
    ldx (PTN_USAGE+1) ; PPU ADDR HIGH
    jsr WAIT_NEXT_VBLANK
    stx PPUADDR       ; PPU ADDR HIGH
    sty PPUADDR       ; PPU ADDR LOW
    ldy #$00
DRAW_USAGE_LOOP:
    lda PTN_USAGE+2,y ; y work as lindex
    beq DRAW_USAGE_END
    sta PPUIO
    iny
    bne DRAW_USAGE_LOOP
DRAW_USAGE_END:

COPY_RAM_CODE:
    ldx #$00
COPY_RAM_CODE_LOOP:
    lda LOOP_ON_RAM,x
    beq COPY_RAM_CODE_END
    sta LOOP_ON_RAM_ADDR,x
    inx
    bne COPY_RAM_CODE_LOOP
COPY_RAM_CODE_END:

INIT_OTHERS:
    lda #$00
    sta <PAD1_CURRENT
    sta <PAD1_OLD
    sta <PAD1_PRESS
    sta <PAD1_RELEASE
    sta <PAD1_CODE
    sta <LED_STATUS
    sta <V_BLANK_COUNTER
    sta <AUTO_RELOAD_EN
    sta <LED_PALETTE_EN
    jsr SPI_BUS_RESET

INIT_CLOSING:
    lda #EnaDisplay
    sta PPUCNT1
    lda #EnaNMI
    sta PPUCNT0
    lda #DisDmaIrq
    sta DMC_FLAGS
    lda #DisFrameCountIrq
    sta SPECIO2
    cli

MAIN_LOOP:
    jsr WAIT_NEXT_VBLANK
    lda #$00
    sta <WORK_L
    lda #$00
    sta <WORK_H
    ldx #$23
    ldy #$21
    jsr DUMP_CPU_MEM_8BYTE
    jsr WAIT_NEXT_VBLANK
    lda #$F8
    sta <WORK_L
    lda #$FF
    sta <WORK_H
    ldx #$23
    ldy #$41
    jsr DUMP_CPU_MEM_8BYTE
    jsr WAIT_NEXT_VBLANK
    jsr UPDATE_PAD1_STATUS
    jsr AUTO_RELOAD
    jsr PAD_PROC
    jmp MAIN_LOOP

; FUNCTION: Force down release when counter is larger than threshold
; INPUT: V_BLANK_COUNTER
; OUTPUT: None
; BROKEN: P, A, X
; STACK: 5
; CONSTRAINT: None
; DEPEND: SPI_SEND_WRAP
AUTO_RELOAD:
    lda <AUTO_RELOAD_EN
    beq AUTO_RELOAD_END
    lda <V_BLANK_COUNTER
    sec
    sbc #LedUpdateCycle
    bmi AUTO_RELOAD_END
    lda #0
    sta <V_BLANK_COUNTER
AUTO_RELOAD_PROC:
    jsr WAIT_NEXT_VBLANK
    lda #DisNMI
    sta PPUCNT0
    ldx #UpdateSwitch
    stx <PAD1_CODE
    jsr SPI_SEND_WRAP
    jsr LOOP_ON_RAM_ADDR
    lda SWITCH_STATUS
    sta <LED_STATUS
    ora #(SPI_CSx_HIGH + SPI_MOSI_HIGH)
    sta SPI_PORT
    jsr WAIT_NEXT_VBLANK
    lda #EnaNMI
    sta PPUCNT0
AUTO_RELOAD_END:
    rts

; FUNCTION: Send PAD CODE via SPI
; INPUT: PAD1_RELEASE
; OUTPUT: PAD1_CODE
; BROKEN: P, A, X
; STACK: 5
; CONSTRAINT: None
; DEPEND: SPI_SEND_WRAP
CODE_FOR_A       EQU $38
CODE_FOR_B       EQU $37
CODE_FOR_SELECT  EQU $36
CODE_FOR_START   EQU $35
CODE_FOR_UP      EQU $34
CODE_FOR_DOWN    EQU $33
CODE_FOR_LEFT    EQU $32
CODE_FOR_RIGHT   EQU $31
PAD_PROC:
    ldy <PAD1_RELEASE
PAD_PROC_A:
    tya
    and #PadA
    beq PAD_PROC_B
    lda #$00
    sta <LED_STATUS
    ldx #CODE_FOR_A
    stx <PAD1_CODE
    jsr SPI_SEND_WRAP
    rts
PAD_PROC_B:
    tya
    and #PadB
    beq PAD_PROC_SELECT
    lda #$01
    sta <LED_STATUS
    ldx #CODE_FOR_B
    stx <PAD1_CODE
    jsr SPI_SEND_WRAP
    rts
PAD_PROC_SELECT:
    tya
    and #PadSelect
    beq PAD_PROC_START
    ldx #CODE_FOR_SELECT
    stx <PAD1_CODE
    jsr SPI_SEND_WRAP
    lda #$01
    eor <AUTO_RELOAD_EN
    sta <AUTO_RELOAD_EN
    jsr DRAW_ON_OFF
    rts
PAD_PROC_START:
    tya
    and #PadStart
    beq PAD_PROC_UP
    ldx #CODE_FOR_START
    stx <PAD1_CODE
    jsr SPI_SEND_WRAP
    lda #$01
    sta <LED_PALETTE_EN
    rts
PAD_PROC_UP:
    tya
    and #PadUp
    beq PAD_PROC_DOWN
    ldx #CODE_FOR_UP
    stx <PAD1_CODE
    jsr SPI_SEND_WRAP
    rts
PAD_PROC_DOWN:
    tya
    and #PadDown
    beq PAD_PROC_LEFT
    jsr WAIT_NEXT_VBLANK
    lda #DisNMI
    sta PPUCNT0
    ldx #CODE_FOR_DOWN
    stx <PAD1_CODE
    jsr SPI_SEND_WRAP
    jsr LOOP_ON_RAM_ADDR
    lda SWITCH_STATUS
    sta <LED_STATUS
    ora #(SPI_CSx_HIGH + SPI_MOSI_HIGH)
    sta SPI_PORT
    jsr WAIT_NEXT_VBLANK
    lda #EnaNMI
    sta PPUCNT0
    rts
PAD_PROC_LEFT:
    tya
    and #PadLeft
    beq PAD_PROC_RIGHT
    ldx #CODE_FOR_LEFT
    stx <PAD1_CODE
    jsr SPI_SEND_WRAP
    rts
PAD_PROC_RIGHT:
    tya
    and #PadRight
    beq PAD_PROC_END
    ldx #CODE_FOR_RIGHT
    stx <PAD1_CODE
    jsr SPI_SEND_WRAP
    rts
PAD_PROC_END:
    rts

; FUNCTION: Draw ON and OFF for AUTO RELOAD
; INPUT: <AUTO_RELOAD_EN
; OUTPUT: None
; BROKEN: P, X, Y
; STACK: 0
; CONSTRAINT: None
DRAW_ON_OFF:
    lda <AUTO_RELOAD_EN
    beq DRAW_OFF
DRAW_ON:
    ldy (PTN_RELOAD_ON+0) ; PPU ADDR LOW
    ldx (PTN_RELOAD_ON+1) ; PPU ADDR HIGH
    stx PPUADDR       ; PPU ADDR HIGH
    sty PPUADDR       ; PPU ADDR LOW
    ldy #$00
DRAW_ON_LOOP:
    lda PTN_RELOAD_ON+2,y ; y work as lindex
    beq DRAW_ON_END
    sta PPUIO
    iny
    bne DRAW_ON_LOOP
DRAW_ON_END:
    beq DRAW_ON_OFF_END
DRAW_OFF:
    ldy (PTN_RELOAD_OFF+0) ; PPU ADDR LOW
    ldx (PTN_RELOAD_OFF+1) ; PPU ADDR HIGH
    stx PPUADDR       ; PPU ADDR HIGH
    sty PPUADDR       ; PPU ADDR LOW
    ldy #$00
DRAW_OFF_LOOP:
    lda PTN_RELOAD_OFF+2,y ; y work as lindex
    beq DRAW_ON_OFF_END
    sta PPUIO
    iny
    bne DRAW_OFF_LOOP
DRAW_ON_OFF_END:
    lda #BgScrolX
    sta BGSCROL
    lda #BgScrolY
    sta BGSCROL
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
; STACK: 3                                             ; SPI_OUTPUT_EN
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

; FUNCTION: SPI Send a byte with LED control
; INPUT: X ... Send data
; INPUT: LED_STATUS ... LED output
; OUTPUT: None
; BROKEN: P
; STACK: 5
; CONSTRAINT: None
; DEPEND: SPI_SEND_A_BYTE
SPI_SEND_WRAP:
    jsr SPI_BUS_RESET
    jsr SPI_SEND_A_BYTE
    pha
    lda <LED_STATUS
    ora #(SPI_CSx_HIGH + SPI_MOSI_HIGH)
    sta SPI_PORT
    pla
    rts

LOOP_ON_RAM:
    lda <IRQ_SWITCH ; +0 : A5 xx
    bne LOOP_ON_RAM ; +2 : D0 FC
    lda #$01        ; +4 : A9 01
    sta <IRQ_SWITCH ; +6 : 85 xx
    rts             ; +8 : 60
    .db $00         ; +9 : 00(sentinel)

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

    lda <LED_PALETTE_EN
    beq NMI_VEC_SPR
    lda #$3F
    sta PPUADDR ; Set VRAM Address HIGH
    lda #$02
    sta PPUADDR ; Set VRAM Address LOW
    lda <LED_STATUS
    beq NMI_VEC_LED_OFF
NMI_VEC_LED_ON:
    lda #LedOn
    sta PPUIO
    lda #Lead
    sta PPUIO
    sec
    bcs NMI_VEC_NO_SPR
NMI_VEC_LED_OFF:
    lda #LedOff
    sta PPUIO
    lda #Lead
    sta PPUIO
    sec
    bcs NMI_VEC_NO_SPR
NMI_VEC_SPR:
    lda #high(SPR_DMA_SRC)
    sta SPRDMA
NMI_VEC_NO_SPR:

    lda #BgScrolX
    sta BGSCROL
    lda #BgScrolY
    sta BGSCROL

    lda #EnaDisplay
    sta PPUCNT1
    lda #EnaNMI
    sta PPUCNT0

    inc <V_BLANK_COUNTER
    pla
    tay
    pla
    tax
    pla
    rti

; FUNCTION: Dump CPU Mapped Memory 8 Byte
; INPUT: WORK_L ... low(DUMP_ADDRESS)
; INPUT: WORK_H ... high(DUMP_ADDRESS)
; INPUT: X ... VRAM Address HIGH
; INPUT: Y ... VRAM Address LOW
; OUTPUT: None
; BROKEN: P, A, X, Y
; STACK: 2
; CONSTRAINT: Execute while VBlank
; DEPEND: CONVERT_TO_ASCII
; END: rts
DUMP_CPU_MEM_8BYTE:
    stx PPUADDR
    sty PPUADDR
    lda WORK_H
    jsr CONVERT_TO_ASCII
    txa
    sta PPUIO
    tya
    sta PPUIO
    lda WORK_L
    jsr CONVERT_TO_ASCII
    txa
    sta PPUIO
    tya
    sta PPUIO
    lda #$3A ; ":"
    sta PPUIO
    lda #$20 ; " "
    sta PPUIO
    ldx #$08
    ldy #$00
DUMP_MEM_LOOP:
    txa
    pha
    tya
    pha
    lda [WORK],y
    jsr CONVERT_TO_ASCII
    txa
    sta PPUIO
    tya
    sta PPUIO
    pla
    tay
    iny
    pla
    tax
    dex
    beq DUMP_MEM_END
    lda #$20 ; " "
    sta PPUIO
    bpl DUMP_MEM_LOOP
DUMP_MEM_END:
    lda #BgScrolX
    sta BGSCROL
    lda #BgScrolY
    sta BGSCROL
    rts

; FUNCTION: Convert a byte to ASCII
; INPUT: A
; OUTPUT: X ... ASCII of A's upper 4bit
; OUTPUT: Y ... ASCII of A's lower 4bit
; BROKEN: P, A
; STACK: None
; CONSTRAINT: None
; DEPEND: None
; END: rts
CONVERT_TO_ASCII:
    tax
    and #$0F
    sec
    cmp #$0A
    bmi CONVERT_TO_ASCII_SET_Y
    adc #$06
CONVERT_TO_ASCII_SET_Y:
    clc
    adc #$30
    tay
    txa
    lsr a
    lsr a
    lsr a
    lsr a
    sec
    cmp #$0A
    bmi CONVERT_TO_ASCII_SET_X
    adc #$06
CONVERT_TO_ASCII_SET_X:
    clc
    adc #$30
    tax
    rts

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
; BROKEN: P, Y
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
Font     EQU $30
LedOn    EQU $2A
LedOff   EQU $0B
Lead     EQU $10
Black    EQU $1d
BgColor  EQU $12
DontCare EQU BgColor
    db BgColor  ,Font    ,BgColor ,BgColor ; Pallet0 *Turn on LED
    db DontCare ,Black   ,Black   ,Black   ; Pallet1
    db DontCare ,Black   ,Black   ,Black   ; Pallet2
    db DontCare ,Black   ,Black   ,Black   ; Pallet3
    db DontCare ,Black   ,Black   ,Black   ; Pallet4
    db DontCare ,Black   ,Black   ,Black   ; Pallet5
    db BgColor  ,Black   ,Black   ,Black   ; Pallet7 *latest BgColor will be appied
    
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
    .else
IRQ_VEC:
    pha
    lda #$00
    sta <IRQ_SWITCH
    pla
    rti
    .endif                     ; USE_IRQ_LOADER

; FUNCTION: Udate PAD1 status
; INPUT: PAD1_CURRENT
; OUTPUT: PAD1_CURRENT PAD1_OLD PAD1_PRESS PAD1_RELEASE
; BROKEN: P, X
; STACK: 2
; CONSTRAINT: None
UPDATE_PAD1_STATUS:
    lda <PAD1_CURRENT
    sta <PAD1_OLD
    jsr GET_PAD1
    sta <PAD1_CURRENT
    lda #$FF
    eor <PAD1_OLD
    and <PAD1_CURRENT
    sta <PAD1_PRESS
    lda #$FF
    eor <PAD1_CURRENT
    and <PAD1_OLD
    sta <PAD1_RELEASE
    rts

; FUNCTION: GET PAD1 status via SPECIO1
; INPUT: None
; OUTPUT: A
; BROKEN: P, X
; STACK: 2
; CONSTRAINT: None
GET_PAD1:
    lda #$01
    sta SPECIO1
    lda #$00
    sta SPECIO1
    ldx #$01
GET_PAD1_LOOP:
    lda SPECIO1
    ror a
    txa
    rol a
    tax
    bcc GET_PAD1_LOOP
    rts

PTN_USAGE:
    dw $2282 ; Destination PPU Address
    db " SELECT:TOGGLE AUTO RELOAD      "
    db " DOWN  :RELOAD                  "
    db " B     :ON                      "
    db " A     :OFF                     ", $00

PTN_RELOAD:
    dw $2248 ; Destination PPU Address
    db "AUTO RELOAD=OFF", $00

PTN_RELOAD_ON:
    dw $2254 ; Destination PPU Address
    db " ON", $00

PTN_RELOAD_OFF:
    dw $2254 ; Destination PPU Address
    db "OFF", $00

PTN_LED1:
    dw $204C ; Destination PPU Address
    db $20, $20, $7F, $7F, $7F, $7F, $20, $20
    db $20, $7F, $7F, $7F, $7F, $7F, $7F, $20
    db $20, $7F, $80, $7F, $7F, $7F, $7F, $20
    db $20, $7F, $7F, $7F, $7F, $7F, $7F, $20
    db $20, $7F, $7F, $7F, $7F, $7F, $7F, $20
    db $20, $7F, $7F, $7F, $7F, $7F, $7F, $20
    db $20, $7F, $7F, $7F, $7F, $7F, $7F, $20
    db $20, $7F, $7F, $7F, $7F, $7F, $7F, $20
    db $7F, $7F, $7F, $7F, $7F, $7F, $7F, $7F
    db $20, $20, $80, $20, $20, $80, $20, $20
    db $20, $20, $80, $20, $20, $80, $20, $20
    db $20, $20, $80, $20, $20, $80, $20, $20
    db $20, $20, $80, $20, $20, $80, $20, $20
    db $20, $20, $20, $20, $20, $80, $20, $20
    db $20, $20, $20, $20, $20, $80, $20, $20, $00

    .bank 0    ; 2kByte Bank Index Of NES File
    .org $C000 ; 6502 Mapped Address
CHR_BIN:
    .org $C200 ; 6502 Mapped Address
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; (space)
    db $30, $30, $30, $30, $00, $30, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; ! 
    db $28, $28, $28, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; " 
    db $28, $28, $fe, $28, $fe, $28, $28, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; # 
    db $28, $fe, $a8, $fe, $2a, $fe, $28, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; $ 
    db $e2, $a4, $e8, $10, $2e, $4a, $8e, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; % 
    db $78, $48, $6a, $12, $6a, $44, $7a, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; & 
    db $30, $10, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; ' 
    db $0c, $10, $20, $20, $20, $10, $0c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; ( 
    db $30, $08, $04, $04, $04, $08, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; ) 
    db $92, $54, $38, $10, $38, $54, $92, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; * 
    db $10, $10, $10, $fe, $10, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; + 
    db $00, $00, $00, $00, $30, $10, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; , 
    db $00, $00, $00, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; - 
    db $00, $00, $00, $00, $00, $30, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; . 
    db $02, $04, $08, $10, $20, $40, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; / 
    db $7c, $82, $82, $00, $82, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 0 
    db $10, $30, $10, $00, $10, $10, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 1 
    db $7c, $02, $02, $7c, $80, $80, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 2 
    db $7c, $82, $02, $7c, $02, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 3 
    db $04, $84, $84, $84, $7e, $04, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 4 
    db $fc, $80, $80, $7c, $02, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 5 
    db $7c, $80, $80, $7c, $82, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 6 
    db $fc, $82, $02, $0c, $10, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 7 
    db $7c, $82, $82, $7c, $82, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 8 
    db $7c, $82, $82, $7c, $02, $02, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 9 
    db $00, $30, $30, $00, $30, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; : 
    db $00, $30, $30, $00, $30, $10, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; ; 
    db $08, $10, $20, $40, $20, $10, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; < 
    db $00, $00, $7c, $00, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; = 
    db $20, $10, $08, $04, $08, $10, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; > 
    db $3c, $42, $42, $1c, $18, $00, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; ? 
    db $7c, $82, $9a, $aa, $bc, $80, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; @
    db $7c, $82, $82, $fe, $82, $82, $82, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; A
    db $fc, $82, $82, $fc, $82, $82, $fc, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; B
    db $7c, $82, $80, $80, $80, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; C
    db $f8, $84, $82, $82, $82, $84, $f8, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; D
    db $fe, $80, $80, $fc, $80, $80, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; E
    db $fe, $80, $80, $fc, $80, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; F
    db $7c, $82, $80, $8e, $82, $82, $7e, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; G
    db $82, $82, $82, $fe, $82, $82, $82, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; H
    db $fe, $10, $10, $10, $10, $10, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; I
    db $7e, $04, $04, $04, $04, $84, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; J
    db $82, $8c, $b0, $c0, $b0, $8c, $82, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; K
    db $40, $40, $40, $40, $40, $40, $7e, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; L
    db $82, $c6, $aa, $aa, $92, $92, $82, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; M
    db $82, $c2, $a2, $92, $92, $8a, $86, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; N
    db $7c, $82, $82, $82, $82, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; O
    db $fc, $82, $82, $82, $fc, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; P
    db $7c, $82, $82, $92, $8a, $84, $7a, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Q
    db $fc, $82, $82, $fc, $82, $82, $82, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; R
    db $7c, $80, $80, $7c, $02, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; S
    db $fe, $10, $10, $10, $10, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; T
    db $82, $82, $82, $82, $82, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; U
    db $82, $82, $82, $82, $44, $28, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; V
    db $82, $82, $92, $92, $92, $aa, $44, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; W
    db $82, $44, $28, $10, $28, $44, $82, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; X
    db $82, $44, $28, $10, $10, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Y
    db $fe, $04, $08, $10, $20, $40, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; Z
    db $1e, $10, $10, $10, $10, $10, $1e, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; [
    db $6c, $28, $7c, $10, $7c, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; \
    db $f0, $10, $10, $10, $10, $10, $f0, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; ]
    db $10, $28, $44, $82, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; ^
    db $00, $00, $00, $00, $00, $00, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; _
    db $20, $10, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; `
    db $00, $00, $fe, $02, $fe, $82, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; a
    db $80, $80, $fe, $82, $82, $82, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; b
    db $00, $00, $fe, $80, $80, $80, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; c
    db $02, $02, $fe, $82, $82, $82, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; d
    db $00, $00, $fe, $82, $fe, $80, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; e
    db $1e, $10, $fe, $10, $10, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; f
    db $00, $00, $fe, $82, $fe, $02, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; g
    db $80, $80, $fe, $82, $82, $82, $82, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; h
    db $10, $00, $10, $10, $10, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; i
    db $02, $00, $02, $02, $02, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; j
    db $80, $80, $86, $98, $e0, $98, $86, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; k
    db $10, $10, $10, $10, $10, $10, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; l
    db $00, $00, $ec, $92, $92, $92, $92, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; m
    db $00, $00, $fc, $82, $82, $82, $82, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; n
    db $00, $00, $7c, $82, $82, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; o
    db $00, $00, $fc, $82, $fc, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; p
    db $00, $00, $7c, $82, $92, $8a, $7e, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; q
    db $00, $00, $8e, $b0, $c0, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; r
    db $00, $00, $fe, $80, $fe, $02, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; s
    db $40, $40, $fe, $40, $40, $40, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; t
    db $00, $00, $82, $82, $82, $82, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; u
    db $00, $00, $82, $82, $44, $28, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; v
    db $00, $00, $92, $92, $92, $92, $6c, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; w
    db $00, $00, $c6, $28, $10, $28, $c6, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; x
    db $00, $00, $82, $82, $7e, $02, $7e, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; y
    db $00, $00, $fe, $0c, $30, $c0, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; z
    db $06, $08, $08, $10, $08, $08, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; {
    db $10, $10, $10, $00, $10, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; |
    db $c0, $20, $20, $10, $20, $20, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; }
    db $22, $54, $88, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; ~
    db $00, $00, $00, $00, $00, $00, $00, $00, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $00 ; box1
    db $fe, $fe, $fe, $fe, $fe, $fe, $fe, $00, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $00 ; box2

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
    .dw IRQ_VEC
    .endif               ; USE_IRQ_LOADER


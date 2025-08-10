.segment "INITCODE"

.include "ascii_charmap.inc"
.include "common.inc"
.import jsrfarsub

.import __BASICLO_LOAD__, __BASICLO_RUN__, __BASICLO_SIZE__
.import __RAMMOS_LOAD__, __RAMMOS_RUN__, __RAMMOS_SIZE__

.import BRKHandler
.import osWRCH
.import NullRTI

.export loaddefpalette

    .byte "CX16"

    lda #1
    sta ram_bank

    ; copy BASIC to RAM
    .assert __BASICLO_SIZE__ = 8*256, error, "Unexpected size of BASICLO segment"
    ldx #0
    .repeat 8, I
:
    lda __BASICLO_LOAD__+I*256, x
    sta __BASICLO_RUN__+I*256, x
    inx
    bne :-
    .endrepeat

    ; Load RAM-allocated code to RAM.
lastpg=>__RAMMOS_SIZE__*256
    ldx #<__RAMMOS_SIZE__
    beq copypages
:
    dex
    lda __RAMMOS_LOAD__+lastpg, x
    sta __RAMMOS_RUN__+lastpg, x
    txa
    bne :-

copypages:
    ldx #>__RAMMOS_SIZE__
    beq @end
    lda #<__RAMMOS_LOAD__
    sta r0
    lda #>__RAMMOS_LOAD__
    sta r0+1
    lda #<__RAMMOS_RUN__
    sta r1
    lda #>__RAMMOS_RUN__
    sta r1+1
    ldy #0
@l:
    lda (r0), y
    sta (r1), y
    iny
    bne @l
    inc r0+1
    inc r1+1
    dex
    bne @l
@end:

    lda #<BRKHandler
    sta $0316
    lda #>BRKHandler
    sta $0317

    lda #<osWRCH
    sta WRCHV
    lda #>osWRCH
    sta WRCHV+1

    ; BASIC sets its own Handler, so none of our bussiness. let's just not crash the Computer
    lda #<NullRTI
    sta BRKV
    lda #>NullRTI
    sta BRKV+1

    jsr loaddefpalette

    ; Add a small prefix at the front of the basic entry.
    ; It sets the active rombank to the one holding BASIC.
    ldx #3
:
    lda banksettmpl, x
    sta __BASICLO_RUN__-4, x
    dex
    bpl :-

    cli

    ; Print intro text and set CHROUT to ISO mode
    inx
introprintlp:
    lda introtxt, X
    beq @end
    jsrfar $FFD2, 0
    inx
    bne introprintlp
@end:

    lda #1
    jmp __BASICLO_RUN__-4

loaddefpalette:
    ; load default color palette
    stz $9F25
    lda #31
    sta $9f20
    lda #$FA
    sta $9f21
    lda #$19
    sta $9f22

    ldx #31
:
    lda defpalette, x
    sta $9f23
    dex
    bpl :-
    stz $9f22 ; IDK if KERNAL handles DEC correctly, so we remove it
    rts

introtxt:
    .byte $90, 1, $9e, $0F, 13, "BBC BASIC IV Commander X16 edition", 13
    .byte "Press Caps-Lock for the most optimal coding experience", 13, 13, 0

defpalette:
    .word $0000, $0C00, $00C0, $0CC0, $000C, $0C0C, $00CC, $0CCC
    .word $0444, $0F44, $04F4, $0FF4, $044F, $0F4F, $04FF, $0FFF

banksettmpl:
    ldx #33
    stx rom_bank
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
    jsrfar KERNAL_CHROUT, 0
    inx
    bne introprintlp
@end:
    phx

    ; There apparently is a spec that says, that the Name of the Language ROM is placed in this address
    ; TODO: Parse&Print version number
    ldx #0
langnameprintlp:
    lda $B809, X
    beq @end
    jsrfar KERNAL_CHROUT, 0
    inx
    bne langnameprintlp
@end:
    plx
capsinfprintlp:
    inx
    lda introtxt, X
    beq @end
    jsrfar KERNAL_CHROUT, 0
    bra capsinfprintlp
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
    @epoch = .time
    ; Aproximate time. I won't bother creating a more accurate code for printing compilation date
    @year = @epoch/60/60/24/365+1970
    @dayspast = (@epoch/60/60/24-(@year-1970)*365)
    @month = (@dayspast/30) .mod 12 +1
    .byte $90, 1, $9e, $0F, 13, "BBC MOS Commander X16 edition.", " Compiled around ", .sprintf("%04i-%02i", @year, @month)
    .byte 13, "Language: ", 0
    .byte 13, "Press Caps-Lock for the most optimal coding experience", 13, 13, 0
    .assert *-introtxt<256, warning, "introtxt too long. the message won't print correctly"
    ; big endian 40-bit unix epoch
    .byte @epoch>>32, @epoch>>24, ^@epoch, >@epoch, <@epoch 

defpalette:
    .word $0000, $0C00, $00C0, $0CC0, $000C, $0C0C, $00CC, $0CCC
    .word $0444, $0F44, $04F4, $0FF4, $044F, $0F4F, $04FF, $0FFF

banksettmpl:
    ldx #33
    stx rom_bank
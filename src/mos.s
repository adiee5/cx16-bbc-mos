.include "ascii_charmap.inc"
.include "common.inc"

.import loaddefpalette

.zeropage
LPTR: .res 2

.bss
bytevar:    .res 1
tmpflag:    .res 1
vdulen:     .res 1
vdubuff:    .res 9

.segment "RAMMOS" ; data segment
vdustate:   .byte 0

.segment "MOS"

osCLI:
    ldx #0
@lp:
    lda colorchr, X
    beq @end
    jsrfar KERNAL_CHROUT, 0
    lda #$80
    jsrfar KERNAL_CHROUT, 0
    lda #$9f
    jsrfar KERNAL_CHROUT, 0
    inx
    cmp #16
    bne @lp
@end:

osWORD:
        stx LPTR
        sty LPTR+1
        cmp #0
        bne NullReturn ; we only support call #0
        lda (LPTR)
        pha
        ldy #1
        lda (LPTR), Y
        pha
        iny
        lda (LPTR), Y
        sta bytevar
        ; I don't know how min/max ASCII parameters are supposed to affect the result.
        ; BASIC seems to only have a $20-$FF request, which I believe is realistically all CHRIN can provide anyways.
        pla
        sta LPTR+1
        pla
        sta LPTR
        
        php
        sei
            stz ram_bank
            lda #<chrinhelper
            sta $ac03
            lda #>chrinhelper
            sta $ac04
            lda #1
            sta $ac05
            inc ram_bank
        plp
        stz tmpflag
        ldy #0
    @l:
        jsrfar KERNAL_CHRIN, 0
        sta (LPTR), y
        cmp #$0D
        bne :+
        jsr osWRCH ; Duck tape
        lsr tmpflag
        rts
    :   cpy bytevar ; we can't really block the movement of the cursor in kernal CHRIN, so instead we just cut the input.
        bcs :+
        iny
    :   bra @l
NullReturn: ; reuses already existing RTS
        rts

osBYTE:
        CMP #$7E
        BNE @mem       ; Ack. Escape
        STA ESCFLG
        RTS
    @mem:
        pha
        CMP #$84
        beq @top
        BCS @exit
        CMP #$83
        BCC @exit
        jsrfar KERNAL_MEMBOT, 0
        bra @exit
    @top:
        jsrfar KERNAL_MEMTOP, 0
    @exit:
        pla
        RTS
;

    .export osWRCH
.proc osWRCH
        pha
        lda vdustate
        beq :+
        jmp longcodes
    :   pla
        cmp #$7f;$14 VDU $7f has to act like backspace
        beq del
        cmp #$20
        bcc codes
        cmp #$80
        bcc :+  ; doing these comparisons is faster than abusing jsrfar
        cmp #$A0
        bcs :+
        pha
        lda #$80
        jsrfar KERNAL_CHROUT, 0
        pla
    :   jsrfar KERNAL_CHROUT, 0
        rts
    del:
        pha
        lda #$14
        jsrfar KERNAL_CHROUT, 0
        pla
        rts
    .proc codes
            stz vdulen
            stx bytevar
            pha
            asl a
            tax
            pla
            jmp (codebh, X)
        null:
            ldx bytevar
            rts
        pass: ; let KERNAL handle it
            ldx bytevar
            jsrfar KERNAL_CHROUT, 0 
            rts
        unimp: ; visual output, that there was some code sent, but our MOS doesn't support it yet
            ldx bytevar
            pha
            lda #'@'
            jsrfar KERNAL_CHROUT, 0
            lda #$80
            jsrfar KERNAL_CHROUT, 0
            pla
            jsrfar KERNAL_CHROUT, 0
            rts
        long: ; code with parameters. it will be handled at later passes
            ldx bytevar
            sta vdustate
            rts
        vdu9:
            ldx bytevar
            pha
            lda #$1D
            jsrfar KERNAL_CHROUT, 0
            pla
            rts
        vdu12:
            ldx bytevar
            pha
            lda #$93
            jsrfar KERNAL_CHROUT, 0
            pla
            rts
        home:
            ldx bytevar
            pha
            lda #$13
            jsrfar KERNAL_CHROUT, 0
            pla
            rts
        vdu20:
            pha
            jsrfar loaddefpalette, 32
            ldx #0
            :
            lda @b, X
            jsrfar KERNAL_CHROUT, 0
            inx
            cpx #3
            bcc :-
            ldx bytevar
            pla
            rts
            @b: .byte $90, 1, $9e
    .endproc
    .proc longcodes
            cmp #17
            beq color
            ;cmp #19
            ;beq newcol
            stz vdustate
            pla
            rts
        color:
            pla
            sta vdubuff
            and #$0F
            bit vdubuff
            bpl @fore
            bvc @bg
            sta $9F2C ; border color
            stz vdustate
            rts
        @bg:
            asl
            asl
            asl
            asl
            pha
            lda #$0F
            bra :+
        @fore:
            pha
            lda #$F0
        :   and KERNAL_IV_COLOR
            sta KERNAL_IV_COLOR
            pla
            ora KERNAL_IV_COLOR
            sta KERNAL_IV_COLOR
            lda vdubuff
            stz vdustate
            rts
    .endproc

    ; table for quick behaviour determining
    codebh:
        .addr codes::null, codes::unimp, codes::unimp, codes::unimp ;0-3
        .addr codes::unimp, codes::unimp, codes::unimp, codes::pass ;4-7
        .addr codes::unimp, codes::vdu9, codes::null, codes::unimp  ;8-B
        .addr codes::vdu12, codes::pass, codes::unimp, codes::unimp ;C-F
        .addr codes::unimp, codes::long, codes::unimp, codes::unimp ;10-13
        .addr codes::vdu20, codes::unimp, codes::unimp, codes::unimp;14-17
        .addr codes::unimp, codes::unimp, codes::unimp, codes::null ;18-1B
        .addr codes::unimp, codes::unimp, codes::home, codes::unimp ;1C-1F
.endproc

colorchr:
    .byt $90,$05,$1c,$9f,$9c,$1e,$1f,$9e
    .byt $81,$95,$96,$97,$98,$99,$9a,$9b


.segment "RAMMOS"

chrinhelper:
        ; TODO Ctrl+U
        bcc @do
        cmp #$1B
        ;beq :+
        ;cmp #'"'
        bne @z
    ; :   
        clc
        rts
    @z:
        sec
        rts
    @do:
        ;cmp #'"'
        ;beq @q
        inc tmpflag
        lda #$0D
        rts
    @q:
        ; we handle quotes in a special way, because CBM quote mode behaviour is undesirable
        ; I'm pretty sure CHRIN (loop5) and CHROUT (prt) share the internal state.
        ; note from future: CHROUT also triggers quote mode! It's unavoidable then ig

        ; uncomment in case weird errors when typing quotes
    ;     phx
    ;     ldx rom_bank
    ;     beq :+
    ;     stp ; let's have this as a logic error info.
    ;     nop
    ;     nop
    ;     lda #$65
    ;     lda #$02
    ;     sta $6502
    ; :   plx
        ; pha
        ; jsr KERNAL_CHROUT
        ; lda #$9d
        ; jsr KERNAL_CHROUT
        ; pla
        ; jsr KERNAL_CHROUT
        ; lda #0
        ; rts
;

    .export jsrfarsub
jsrfarsub:
    .include "jsrfar.inc"

    ; TODO: Handle CPU differences!!!
    .export BRKHandler
BRKHandler:
        lda #33
        sta rom_bank

    ; LET'S REALLY HOPE that cx16 irqsetup code doesn't change (this stack order remained since R44)
    ; (alternatively replace the KERNAL code in RAM with something else)
        ply
        plx
        pla ; pseudo push
        plp ; neo plp
        pla ; neo return #<
        pla ; neo return #>
        pla ; rom bank
    .pushcpu
    .setcpu "65816"
        ; At this point, stack has completely different contents
        ; depending on CPU type. 
        clc
        sep #1
        bcc @8bit

        lda 7, S
        sec
        SBC #1
        STA FAULT+0
        LDA 8, S
        SBC #0
        STA FAULT+1       ; $FD/E=>after BRK opcode

        pla ; 816 "Data Bank"
        pla ; Zero Page reloc

        pla ; the IRQ setup preserves A reg in a rather strange way
        xba ; becuse of that, we need to retreive it in this specific way
        pla
        xba
        bra @exit
    .popcpu
    @8bit:
        phx
        tsx

        ; Get address from stack
        LDA $0104,X
        SEC
        SBC #$01
        STA FAULT+0
        LDA $0105,X
        SBC #$00
        STA FAULT+1       ; $FD/E=>after BRK opcode

        plx
        pla ; actual A reg
    @exit:
        CLI
        JMP (BRKV) ; After this point, user only needs to RTI
;

.export NullRTI
NullRTI:
    RTI

.segment "VECTORS"
    jmp jsrfarsub

    .res 36 ; sadly has to be static number

    ; secondary calls. BASIC itself doesn't rely on these at all
    jmp NullReturn
    jmp NullReturn
    jmp NullReturn ; Printing routine
    jmp NullReturn
    jmp NullReturn
    jmp NullReturn
    jmp NullReturn
    jmp NullReturn ; Print hex
    jmp NullReturn ; Print hex word
    jmp NullReturn
    jmp NullReturn ; Apparently PRIMM, BUT BBC micro has something else.
    jmp NullReturn
    jmp NullReturn
    jmp NullReturn
    jmp NullReturn
    jmp NullReturn
    jmp NullReturn
    jmp NullReturn
    jmp NullReturn

    .assert *=$FFCE, error, "MOS API calls misaligned!"
    ; here start the actually important calls. 
        jmp NullReturn  ; OPEN if I'm correct
        jmp NullReturn
        jmp NullReturn
        jmp NullReturn
        jmp NullReturn
        jmp NullReturn
        jmp NullReturn  ; GETIN
        cmp #$0D        ; OSASCI. On CX16 platform, these different WRCH wrappers don't do much, as $0A is ignored by CHROUT
        bne OSWRCH
        lda #$0A        ; OSNEWL. Type enter.
        jsr OSWRCH
        lda #$0D
OSWRCH: jmp (WRCHV) ; this is required to be vectored
        jmp osWORD
        jmp osBYTE
        jmp NullReturn ; OS_CLI. Not sure how this should work on CX16

    ; 6502 interrupt vectors only work on ROM bank 0
    .byte "MOS<A5"
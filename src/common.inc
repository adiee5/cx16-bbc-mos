r0 = 2
r1 = r0 +2
ram_bank = 0
rom_bank = 1

ESCFLG=$FF
FAULT=$FD

WRCHV=$20E
BRKV=$202

KERNAL_CHROUT = $FFD2
KERNAL_CHRIN  = $FFCF
KERNAL_MEMBOT = $FF9C
KERNAL_MEMTOP = $FF99

.macro jsrfar addr, bank
    jsr jsrfarsub
    .addr addr
    .byte bank
.endmacro
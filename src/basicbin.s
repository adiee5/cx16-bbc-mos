.segment "BASICLO"

    .incbin "basic4lo.bin"

.assert * = $C000, error, "RAM-ROM split missaligned!"
.segment "BASIC"

    .incbin "basic4hi.bin"
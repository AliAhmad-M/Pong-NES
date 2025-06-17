SPRITES:
; SPR: y   tile attribute  x
.byte $00, $00, %00000000, $00  ; Zero sprites
.byte $00, $00, %00000000, $00

; Ball
.byte $74, $00, %00000000, $7C

; Paddle 1
.byte $64, $01, %00000000, $10
.byte $6C, $01, %00000000, $10
.byte $74, $01, %00000000, $10
.byte $7C, $01, %00000000, $10

; Paddle 2
.byte $64, $01, %00000000, $E8
.byte $6C, $01, %00000000, $E8
.byte $74, $01, %00000000, $E8
.byte $7C, $01, %00000000, $E8

; Player 1 score
.byte $08, $02, %00000000, $10

; Player 2 score
.byte $08, $02, %00000000, $E8

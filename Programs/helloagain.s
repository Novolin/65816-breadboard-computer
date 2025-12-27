; Once again for the bazillionth time
; actually going to try doing things "right" with the lcd

; defs:
.struct VIA         ; Defining our 65C51 VIA
    .org $E000      ; Lives at $E000
    PORTB .byte
    PORTA .byte
    DDRB .byte
    DDRA .byte
.endstruct          ; Shouldn't need more than that!
;LCD command stuff:
LCDRS = %00000010
LCDRW = %00000100
LCDE = 1

.code
    jsr LCDINIT


lcdcheck:               ; Checks if the LCD is busy or not:
    pha
    lda #0
    sta VIA::PORTB      ; Set port B to input 
lcdbusy:
    lda LCDRW           ; Make sure RW is set before we trigger E
    sta VIA::PORTA      ; Also clears any sent enable signals.
    inc VIA::PORTA      ; Fire our enable 
    lda VIA::PORTB      ; Check our flag:
    and %10000000       ; should be a 0 if not busy 
    bne lcdbusy         ; loop until we're done.
    PLA                 
    RTS                 ; continue execution


lcdcmd:                 ; Send a command to the LCD
    jsr lcdcheck        ; Make sure it's free.
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


initval = $30
dispon = $0F            ; screen on, cursor on, blink on.


.segment "VECTORS"
.addr LCDINIT           ; dont forget to force little endial lmfau
.addr LCDINIT
.addr LCDINIT

.data
stringloc: .asciiz "Hello, Worls!"

.code                   ; Code block. reset vector should be to LCDINIT!!

lcdcheck:               ; Checks if the LCD is busy or not:
    pha
    lda #0
    sta VIA::DDRB       ; Set port B to input 
lcdbusy:
    lda LCDRW           ; Make sure RW is set before we trigger E
    sta VIA::PORTA      ; Also clears any sent enable signals.
    nop
    nop                 ; probably don't need these, but better safe than sorry, and i have lots of rom space
    inc VIA::PORTA      ; Fire our enable 
    lda VIA::PORTB      ; Check our flag:
    and %10000000       ; should be a 0 if not busy 
    bne lcdbusy         ; loop until we're done.
    lda #$FF
    sta VIA::DDRB       ; return portb to output mode
    PLA                 
    RTS                 ; continue execution


lcdcmd:                 ; Send a command in the accumulator to the LCD
    jsr lcdcheck        ; Make sure it's free.
    pha                 ; store our data for a moment
    lda #0              ; prepare to send a command
    sta VIA::PORTA
    pla                 ; get back our command byte
    sta VIA::PORTB      ; put it on the data lines
    inc VIA::PORTA      ; fire the enable bit
    RTS                 ; we can go back to whatever other thing now

lcdchar:                ; send the character data in A to the LCD
    jsr lcdcheck        ; ensure LCD is free
    pha                 ; sorry bro, gotta set up PORT A first
    lda #LCDRS          ; contorl byte
    sta VIA::PORTA
    pla
    sta VIA::PORTB
    inc VIA::PORTA      ; Send the enable bit
    RTS                 ; I think that's all?



LCDINIT:                ; boot our LCD screen, get it ready to go
    lda #$30            ; I think $30 is the correct value for our initialization. It may be like $38 but i dont remember
    jsr lcdcmd
    lda #$30
    jsr lcdcmd          ; datasheet says to do it multiple times, so i'm doin that.
    lda #$30
    jsr lcdcmd
    lda #$0F            ; cursor/blink/etc.
    jsr lcdcmd




sendstring:
    ldx #0              ; Use X as our offset
strloop:
    lda stringloc,X     ; load our character
    beq stringdone      ; exit our loop if we loaded a null/terminating char
    jsr lcdchar         ; write it
    inx                 ; increment our pointer
    jmp strloop         ; repeat

stringdone:
    brk                 ; kill our program, we're done for now.





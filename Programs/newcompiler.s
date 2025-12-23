; Re-writing my hello world for a new compiler 
; vasm is freaking out about jump addresses and i can't be assed to fix it
; it also doesn't have '816 support so fuck it

.p816                   ; identify our CPU



; Define our VIA:
.struct IOPORT          ; 6522 Versatile Interface Adapter
    .org $E000          ; Lives in E000
    PORTB .byte
    PORTA .byte
    DDRB .byte
    DDRA .byte
.endstruct      ; TODO: Put this in a header file w/ all the i/o and other ports


.segment "DATA"
OUTSTRING:
    .asciiz "Hello, World!"
.segment "VECTORS"
    .word BOOT
    .word BOOT
    .word BOOT

.code
BOOT:
    lda #$FF
    sta IOPORT::DDRA
    sta IOPORT::DDRB
    LDA #$38            ; LCD Initialization byte
    STA IOPORT::PORTB
    LDA #1
    STA IOPORT::PORTA           ; Send the enable pulse
    JSR DELAY           ; Give it time to do things
    DEC IOPORT::PORTA
    LDA #$0F            ; Turn on, cursor and blink enabled.
    STA IOPORT::PORTB
    LDA #1
    STA IOPORT::PORTA           ; send command
    JSR DELAY
    DEC IOPORT::PORTA           ; We're executing enough stuff before the next cmd that we shouldn't need another delay
    
WRITESTR:
    LDX #0              ; Make sure X register is empty
    LDY #3              ; Use Y for our command register, since we're going to write it a lot. Saves on LDA instructions.
STRLOOP:
    LDA OUTSTRING,X     ; Get our next character
    BEQ PROGEND         ; If it's null, exit.
    STA IOPORT::PORTB
    STY IOPORT::PORTA
    JSR DELAY
    DEC IOPORT::PORTA
    INX
    JMP STRLOOP         ; Unconditional jump, the check on the character we load will kill this loop.


DELAY:
    PHA                 ; Store the Accumulator to the stack
    LDA #$FF            ; Arbitrary value, can be tweaked when I need better precision/more time.
DELOOP:
    DEC 
    BNE DELOOP
    PLA                 ; Take back our starting data
    RTS                 ; Go home.



PROGEND:
    .end                ; Kill the program here.

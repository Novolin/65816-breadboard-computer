; Once again for the bazillionth time
; actually going to try doing things "right" with the lcd

; LCD Timing Notes:
; @ 1MHz, it's 500 ns between clock cycles, so we're comfortably in the happy zone for the LCD
; Higher speeds may make things act up, you may need to add delays to the command/data subs
; also adjust the wait time for the boot stuff.

.p816

; defs:
.struct VIA         ; Defining our 65C51 VIA
    .org $E000      ; Lives at $E000
    PORTB .byte
    PORTA .byte
    DDRB .byte
    DDRA .byte
.endstruct          ; Shouldn't need more than that!
;LCD command stuff:
LCDE = %1           ; Just in case I need to  do funky stuff later.
LCDRS = %00000010
LCDRW = %00000100
LCDINIT = %00111000
LCDON = $0F            ; screen on, cursor on, blink on.
LCDCLR = 1		; probably doesn't need its own def but w/e


.segment "VECTORS"
.addr BOOT           ; dont forget to force little endial lmfau
.addr BOOT
.addr BOOT

.data			; The typo stays.
stringloc: .asciiz "Hello, Worls!"

.code                   ; Code block. reset vector should be to BOOT!!

delay:			; Delay for however many loops are in the accumulator, ~1ms/loop @ 1MHz
    RTS         ; I'm not at 1MHz yet, so if i dont do this, loops take literal days.
    phx			; Save our x register for later
    tax			; Move the # of loops to X
    lda #$FF		; 255 cycles for now
deloop:			; the actual loop
    dec a		; Decrement A until it hits 0
    bne deloop
    lda #$FF		; Reset the A counter here
    dex			; Decrement X until *it* hits 0
    bne deloop
    plx			; Take our x back
    rts    

lcdcheck:               ; Checks if the LCD is busy or not:
    pha
    lda #0
    sta VIA::DDRB       ; Set port B to input 
lcdbusy:
    lda #LCDRW          ; Make sure RW is set before we trigger E
    sta VIA::PORTA      ; Also clears any sent enable signals.
    lda #(LCDRW | LCDE) ; Instead of nops, just make the accumulator work
    sta VIA::PORTA      ; Fire our enable 
    lda VIA::PORTB      ; Check our flag:
    and %10000000       ; should be a 0 if not busy 
    bne lcdbusy         ; loop until we're done.
    lda #$FF
    sta VIA::DDRB       ; return portb to output mode
    pla                 
    rts                 ; continue execution


lcdcmd:                 ; Send a command in the accumulator to the LCD
    jsr lcdcheck        ; Make sure it's free.
    pha                 ; store our data for a moment
    lda #0              ; prepare to send a command
    sta VIA::PORTA
    pla                 ; get back our command byte
    sta VIA::PORTB      ; put it on the data lines
    inc VIA::PORTA      ; fire the enable bit
    rts                 ; we can go back to whatever other thing now

lcdchar:                ; send the character data in A to the LCD
    jsr lcdcheck        ; ensure LCD is free
    pha                 ; sorry bro, gotta set up PORT A first
    lda #LCDRS          ; contorl byte
    sta VIA::PORTA
    pla
    sta VIA::PORTB
    inc VIA::PORTA      ; Send the enable bit
    rts                 ; I think that's all?

lcdstartup:             ; Separate from commands, as busy flag does not work until initialized.
    lda #0
    sta VIA::PORTA      ; Clear our VIA's A output, in case it's got old data
    lda #LCDINIT        ; $38 should give us 2 lines, 8 bit data and 5x8 font
    inc VIA::PORTA      ; E is the lowest bit, so this is making it high
    sta VIA::PORTB      ; Put the data packet on teh bus
    dec VIA::PORTA      ; Send pulse.
 rts




BOOT:                   ; boot our LCD screen, get it ready to go
    lda #$FF            ; Start by initializing our VIA
    sta VIA::DDRA
    sta VIA::DDRB
    lda #50		
    jsr delay		; ~50ms for the LCD to wake up
    jsr lcdstartup      ; Send the startup/init packet multiple times
    lda #4
    jsr delay		; I think it wants another ~4ms at this point
    jsr lcdstartup      ; why? idk, datasheet says so.
    lda #4
    jsr delay
    jsr lcdstartup	; ok it should finally be awake now.
    lda #LCDON          ; set the cursor/blink/display on flags
    jsr lcdcmd
    lda #LCDCLR		; Send a clear command
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
    brk 		; String stuff will need to be rewritten, but for now just kill it.







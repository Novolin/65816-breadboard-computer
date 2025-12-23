; Version 2 of my hello world, giving up on 4-line comms
; i'll sort that out once I know things work at all!!!



; fixed memory locations
PORTA = $E001
PORTB = $E000
DDRA = $E003
DDRB = $E002

STRINGLOC = $9000
TIMEVEC = $0200         ; Where our delay timer lives
                        ; outside of zero page for extra time delays




 .org $7FFD             ; boot/reset vector
 .byt $80               ; Sends us to start of ROM
 .byt $00               ; pad the rom to 8k
 .byt $00 

 .org $1000             ; will be $9000 in ROM
 .asciiz "Hellorld!"    ; asciiz null terminates the string

 .org $0000
 lda #$FF               ; init the Direction registers
 sta DDRA               ; just do them all as outputs to start.
 sta DDRB
 lda #5
 sta TIMEVEC            ; Set it to do 5 delay loops
 JSR DELAY              ; Go to our delay loop, allow the LCD to boot
 lda #%00111000         ; LCD function set
 sta PORTB
 LDA #1
 sta PORTA
 jsr DELAY
 dec PORTA
 jsr DELAY
 lda #$0F               ; LCD ON, cursor/blink on. If the cursor isn't there and blinking, we know it's fuckered.
 sta PORTB
 lda #1
 sta PORTA
 jsr DELAY
 dec PORTA
 jsr DELAY
 

STRINGOUT:
 ldx #0
STRINGLOOP:
 lda STRINGLOC,x
 beq PROGEND
 sta PORTB
 lda #3 
 sta PORTA
 jsr DELAY
 dec PORTA
 inx
 jmp STRINGLOOP


DELAY:
 pha                ; Store our A/X/Y regs' for now:
 phx                ; remember to flag the compiler to let it work ( -)
 ldx TIMEVEC        ; # of times to go through the loop
DELOOP:
 lda #$FF           ; 255 is ok for now, I don't think I care about ultra precise timing with this atm.
INNERLOOP:
 dec a
 bne INNERLOOP      ; keep goin until that zero hits
 dex 
 bne DELOOP         ; same with x
 plx                ; Get our stuff back from the stack
 pla                
 rts


PROGEND:
 nop                ; End it all! 
; Version 2 of my hello world, giving up on 4-line comms
; i'll sort that out once I know things work at all!!!

PORTA = $E001
PORTB = $E000
DDRA = $E003
DDRB = $E002
STRINGLOC = $9000
TIMEVEC = $0200     ; Where our delay timer lives
                    ; outside of zero page for extra time delays

.org $7FFD          ; boot/reset vector
.byt $80            ; Sends us to start of ROM

.org $1000          ; will be $9000 in ROM
.asciiz "Hellorld!" ; asciiz null terminates the string

.org $0000
 lda #$FF           ; init the Direction registers
 sta DDRA           ; just do them all as outputs to start.
 sta DDRB
 lda #%00111000     ; LCD function set, 

STRINGOUT:
 


DELAY:
 pha                ; Store our A/X/Y regs' for now:
 phx
 phy
 lda #$FF           ; 255 should be ok?
 

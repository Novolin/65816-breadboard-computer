; This program is aimed to test my PIO stuff
; Port B on the 6522 is set to the LCD display
; Port A will be just some LEDs.

.define PORTA $8001
.define PORTB $8002

.org $7FFC		; Boot vector:
 JMP $9000

.org $1000
BOOT:
 STI                	; Disable interrupts
 LDY #0
 LDX #0
 LDA #$FF           	; DDR2 direction: all outs
 STA $8002
 sta PORTA              ; Also save it in port a          
 

RUNLOOP:



WAITSEC:
  STX $F0
  STY $F1
  STA $F2
  LDA #$FF
  
 
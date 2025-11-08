PORTB = $E000
PORTA = $E001
DDRB = $E002
DDRA = $E003
PIACTRL = $E00C 		; Control register
LCDRS = %10
LCDRW =%100 


STRLOC = $C000			; Where the string is located
 .org $7FFC			; On reset/boot
 .word $80			; Jump to our start address for this and irq
 .byt $00
 .byt $00			; Padding the ROM to full size
 .org $4000			; Will be F000
 .fcc "Hello, World!"
 .org $0000			; New HW layout means ROM actually starts at 0! hooray!			


				; Because of some 
BOOT:
 LDA #%11111111			; DDR Flags for output
 STA DDRB
 LDA #%10101111			; Pulse HI on output from portB
 STA PIACTRL
 LDA #%00110000			; Data packet, set 4-bit mode on LCD
 STA PORTB
 JSR LCDINIT			; We may need to re-init the LCD
 LDX #0				; make sure X is clear
 JMP LOOP 			; off we go!!!!


LCDINIT:			; Subroutine in case we need to reinit
 LDA #%00110001			; Keep on 4-bit mode
 STA PORTB
 DEC PORTB
 LDA #%01000001			; Set screen size/cursor
 STA PORTB
 DEC PORTB
 LDA #3
 STA PORTB
 DEC PORTB 


 LDA #1				; Clear the LCD
 STA PORTB
 DEC PORTB
 LDA #1
 STA PORTB
 DEC PORTB			; Every command takes two writes. Hopefully it's ok in terms of timing?
 LDA #2
 STA PORTB 
 LDA #0
 STA PORTB
 LDA #%11000000			; Disable blink
 STA PORTB
 LDA #2
 STA PORTB 
 RTS				; Done
 
SENDA:
 STA $FF			; Toss our character into a ZP buffer
 AND #%11110000			; 4 MSB
 ORA #%00000001			; Set character flag
 STA PORTB
 LDA $FF << 4
 AND #%11110000
 ORA #%00000001
 STA PORTB
 LDA #2
 STA PORTB 
 RTS


LOOP:
 LDA STRLOC,X			; Load the next character
 BEQ KILL		 	; If it's $00, end the program
 JSR SENDA
 INX
 JMP LOOP


IDLE:
 JMP IDLE

KILL: 				; End execution
 JMP IDLE


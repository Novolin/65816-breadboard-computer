PORTB = $8000
DDRB = $8002
PIACTRL = $800C 		; Control register
 .ds8 $1000
 .org $7FFC			; On reset/boot
 jmp $9000			; Jump to our start address
 .byt 0				; Padding the ROM
 .org $7000			; Will be F000
 .fcc "Hello, World!"
 .org $1000			; Our address range starts at $1000 in the ROM			
BOOT:
 LDA #%00111111			; DDR Flags for output
 STA DDRB
 LDA #%10101110			; Pulse HI on output from portB
 STA PIACTRL
 LDA #%00110000			; Data packet, set 4-bit mode on LCD
 STA PORTB
 JSR LCDINIT			; We may need to re-init the LCD
				; So make it a subroutine
 LDX #0				; make sure X is clear
 JMP LOOP 			; off we go!!!!


LCDINIT:
 LDA #%00110000			; Keep on 4-bit mode
 STA PORTB
 LDA #%01000000			; Set screen size/cursor
 STA PORTB
 LDA #2
 STA PORTB 


 LDA #0				; Clear the LCD
 STA PORTB
 LDA #1
 STA PORTB			; Every command takes two writes. Hopefully it's ok in terms of timing?
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
 LDA $F000,X		; Load the next character
 BEQ KILL		; If it's $00, end
 JSR SENDA
 INX
 JMP LOOP

 
KILL:
 BRK


PORTB = $E000
PORTA = $E001
DDRB = $E002
DDRA = $E003
PIACTRL = $E00C 		; Control register
LCDRS = %10
LCDRW =%100 
STRLOC = $C000			; Where the string is located
 
 .org $7FFD	
 			; On reset/boot
 .word $80			; Jump to our start address for this and irq
 .byt $00			; Padding the ROM to full size
 .org $4000			; Will be F000
 .fcc "Hello, World!"
 .org $0000			; New HW layout means ROM actually starts at 0! hooray!			


				; Because of some 
BOOT:
 LDA #%11111111			; DDR Flags for output
 STA DDRB


LCDINIT:			; Subroutine in case we need to reinit
 LDA #%00100001			; Keep on 4-bit mode
 STA PORTB
 DEC PORTB
 LDA #%01000001			; Set screen size/cursor
 STA PORTB
 DEC PORTB
 LDA #3
 STA PORTB
 DEC PORTB 


 LDA STRLOC,X ; Start outside the loop because we're doing a BNZ at the end of it
SENDIT:
 INX
 STA $FF
 AND #%11110000
 ORA #%00000101	; I think this puts RS as 1?
 STA PORTB
 DEC PORTB
 LDA $FF
 ROL
 ROL
 ROL
 ROL
 AND #%11110000
 ORA #%00000101
 STA PORTB
 DEC PORTB
 LDA STRLOC,X
 BNE SENDIT
 

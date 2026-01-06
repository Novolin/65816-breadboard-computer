; I/O ports
PORTB = $E000
PORTA = $E001
DDRB = $E002
DDRA = $E003
PIACTRL = $E00C 		; Control register

; Labeled stuff so it's easier to tweak


; VIA: B7 B6 B5 B4 B3 B2 B1 B0
; LCD: D7 D6 D5 D4 NC RS RW E

LCDCHAR = %101			; RS/E hi, for sending a character
LCDREAD = %11			; RW/E hi, to read LCD state
LCDON = $0C			; Command byte for display on
LCDMODE = $06			; Command byte for other mode settings
LCDINIT = $28			; The byte we send on boot/init

STRLOC = $C000			; Where the string is located
 
 .org $7FFD			; Reset Vector
 .word $80			; Jump to our start address for this and irq
 .byt $00			; Padding the ROM to full size
 .org $4000			; Will be $C000
 .fcc "Hello, World!"
 .org $0000			; New HW layout means ROM actually starts at 0! 
				; hooray!


LCDBOOT: 
 LDA #21			; First one only needs the length bit and enable
 STA PORTB
 DEC PORTB
 LDA #LCDINIT
 JSR LCDCMD
 LDA LCDMODE
 JSR LCDCMD
 JMP WRITESTRING

LCDCMD:
 PHA				; Copy our data byte to the stack
 AND #$F0			; Get the high nibble
 ORA #1				; Enable
 STA PORTB
 PLA				; Take back our byte, also delay
 DEC PORTB			
 ROL
 ROL
 ROL
 ROL
 AND #$F0
 ORA #1
 STA PORTB
 ROL				; Small delay
 DEC PORTB
 JSR CHECKBUSY
 RTS
 
CHECKBUSY:			; Check if the LCD is busy
 LDA #$0F 			; Flag data bits as inputs
 STA DDRB
RUNCHECK:
 LDA #LCDREAD
 STA PORTB
 ROL 				; Delay for a tiny bit
 LDA PORTB
 DEC PORTB
 PHA				; We need to save the val, but not for long
 LDA #LCDREAD
 STA PORTB
 DEC PORTB			; ignore the lower bits
 PLA				; Get our byte back
 AND #%1000000			; Isolate the busy flag
 BNE RUNCHECK			; If it's still busy, try again
 LDA #$FF
 STA DDRB			; Back to output mode
 RTS

SENDCHAR: 			; Send the character in the acumulator
 PHA				; Save our byte for later
 AND #$F0			; Isolate upper nibble
 ORA #LCDCHAR
 STA PORTB
 PLA				; retrieve our byte, delay a lil bit
 DEC PORTB
 ROL				; Rotate so we get our upper nib
 ROL				
 ROL
 ROL
 AND #$F0			; Repeat as above
 ORA #LCDCHAR
 STA PORTB
 ROL				; use this to delay instead
 DEC PORTB
 JSR CHECKBUSY
 RTS

WRITESTRING:
 LDX #0
NEXTCHAR:
 LDA STRLOC,X
 INX
 BEQ STRINGDONE
 JSR SENDCHAR
 JMP NEXTCHAR
STRINGDONE:
 NOP


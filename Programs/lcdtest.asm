; Our ROM is offset by $8000, but our adressable area starts at $9000
STRINGLOC = $D000
PORTB = $8000
LCDBUFF = $FF
 .blk $1000
 .org $7FFC
 JMP BOOT
 .byt 0
 .org $5000
 .fcc "Hello, World!"
 .org $1000

BOOT:
 LDX #0
 LDY #0
 LDA #$FF		; Set the DDR
 STA $8002 		
 STA $800C		; Also the command register
 STA $FE 		; Also also our delay timer
 LDA #%00100001		; LCD Setup
 STA $8000		
 DEC $8000		; Clock the LCD
 LDA #%00110100
 STA $FF
 JSR CMDSEND
 LDA #%00001100
 STA $FF
 JSR CMDSEND
 JMP LOOP

CMDSEND:		; Send the data in $FF to the LCD as a command
 LDA $FF
 AND #$F0		; Drop the lower bits
 ADC #1			; Enable hi
 STA $8000
 DEC $8000		; Enable lo
 LDA $FF << 4		; Load the second nibble
 AND #$F0
 ADC #1
 STA $8000		; send, etc.
 JSR DELAY
 DEC $8000
 LDA #5			; Send a read command because it's weird
 STA $8000
 JSR DELAY
 DEC $8000
 LDA #1
 STA $8000
 JSR DELAY
 DEC $8000
 RTS

DATSEND:		; Send the data in $FF to the LCD, as a character
 LDA $FF
 AND #$F0
 ADC #3			; RS, E
 STA $8000
 JSR DELAY
 DEC $8000		; Pulse
 LDA $FF << 4		; Nibble 2
 AND #$F0
 ADC #3
 STA $8000
 JSR DELAY
 DEC $8000
 LDA #5
 STA $8000
 JSR DELAY
 DEC $8000
 RTS

LOOP:
 LDA STRINGLOC,X
 BEQ KILL
 STA $FF
 JSR DATSEND
 INX
 JMP LOOP

DELAY:			; Delays for however long is in $FE
 LDY $FE
DELOOP:
 DEY
 NOP
 BNE DELOOP
 RTS

KILL:
 BRK
 

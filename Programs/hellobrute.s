; Brute forcing "Hello, World!"
PORTA = $8001

 .org $1FFC	; With ROM offset, is $FFFC
 JMP $E000	; Jump to start of ROM
 .byte $00
 
 .org $0000	; with ROM offset, $E000

 LDA #$FF	; Set up the stuff 
 STA $8003
 
		; Set up LCD in 4-byte mode!
 LDA #$51	
 STA PORTA
 AND #$FE	; Toggle the enable bit
 STA PORTA	; LCD should be in 4-byte mode now

 LDA #$55	; Send the first nibble of H
 STA PORTA
 AND #$FE	; Toggle enable
 STA PORTA
 LDA #$85	; Send the second nibble
 STA PORTA	
 AND #$FE
 STA PORTA	; Enable toggle

 LDA #$65	; "E"
 STA PORTA
 AND #$FE
 STA PORTA
 LDA #$55
 STA PORTA
 AND #$FE
 STA PORTA

 LDA #$65
 STA PORTA
 AND #$FE
 STA PORTA
 LDA #$C5
 STA PORTA
 AND #$FE
 STA PORTA

 LDA #$65
 STA PORTA
 AND #$FE
 STA PORTA
 LDA #$C5
 STA PORTA
 AND #$FE
 STA PORTA

 LDA #$65
 STA PORTA
 AND #$FE
 STA PORTA
 LDA #$F5
 STA PORTA
 AND #$FE
 STA PORTA
 
 LDA #$25
 STA PORTA
 AND #$FE
 STA PORTA
 LDA #$C5
 STA PORTA
 AND #$FE
 STA PORTA

 LDA #$25
 STA PORTA
 AND #$FE
 STA PORTA
 LDA #$05
 STA PORTA
 AND #$FE
 STA PORTA

 LDA #$75
 STA PORTA
 AND #$FE
 STA PORTA
 LDA #$75
 STA PORTA
 AND #$FE
 STA PORTA

 LDX #($F&$FF) << 4
 LDX #$FF & $F << 4	

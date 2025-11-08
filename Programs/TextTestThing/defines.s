; Set HW addresses:
PORTB = $E000		; Ignore $6XXX in the ROM, that's I/O land
PORTA = $E001
DDRB = $E002
DDRA = $E003
SETREGB = $E004 	; wtf is the settings thing called?


; ROM - related addresses
RESVECT = $7FFD		; Reset/Boot vector (little-endian bs here)
IRQVECT = $7FFE     
NMIVECT = $7FFA

TEXTLOC = $4000 	; If 4k isn't enough for my program, I think I'm cooked lol

; Defined RAM addresses:
TEXTSTORE = $1000	; Where the string will live in RAM
TEXTLEN = $0FFF		; How long is it
CURSPOS = $0FFE		; How many characters deep are we in displaying

; LCD Commands:
LCDBOOT = #%00101100
LCDBLINKOFF = #%00001100
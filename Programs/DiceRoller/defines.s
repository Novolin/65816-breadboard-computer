; Set HW addresses:
PORTB = $E000		; Ignore $6XXX in the ROM, that's I/O land
PORTA = $E001
DDRB = $E002
DDRA = $E003
SETREGB = $E004 	; wtf is the settings thing called?


; ROM - related addresses
RESVECT = $7FFC		; Reset/Boot vector (FFFC - 8000)
IRQVECT = $7FFE
NMIVECT = $7FFA

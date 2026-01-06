; Rewritten IO/GFX code, using a W65C22 VIA
; uses PORTA for a 16 button keypad
; PORTB for a 20x4 (or 16x2) LCD
; SR for a graphical LCD.

.IFNDEF delay
.INCLUDE  'delay.s'
.ENDIF
IOPORT = $E000      ; Locating it at E000 for now, so it will work with the low-spec hardware
                    ; Will change once I can implement > 16b memory addressing

.struct IO
.org IOPORT
 LCD            .BYTE                   ;PORTB, LCD control
 KP_GLCD        .BYTE                   ;PORTA, Keypad input/GLCD control lines
 DDR_LCD        .BYTE                   ;DDRB, LCD DDR
 DDR_KP         .BYTE                   ;DDRA, Keypad DDR.
 T1C            .WORD                   ;T1 Counter bytes (unused?)
 T1L            .WORD                   ;T1 Latch bytes (unused)
 T2C            .WORD                   ;T2 Counter bytes (For SR)
 SR             .BYTE                   ;Shift Register (for GLCD)
 ACR            .BYTE                   ;Aux control Register
 PCR            .BYTE                   ;Peripheral Control register
 IFR            .BYTE                   ;Interrupt Flag register
 IER            .BYTE                   ;Interrupt Enable Register
.ENDSTRUCT


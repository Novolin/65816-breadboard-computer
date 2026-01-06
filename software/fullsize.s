; This is hello, world! for when i've implemented a larger address space
; probably after I make a separate clock board and stuff, clearing up a breadboard
; or just straight up start soldering stuff!!!

.p816           ; Identify our processor

.include 'includes/delay.s'
.include 'includes/lcd.s' ;TODO: update this with the proper address space


.segment "VECTORS"
.ADDR           SOFTINT                 ; C816 Vector: COP
.ADDR           SOFTINT                 ; C816 Vector: BRK
.ADDR           SOFTINT                 ; C816 Vector: Abort
.ADDR           NMI                     ; C816 Vector: NMI
.ADDR           0                       ; Unused
.ADDR           IRQ                     ; C816 Vector: IRQ
.ADDR           0                       ; Unused
.ADDR           0                       ; Unused
.ADDR           SOFTINT                 ; 6502 Vector: COP
.ADDR           0                       ; Unused
.ADDR           SOFTINT                 ; 6502 Vector: Abort
.ADDR           NMI                     ; 6502 Vector: NMI
.ADDR           BOOT                    ; 6502/816 Vector: Reset
.ADDR           IRQ                     ; 6502 Vector: IRQ

.code
SOFTINT:                                ; Routine for non-hardware interrupts
 RTI                                    ; not implemented

NMI:                                    ; NMI Triggered, likely from serial adapter
 RTI                                    ; not implemented.

IRQ:                                    ; IRQ Triggered, likely from VIA?
 RTI                                    ; not implemented.
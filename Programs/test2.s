; This program is aimed to troubleshoot some issues on my LCD output
; Tie data out from the 65c22 to some LEDs to make sure it's working

.org $1000          ; First 1k is taken up by other junk
BOOT:
 STI                ; Disable interrupts
 LDY #0
 LDX #0
 LDA #$FF           ; DDR2 direction: all outs
 STA $8002          
 LDA #%10111111     ; Set PIA to Pulse Output on 
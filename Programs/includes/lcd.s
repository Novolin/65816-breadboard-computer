; Definitions for the LCD module, attached via a WDC65C22 Versatile Interface Adapter.
; I use a 20x4 character one, because i want more text, but it should work for 16x2 as well
; Almost all of them use the same controller.

; This may also include the graphical LCD stuff too, but that's a later problem.
.p816

.IFNDEF delay
.include        "delay.s"
.ENDIF
.ifndef IOMEM
IOMEM = $E000
.ENDIF

; Define the VIA's ports. Make sure you use the right memory address!!
.struct LCD                             ; Will handle both graphical and Text LCDs
.org IOMEM                              ; Lives at memory address $010000, in our highmem space
 CHRDAT          .byte                   ; PORTB on the VIA, for our character LCD data output
 CONTROL         .byte                   ; PORTA, houses control lines for both displays
 DDRB            .byte                   ; DDR for PORTB
 DDRA            .byte                   ; DDR for PORTA
 T1C             .WORD                   ; Timer 1 Counter
 T1L             .WORD                   ; T1  Latches
 T2C             .WORD                   ; T2 Counter
 SR              .BYTE                   ; Shift Register Data
 ACR             .BYTE                   ; Aux control Register
 PCR             .BYTE                   ; Perif. Control register
 IFR             .BYTE                   ; Interrupt Flag register
 IER             .BYTE                   ; Interrupt enable register
.endstruct                              ; That's all we need, since the last byte is just PORTA again.

; Character LCD definitions
; Control values:
LCD_E           = %00000001             ; Enable bit, alternatively just inc/dec CHLCD::CMDPORT
LCD_CHAR        = %00000010             ; Register Select. 1 = data, 0 = Command
LCD_RW          = %00000100             ; Read/Write. 1 = Read, 0 = Write. Mostly used in busy checking.

; Command packets, send without RS or RW:
LCD_CLEAR       = 1                     ; Clear the display, move cursor to home. (1.5ms)
LCD_HOME        = 2                     ; Return the cursor to the home position, keeping display data. (1.5ms)
LCD_CURS_MOV_LR = %00000111             ; Set the cursor/screen to move L->R as characters are drawn
LCD_CURS_MOV_RL = %00000101             ; Set the cursor/screen to move R->L as chars are drawn (?)
LCD_CURS_MOV_NO = %00000100             ; Turn off cursor movement. Subsequent chars are drawn on top of the last. (?)
LCD_OFF         = %00001000             ; i think this just turns the whole bitch off? no idea!!
LCD_ON_NOCURS   = %00001100             ; Turn on the display, no cursor at all
LCD_ON_NOBLINK  = %00001110             ; Turn on the display and steady cursor
LCD_ON_BLINK    = %00001111             ; Turn on display w/ blinking cursor
LCD_SHIFT_RL    = %00011100             ; Shift the whole screen from R->L w/ every character
LCD_SHIFT_LR    = %00011000             ; Shift the whole screen from L->R w/ every character
LCD_CURS_RL     = %00010100             ; Move the cursor R->L with every character drawn
LCD_CURS_LR     = %00010000             ; Move the cursor L->R with every character drawn
LCD_INIT        = %00111000             ; Initialize the LCD. This sets 8-bit data mode, 2 lines, 5x7 font. No reason to use anything else.
LCD_SET_CGRAM   = %01000000             ; OR WITH THE CGRAM ADDRESS YOU WANT TO USE!! OR JUST DONT MESS WITH IT!
LCD_SET_CURPOS  = %10000000             ; OR W/ the new cursor position you want!

; Shortcuts for common cursor positions! logical OR w/ LCD_SET_CURPOS to move the cursor there.
CURS_L1         = $00                   ; Line 1, Col 0
CURS_L2         = $40                   ; Line 2, Col 0
CURS_L3         = $14                   ; On 20x4 displays, line 3 is an extension of line 1.
CURS_L4         = $54                   ; Same with line 4. 16x4 displays may act different? check your datasheet.


; GFX LCD Definitions:
GLCD_RESET      = $10000000
GLCD_CS         = $10111111             ; AND with whatever else, to bring CS low!
GLCD_RS         = $00100000             ; Data/Command mode. 

; I'm not going to write all of the commands because it's a goddamn book!! 

LCD_BOOT:      ; Enable the VIA, initialize the LCD to 'default' mode
 PHA                                    ; Hold on to whatever's in A.
 PHY                                    ; And Y, we're going to use that for some other stuff.
 LDY            #LCD_E                  ; Specifically toggling the "E" bit.
 LDA            #$FF
 STA            LCD::DDRB               ; Set up our DDRs, both all outputs
 STA            LCD::DDRA             
 LDA            #0                      ; Make sure the ports are empty
 STA            LCD::CONTROL
 STA            LCD::CHRDAT
 LDA            #40                     ; 40 ms of delay, so the LCD can get up to stable voltage.
 JSR            delay                   ; Delay while the LCD wakes up
 LDA            #LCD_INIT               ; Prepare our init value
 STY            LCD::CONTROL            ; Flag Enable bit
 STA            LCD::CHRDAT             ; Get the data packet out
 DEC            LCD::CONTROL            ; Latch it.
 JSR            LCD_WAIT                ; Loops until LCD is ready
 STY            LCD::CONTROL            ; LCD_WAIT will put the command port back to 0, so we just need the "E" bit to toggle.
 LDA            #LCD_ON_BLINK           ; choose your preferred power-on setting. I'm going with blinky for now
 STA            LCD::CHRDAT             ; Make sure it's on the bus
 DEC            LCD::CONTROL            ; Latch.
 JSR            LCD_WAIT                ; Ensure it goes through.
 STY            LCD::CONTROL
 LDA            #LCD_CLEAR              ; Send a clear command, too.
 STA            LCD::CHRDAT             ; Launch it
 DEC            LCD::CONTROL            ; Latch it.
 PLY                                    ; Return our original Y register
 PLA                                    ; And our A register
 RTS                                    ; And go back to what we were doing before!
 
 
 

LCD_WAIT:      ; Wait for the LCD busy flag to clear
 PHA                                    ; Keep A saved safely away
 LDA            LCD::CONTROL            ; Pull our current control register
 AND            #($F0|LCD_RW)           ; Mask our control bits for the other screen
 STA            LCD::CONTROL
 LDA            #0                      ; Set our DDR to in on the data lines.
 YOURE HERE IN THE REWRITE
 STA            CHLCD::DDRB             
@READBUSY
 INC            CHLCD::CMDPORT          ; Fire the Enable bit
 LDA            CHLCD::DATAPORT         ; Load the byte
 DEC            CHLCD::CMDPORT          ; Release E
 AND            %10000000               ; Check if it's busy
 BNE            @READBUSY               ; If it is, try again.
 LDA            #$FF                    ; Busy flag cleared, turn the DDR back
 STA            CHLCD::DDRB
 LDA            #0  
 STA            CHLCD::CMDPORT          ; Let us return to INC/DEC mode.
 PLA                                    ; Don't forget the accumulator!
 RTS                                    ; Return!
 
; Definitions for the LCD module, attached via a WDC65C22 Versatile Interface Adapter.
; I use a 20x4 character one, because i want more text, but it should work for 16x2 as well
; Almost all of them use the same controller.

; This may also include the graphical LCD stuff too, but that's a later problem.

.IFNDEF delay
.include        "delay.s"
.ENDIF

; Define the VIA's ports. Make sure you use the right memory address!!
.struct CHLCD                           ; CHaracter LCD
.org $E000                              ; Mine lives at $E000 for now, it will change when i start using expansion buses.
DATAPORT        .byte                   ; PORTB on the VIA, for our data output 
CMDPORT         .byte                   ; PORTA, houses commands
DDRB            .byte                   ; DDR for PORTB
DDRA            .byte                   ; DDR for PORTA
.endstruct                              ; That's all we need for now, will take more when gfx are implemented.

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


DISP_BOOT:      ; Enable the VIA, initialize the LCD to 'default' mode.
 PHA                                    ; Hold on to whatever's in A.
 PHY                                    ; And Y, we're going to use that for some other stuff.
 LDY            #LCD_E                  ; Specifically toggling the "E" bit.
 LDA            #$FF
 STA            CHLCD::DDRB             ; Set up our DDRs, both all outputs
 STA            CHLCD::DDRA             
 LDA            #0                      ; Make sure the ports are empty
 STA            CHLCD::CMDPORT
 STA            CHLCD::DATAPORT
 LDA            #40                     ; 40 ms of delay, so the LCD can get up to stable voltage.
 JSR            delay                   ; Delay while the LCD wakes up
 LDA            #LCD_INIT               ; Prepare our init value
 STY            CHLCD::CMDPORT          ; Flag Enable bit
 STA            CHLCD::DATAPORT         ; Get the data packet out
 DEC            CHLCD::CMDPORT          ; Latch it.
 LDA            #1                      ; do a short delay before re-sending
 JSR            delay                   ; I think it needs the init command 3x to deal with 4-bit mode?
 STY            CHLCD::CMDPORT          ; honestly, i'm just doing it because the datasheet does
 LDA            #1                      ; re-loading the accum here so the pulse width isn't too short.
 DEC            CHLCD::CMDPORT          ; it would probably still be ok, but that's safety in case i boost past 1MHz
 JSR            delay                   ; last delay before we can be sure it stuck
 STY            CHLCD::CMDPORT          ; We need to wait after this so the pulse isn't too short.
 NOP                                    ; Probably don't even need to, but we just waited like 50ms, what's 2us?
 DEC            CHLCD::CMDPORT          ; OK, now we can actually use the busy flag!!
 JSR            LCD_WAIT                ; Loops until LCD is ready
 STY            CHLCD::CMDPORT          ; LCD_WAIT will put the command port back to 0, so we just need the "E" bit to toggle.
 LDA            #LCD_ON_BLINK           ; choose your preferred power-on setting. I'm going with blinky for now
 STA            CHLCD::DATAPORT         ; Make sure it's on the bus
 DEC            CHLCD::CMDPORT          ; Latch.
 JSR            LCD_WAIT                ; Ensure it goes through.
 STY            CHLCD::CMDPORT
 LDA            #LCD_CLEAR              ; Send a clear command, too.
 STA            CHLCD::DATAPORT         ; Launch it
 DEC            CHLCD::CMDPORT          ; Latch it.
 PLY                                    ; Return our original Y register
 PLA                                    ; And our A register
 RTS                                    ; And go back to what we were doing before!
 
 
 

LCD_WAIT:      ; Wait for the LCD busy flag to clear
 PHA                                    ; Keep A saved safely away
 LDA            #LCD_RW                 ; Prepare a read action
 STA            CHLCD::CMDPORT
 LDA            #0                      ; Set our DDR to in on the data lines.
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
 
; This file defines some ways to draw basic shapes, and otherwise manipulate the graphical lcd

.IFNDEF LCD_BOOT                        ; Just a random thing defined in our LCD subroutine, to make sure it's loaded
.INCLUDE lcd.s 
.ENDIF

.STRUCT GMEM                            ; Memory allocation for our program variables
.ORG $1000                              ; Storing them in a random spot for now, i should probably find somewhere better, tbh
XORIG           .BYTE                   ; X origin for our intended shape
XSIZE           .BYTE                   ; X Size for our intended shape
YORIG           .BYTE                   ; Y origin for our intended shape
YSIZE           .BYTE                   ; Y size for our intended shape


.ENDSTRUCT



.code  
draw_line: 
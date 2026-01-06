# Displays:

There are two displays connected to this system. One is a 320x240 LCD display, connected via SPI, and the other is a 20x4 character display, connected via parallel.

## Display Selection:

Display output is selected using i/o PORTA, with the lower nibble handling the control signals for the text display, and the uppper nibble controlling the graphical display. The plan (as it exists now) is to use defined shortcuts for each type of command, to ensure they do not overlap.

PORTB will send data to the LCD, using the 8-bit communication mode. I may change this in the future to be the 4-bit mode and then I can free up another port for other things.


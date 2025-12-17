# Displays:

There are two displays connected to this system. One is a 320x240 LCD display, connected via SPI, and the other is a 20x4 character display, connected via parallel.

## Display Selection:

Display output is selected using i/o PORTA, with the lower nibble handling the control signals for the text display, and the uppper nibble controlling the graphical display. The plan (as it exists now) is to use defined shortcuts for each type of command, to ensure they do not overlap.

PORTB is reserved for packet data itself. For the text display, the 8-bit data packet is directly output on the bus. For the graphical display, PORTB is switched to serial communications mode.



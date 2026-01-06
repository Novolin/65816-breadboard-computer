# 65816-breadboard-computer
My Personal 65C816 breadboard build, including schematics, etc.

/KiCad contains my schematics/raw kicad files, if you want to laugh at my design.

/Software contains the programs I've written, mostly raw assembly, but I will hopefully have a C compiler up and running eventually.

/Docs will have a variety of documents on the exact nature of each hardware decision and how it works. I'll also be publishing these to a blog on my web zone. 

# Hardware Description:

This system is designed to use modular components, with room for expansion in RAM or I/O, using programmable logic. 

The primary CPU is a W65C816, which handles all logic/program execution. The "Bare Minimum" setup includes 32k of RAM and 32K of ROM space, both of which are placed on the primary controller board. The CPU is driven to 1 MHz by a divided clock oscillator, which provides a 2-phase clock signal, for any devices that may need it.

Expansion is handled through a 2x20 pin slot, so I can use a standard floppy drive cable to send it to a breakout board or other device.

## Graphical Output:

Despite my original intentions to use a z80 to drive a 320x240 display via weird magic bullshit, I have decided to switch to having the CPU directly control the display via the VIA's PORTB, though I will be sharing this with the 16x2 LCD thanks to some Ideas about how to handle I/O. See Docs/Displays for details.


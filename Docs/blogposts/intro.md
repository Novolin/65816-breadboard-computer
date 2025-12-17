# 65C816-Based Homebrew Computer! Part one: The beginnings.

I've been following Ben Eater's 6502 homebrew computer[LINK] for a while, and wanted to do something similar myself. Upon discussing things in the Usagi Electric discord, I decided to use a W64C816S, the successor to the 6502, for a few reasons. First of all: it should be drop-in compatible with Ben's design (at least the early stages). Once I get my feet wet, I can branch out and do a lot more. Secondly, getting a 6502 would have been a whopping $2 less than an '816, so I might as well get the more powerful option, and have room to grow and play around.

## Goals:
At the start, my goals were vague, just to make something that worked, but now I've solidified on a concept:
1. Have a functional computer 
2. Allow connection via serial to another system
3. Have a graphical and text display
4. Enable future expansion/tinkering
    - Human Interface Devices of some form
    - Swapping of graphics/serial/whatevs
5. Get some PCBs made.



### Goal 1: Have a functioning computer.
This is a simple ask: it should be able to run the code that is placed on it, and do stuff. I'm not asking for perfection, but just for it to work. Arguably, this is the hardest part to actually achieve.

### Goal 2: Serial Connections
I want to communicate with the computer beyond inserting a new ROM chip, allowing for new programs/etc. A serial connection, using the 65C51 SIA is the best option, since it's in the ecosystem and has good documentation available for it. While using an RS-232 port and UART-to-usb or whatever is an option if I wanted to keep the hardware Authentic, I'm going to be lazy and just use an Arduino Micro as a USB serial adapter. This eases the adapter headaches, since it's able to do the USB -> serial translation, and it's cheap. If I get bitten by the retro-communications bug, I can figure out some other adapter situation and drop it in for ease of use. 

### Goal 3: Graphical and Text Display
Having a system that communicates only via serial is not what I am hoping for with this project. I want to be able to see/read things on a screen, and I purchased a 20x4 LCD display for this project, and repurposed a 320x240 LCD that I've had kicking around for graphical stuff. I've had a few ideas that went bust on this front, and I'll write them up at some point.

### Goal 4: Enable Future Expansion
Making a one-and-done system is a fun project, but I am unable to truly "finish" anything, so my way out for this is to have expansion buses on the system, allowing for more storage, devices, interfaces, etc. These buses will have access to the main CPU lines that I'll need, as well as address/data lines. Since I'm using Programmable Logic Devices as bus controllers, it's easy enough to daisy-chain my ports if needed.

### Goal 5: Get PCBs made
I've never designed a PCB. I did get some made using an open-source design once, but this is a new opportunity for me to expand my skillset, and experiment. It's a scary step, and not the cheapest, but I'm excited to do it. I'll likely use a manufacturing service, instead of etching/machining my own, but even the design process has taught me a lot.
PCBs are also critical for future expansion, since there's only so many breadboards I can manage.


In the short term, my focus has been on the first goal, having *anything* functional, before moving on to dealing with the others. So far, it's eluded me, but I have a hardware tweak that I have yet to test, which should make things fully functional.


## Hardware
As I mentioned at the start, I'm using a W65C816 processor, both due to price similarity to the 6502, but also due to its 24-bit memory addressing.

The 6502 uses a 16-bit memory bus, allowing for up to 64 Kilobytes of addressible memory, be it RAM, ROM, I/O or other stuff. The '816 uses some funky timing and the 8-bit data lines to increase the bus width to 24 bits, allowing for 16 **Mega**bytes of address space. There are also a variety of changes to the processor architecture which allow for 16-bit math, and a number of other changes. I'm not a 6502/65816 wizard, I'm barely what you would call a beginner, but the '816 is just an improved processor at the end of the day.

RAM is currrently divided into 32K SRAM chips, HM62256 clones from Aliexpress, and my total of 5 chips should lead to about 160 Kb of RAM total, which is more than enough for what I'm doing at the moment. 

My ROM is an AT28C256, also off Aliexpress, giving 32K of ROM space. With the addition of serial communications, this should be more than enough to handle the code needed to get things loaded into RAM.

Logic switching is handled by an AT16V8B, a derivitive of the GAL16V8B Programmable Logic Device (PLD). Why PLDs, instead of 74XX logic? Early experiments with graphics adapters led to me needing the ability to latch various control signals, and - once again - sourcing some chips from Aliexpress meant getting 5 of the dang things, so I might as well switch to using 'em. This also eases the burden on addressing expansion signals, since a simple re-flash is all it takes to change the routing (though PLDs do have a limited life-span, and I'll try to avoid re-flashing if possible.)
After a few expansions, it becomes messy as hell to use discrete logic ICs for each change, and that's not something I felt like playing with, especially since early prototyping meant limited breadboard space.


My clock oscillator runs at 16 MHz, which I am dividing three times to bring it to a more managable 2 MHz. I will be able to speed things up in the future, but this should be more than enough for anything I'm planning on.


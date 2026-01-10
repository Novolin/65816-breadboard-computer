#!/bin/sh

if [ -d assembler ]; then
    echo "Github container found!"
    echo "Assembling..."
    ./assembler/cc65/bin/ca65 helloagain.s
    echo "Linking..."
    ./assembler/cc65/bin/ld65 helloagain.o -C compatconfig.conf -o output.bin
    echo "Done!"
else
    echo "Native directory, assuming ca65 is set up correctly..."
    echo "Assembling..."
    ca65 helloagain.sh
    echo "Linking, will output to 'output.bin'"
    ld65 helloagain.o -C compatconfig.conf -o output.bin
    echo "Done!"
fi
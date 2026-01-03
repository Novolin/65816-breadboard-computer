This folder contains modules designed for individual components of the build

Remember to check the addresses defined in the structs in each file! Make sure they match real hardware!!

I am using CA65 as my assembler, so code is formatted for that. I'll write a lil baby script to compile on linux, at some point.

IOMEM only goes up to $01800F, the top address of the ACIA.

reminder: update schematic to include the vrom chip!!
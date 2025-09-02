# Micropython-based eeprom programmer
# designed to work with pi pico
# v 0.2

from machine import Pin

# ROM Sizes, for checking later
32K_ROMLEN = 0x8000 
16K_ROMLEN = 0x4000
8K_ROMLEN = 0x2000

# Pin assignments
ready_led = Pin(20, Pin.OUTPUT)
busy_led = Pin(20, Pin.OUTPUT)



sr_oe = Pin(2, Pin.OUTPUT)
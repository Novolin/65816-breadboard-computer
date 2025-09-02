# Micropython-based eeprom programmer
# designed to work with pi pico
# v 0.2

from machine import Pin #type:ignore

# ROM Sizes, for checking later
sizelist = (0x8000, 0x4000, 0x2000)
ROMLEN_32K = 0x8000 
ROMLEN_16K = 0x4000
ROMLEN_8K = 0x2000

class AddressRegister:
    # Class to hold our shift register stuff
    def __init__(self, oe, clk, dat, clr) -> None:
        self.oe = Pin(oe, Pin.OUTPUT)
        self.clk = Pin(clk, Pin.OUTPUT)
        self.dat = Pin(dat, Pin.OUTPUT)
        self.clr = Pin(clr, Pin.OUTPUT)
        self.value = -1 # Bus is not set
        self.clr.value(1)


    def clear(self):
        self.clr.value(0)
        self.clk.value(1)
        self.clk.value(0)
        self.clr.value(1)

    def set_value(self, value):
        self.oe.value(1)
        for i in range(16):
            nextbit = value & (1<<i)
            self.dat.value(nextbit) # I think this is truthy-falsey? so anything > 0 counts as on?
            self.clk.value(1)
            self.clk.value(0)
        # Pulse the clock one more time to put the shift register data in the output register, since we tied the pins together
        self.clk.value(1)
        self.clk.value(0)
        self.oe.value(0)
        self.value = value


class DataBus:
    def __init__(self, pins:list) -> None:
        self.value = 0
        self.pins = []
        for p in pins:
            self.pins.append(Pin(p, Pin.OUTPUT))
    
    def write_value(self, value):
        self.value = value
        for i in range(8):
            if value << i > 0:
                self.pins[i].value(1)
            else:
                self.pins[i].value(0)

    def read_value(self)-> int:
        self.value = 0
        for i in range(8):
            if self.pins[i].value():
                self.value += 1 << i
        return self.value
    
class EEPROM:
    def __init__(self, rw, oe, ce, size = ROMLEN_32K, writeprotect = False):
        if size not in sizelist:
            raise ValueError
        self.size = size
        self.rw = Pin(rw, Pin.OUTPUT)
        self.oe = Pin(oe, Pin.OUTPUT)
        self.ce = Pin(ce, Pin.OUTPUT)
        self.writeprotect = writeprotect # Is our EEPROM write protected?


    
    

# Pin assignments
ready_led = Pin(20, Pin.OUTPUT)
busy_led = Pin(19, Pin.OUTPUT)
error_led = Pin(18, Pin.OUTPUT)
ready_led.value(0)      # Do some nice startup lights while we do other stuff
error_led.value(1)
busy_led.value(1)

address_reg = AddressRegister(2, 3, 4, 5)
dbus = DataBus([6,7,8,9,10,11,12,13])
prom = EEPROM(25, 24, 23)

ready_led.value(1)
error_led.value(0)
busy_led.value(0)

target_file = ""
data = bytearray(0)


def send_byte(address, value):
    # Write "value" to "address", leaving CE active at the end, so things latch nicely.
    if address > prom.size:
        raise ValueError # ADDRESS TOO BIG, MY MAN!
    prom.ce.value(1)
    prom.oe.value(1)
    if prom.rw.value():
        prom.rw.value(0)
    
    address_reg.set_value(address)
    dbus.write_value(value)
    prom.ce.value(0)


def end_write_cycle():
    prom.ce.value(1)
    


def disable_write_protect():
    # Disables the software write protection on the EEPROM
    if prom.writeprotect and prom.size == ROMLEN_32K:
        pass
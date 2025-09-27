# Micropython-based eeprom programmer
# designed to work with pi pico
# v 0.2

from machine import Pin #type:ignore
from time import sleep_ms #type:ignore

PIN_OE = 3
PIN_WE = 2
PIN_CE = 4

LED_R = 27
LED_Y = 28
LED_G = 29

BUTT = 26

SR_DAT = 13
SR_OE = 14
SR_RESET = 5
SR_CLK = 6

DATAPINS = [18, 19, 20, 21, 22, 23, 24, 25]

# ROM Sizes, for checking later
sizelist = (0x8000, 0x4000, 0x2000)
ROMLEN_32K = 0x8000 
ROMLEN_16K = 0x4000
ROMLEN_8K = 0x2000

class AddressRegister:
    # Class to hold our shift register stuff
    def __init__(self, oe, clk, dat, reset) -> None:
        self.oe = Pin(oe, Pin.OUT)
        self.clk = Pin(clk, Pin.OUT)
        self.dat = Pin(dat, Pin.OUT)
        self.reset = Pin(reset, Pin.OUT)
        self.value = -1 # Bus is not set
        self.oe.value(0)
        self.clear()


    def clear(self):
        self.dat.value(0)
        self.reset.value(1)
        sleep_ms(1)
        self.clk.value(1)
        sleep_ms(1)
        self.clk.value(0)
        sleep_ms(1)
        self.reset.value(0)
        self.clk.value(1)
        sleep_ms(1)
        self.reset.value(1)
        self.oe.value(0)
        self.value = 0

    def set_value(self, value):
        # we have to flip the bits because my idiot ass wired the shift registers basically in reverse:
        bflip = 1 << 16
        for i in range(16):
            if bflip >> i & value:
                self.dat.value(1) # I think this is truthy-falsey? so anything > 0 counts as on?
            else:
                self.dat.value(0)
            sleep_ms(1)
            self.clk.value(0)
            sleep_ms(1)
        
            self.clk.value(1)
        # Pulse the clock one more time to put the shift register data in the output register, since we tied the pins together
        self.clk.value(0)
        sleep_ms(1)

        self.clk.value(1)
    
        sleep_ms(1)
        self.value = value


class DataBus:
    def __init__(self, pins:list) -> None:
        self.value = 0
        self.pins = []
        for p in pins:
            self.pins.append(Pin(p, Pin.OUT))
    
    def write_value(self, value):
        self.value = value
        for i in range(8):
            if (value >> i) & 1:
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
        self.rw = Pin(rw, Pin.OUT)
        self.oe = Pin(oe, Pin.OUT)
        self.ce = Pin(ce, Pin.OUT)
        self.writeprotect = writeprotect # Is our EEPROM write protected?


    
# TESTING THE HARDWARE SO I DONT LET THE SMOKE OUT

a_bus = AddressRegister(SR_OE, SR_CLK, SR_DAT, SR_RESET)
d_bus = DataBus(DATAPINS)
controls = [Pin(LED_R, Pin.OUT), Pin(LED_Y, Pin.OUT), Pin(LED_G, Pin.OUT), Pin(PIN_WE, Pin.OUT), Pin(PIN_CE, Pin.OUT), Pin(PIN_OE, Pin.OUT)]
c_label = ["Red!", "Yellow!", "Green!", "Write Enable!", "Chip Enable!", "Output Enable!"]
Button = Pin(BUTT, Pin.IN, Pin.PULL_DOWN)


# Test Suite:
d_bus.write_value(0)
print("Testing Controls! Press Button to continue:")
for i in range(6):
    print(c_label[i])
    controls[i].value(1)
    while Button.value() == False:
        sleep_ms(1)
    sleep_ms(250) # debounce/ slow ya down
    controls[i].value(0)

print("Pulling Data Bus HI!")
d_bus.write_value(255)
while Button.value()==False:
    sleep_ms(1)
sleep_ms(250)
d_bus.write_value(0)
print("Writing to Address Bus!")

shift = 0
while shift < 16:
    a_bus.set_value(1<< shift)
    print(shift)
    while Button.value() == False:
        sleep_ms(1)
    sleep_ms(500)
    shift = shift + 1
print( "DONE")




'''# Pin assignments
ready_led = Pin(20, Pin.OUT)
busy_led = Pin(19, Pin.OUT)
error_led = Pin(18, Pin.OUT)
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
        '''
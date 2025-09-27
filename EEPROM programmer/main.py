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
            self.pins.append(Pin(p, Pin.IN, Pin.PULL_DOWN))
        self.mode = 0 # 0 = input
    
    def write_value(self, value):
        if not self.mode:
            self.set_mode("output")
        self.value = value
        for i in range(8):
            if (value >> i) & 1:
                self.pins[i].value(1)
            else:
                self.pins[i].value(0)

    def read_value(self)-> int:
        if self.mode:
            self.set_mode("input")
        self.value = 0
        for i in range(8):
            if self.pins[i].value():
                self.value += 1 << i
        return self.value
    def set_mode(self, mode:str):
        if mode == "input":
            self.mode = 0
            for p in self.pins:
                p.mode = Pin.IN
                p.pull = Pin.PULL_DOWN
        elif mode == "output":
            self.mode = 1
            for p in self.pins:
                p.mode = Pin.OUT
                p.value(0)


class EEPROM:
    def __init__(self, rw, oe, ce, size = ROMLEN_32K, writeprotect = False):
        if size not in sizelist:
            raise ValueError
        self.size = size
        self.rw = Pin(rw, Pin.OUT)
        self.oe = Pin(oe, Pin.OUT)
        self.ce = Pin(ce, Pin.OUT)
        self.writeprotect = writeprotect # Is our EEPROM write protected?
        self.file_data = bytes() 
        

    def write_pulse(self):
        # sends the signals to the PROM to latch data from the data bus
        self.oe.value(1) # ensure output enable is low
        self.ce.value(0) # ensure chip enable is low
        sleep_ms(1) # i think timing requires both to be on for a hair, so just be safe.
        self.rw.value(0)
    
    def end_write_pulse(self):
        self.ce.value(1)
        self.rw.value(1) # doing both just to be safe.
    
    def send_read_pulse(self):
        self.rw.value(1)
        self.oe.value(0)
        sleep_ms(1)
        self.ce.value(0)
    
    def end_read_pulse(self):
        self.rw.value(1)
        self.ce.value(1)
        self.oe.value(1)

class TaskManager:
    # Class you can call to do loops and shit while things load.
    def __init__(self, addresses:AddressRegister, data_bus:DataBus, rom:EEPROM, file = "program.bin"):
        self.error = False
        self.romfile = file
        self.romsize = None
        self.address_bus = addresses
        self.data_bus = data_bus
        self.rom = rom
        self.read_data = bytearray()

    def raise_error(self):
        self.error = True

    def load_file(self): 
        # Set up the data stuff we need
        
        with open(self.romfile, "rb") as indata:
            data = indata.read()
        if len(data) > self.rom.size:
            print("ERROR: Data too big for chosen EEPROM!!")
        elif len(data) < self.rom.size: 
            print("File smaller than EEPROM! Padding start.\nThis may break hard-coded ROM calls")
            dat_diff = self.rom.size - len(data)
            newdat = bytearray(bytes(0) * dat_diff)
            for b in data:
                newdat.append(b)
            data = newdat
        self.rom.file_data = data
    
    
    def write_file(self):
        print("Writing Data...")
        busy_led.value(1)
        ready_led.value(0)
        act_led.value(1)
        self.data_bus.set_mode("output")
        for i in range(self.rom.size):
            self.address_bus.set_value(i)
            self.data_bus.write_value(self.rom.file_data[i])
            self.rom.write_pulse()
            act_led.value(0)
            if i % 100:
                print(".", end="")
            self.rom.end_write_pulse()
            act_led.value(1)
        print("Done! Verifying!")
        self.data_bus.set_mode("input")
        
        for i in range(self.rom.size):
            pass

    def loop(self):
        # For now, just do one file, hardcoded.
        ready_led.value(1)
        busy_led.value(0)
        act_led.value(0)



        while True:
            if self.error: # Hard loop, requiring a reset. 
                busy_led.value(1)
                ready_led.value(0)
                act_led.value(0)
                sleep_ms(500)
                busy_led.value(0)
                act_led.value(1)
                sleep_ms(500)
                continue
            





busy_led = Pin(LED_R, Pin.OUT) # Red LED signalling you shouldn't fuck with the ROM
busy_led.value(1)
act_led = Pin(LED_Y, Pin.OUT) # led to mark when we're doin shit
act_led.value(1)
ready_led = Pin(LED_G, Pin.OUT) # led to signal we are ready to go :)
ready_led.value(0)
button = Pin(BUTT, Pin.IN, Pin.PULL_DOWN) # use the internal pulldown because i dont want to solder another fuckin resistor

tm = TaskManager(AddressRegister(SR_OE, SR_CLK, SR_DAT, SR_RESET), DataBus(DATAPINS), EEPROM(PIN_WE, PIN_OE, PIN_CE))
tm.load_file()



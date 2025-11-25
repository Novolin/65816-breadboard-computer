# Micropython-based eeprom programmer
# designed to work with pi pico
# v 0.3
# Semi-rewritten

from machine import Pin #type:ignore
from time import ticks_ms, ticks_add, ticks_diff, sleep_us #type:ignore

# Pin defs should stay the same since everything is soldered.
ROM_OE = 3
ROM_WE = 2
ROM_CE = 4

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
ROMLEN_32K = 0x8000 
ROMLEN_16K = 0x4000
ROMLEN_8K = 0x2000

class LightsAndButt:
    # This controls our lights and buttons:
    def __init__(self, button = BUTT, busy = LED_R, ready = LED_G, activity = LED_Y):
        self.button = Pin(button, Pin.IN, Pin.PULL_DOWN)
        self.busy = Pin(busy, Pin.OUT)
        self.ready = Pin(ready, Pin.OUT)
        self.act = Pin(activity, Pin.OUT)
        self.busy.on()
        self.ready.off()
        self.act.off()

    def wait_for_button(self) -> bool:
        # Waits infinitely for someone to hit the button.
        self.set_ready()
        while self.button():
            sleep_us(100)
        return True
    
    def set_ready(self):
        self.ready.on()
        self.busy.off()
        self.act.off()

    def set_busy(self):
        self.ready.off()
        self.busy.on()
    
class ShiftReg:
    # Shift register functions in one nice little home.
    def __init__(self, dat = SR_DAT, oe = SR_OE, reset = SR_RESET, clk = SR_CLK):
        self.dat = Pin(dat, Pin.OUT)
        self.oe = Pin(oe, Pin.OUT)
        self.reset = Pin(reset, Pin.OUT)
        self.clk = Pin(clk, Pin.OUT)
        self.out_val = 0 # What the current value on output is


    def set_value(self, new_value):
        # we have to flip the bits because my idiot ass wired the shift registers basically in reverse:
        bflip = 1 << 16
        for i in range(16):
            if bflip >> i & new_value:
                self.dat.on() # I think this is truthy-falsey? so anything > 0 counts as on?
            else:
                self.dat.off()
            self.clk.off()
            sleep_us(50) # Hopefully enough time?
            self.clk.on()
        # Pulse the clock one more time to put the shift register data in the output register, since we tied the pins together
        self.clk.off()
        sleep_us(150)
        self.clk.on()
        sleep_us(150)
        self.out_val = new_value
    
    def clear(self):
        self.dat.off()
        self.reset.off()
        sleep_us(150)
        self.clk.on()
        sleep_us(150)
        self.clk.off()
        sleep_us(150)
        self.reset.on()
        self.clk.on()
        sleep_us(150)
        self.oe.off()
        self.value = 0

class Programmer:
    # Just going to use one fuckin huge programmer object.
    def __init__(self, filetarget:str = "program.bin", targetsize = ROMLEN_32K):
        self.filetarget = filetarget # What file to write to the ROM
        self.targetsize = targetsize # How big is the EEPROM we're going for
        self.prog_data = bytearray()
        # Blinken Lights
        self.lights = LightsAndButt()
        self.lights.set_busy()

        # Init our control pins as generic inputs (high-Z)
        self.rom_ce = Pin(ROM_CE, Pin.OUT) 
        self.rom_ce.on()
        self.rom_oe = Pin(ROM_OE, Pin.OUT)
        self.rom_oe.on()
        self.rom_we = Pin(ROM_WE, Pin.OUT)
        self.rom_we.on()
        self.sr = ShiftReg()
        self.data_dir = Pin.IN # Use the built in pin stuff because lol
        self.dat_pins = []
        for i in DATAPINS:
            self.dat_pins.append(Pin(i, self.data_dir))
        

    def set_data_dir(self, direction:Pin.IN|Pin.OUT):
        # Set the direction of the data bus
        # Do I need to mess with mode if I'm reading because I messed up and used the one connected to the built in led?
        for i in self.dat_pins:
            i.init(direction)
        self.data_dir = direction

    def read_value(self, address:int) -> int:
        self.lights.set_busy()
        # Reads the value of the rom at the given address
        if address > self.targetsize:
            print("Error! read address out of bounds!")
            return -1
        if self.data_dir != Pin.IN:
            self.set_data_dir(Pin.IN)
        self.sr.set_value(address)
        val = 0
        # signal the ROM to output data:
        self.rom_oe.off()
        self.rom_ce.off()
        for i in range(8):
            val |= self.dat_pins[i]() << i # mess with shifting to make sure it's correct.
        self.rom_oe.on()
        self.rom_ce.on()
        self.lights.set_ready()
        return val
    
    def write_val(self, address, value):
        # First do some goofs w/ lights becasue obv. that's the most importanantent
        if address & 0b10000000: # This should make the activity light blink semi-regularly, as if things are happening :)
            self.lights.act.on()
        else:
            self.lights.act.off() 
        # Set our buses before fuckin with the rom:
        self.sr.set_value(address)
        for i in range(8):
            if 1 << i  & value:
                self.dat_pins[i].on()
            else:
                self.dat_pins[i].off()
        self.rom_ce.off()
        sleep_us(150)
        self.rom_we.off()
        sleep_us(150)
        self.rom_we.on()
        self.rom_ce.on()


    def write_file(self):
        # Loads program.bin and then writes the file to ROM.
        # Load the program as part of this function, so you don't have to soft reset every fucking time you change it

        self.lights.set_busy()
        self.lights.act.on()
        print("Loading from file:" , self.filetarget)
        with open(self.filetarget, "rb") as filedata:
            for b in filedata.read():
                self.prog_data.append(b)
        if len(self.prog_data) > self.targetsize:
            print("File too large! Contains ", len(self.prog_data), " Bytes, expected at most ", self.targetsize, "! Truncating to target ROM size!" )
        elif len(self.prog_data) < self.targetsize:
            print("File too small! Padding ROM with $00 ", self.targetsize - len(self.prog_data), " times! Interrupt vectors might break!")
            while len(self.prog_data) < self.targetsize:
                self.prog_data.append(0)

        self.lights.act.off() # turn off act light while we prepare our buses, becvause it makes flashy :) :) :) 
        print("Writing data:")
        self.set_data_dir(Pin.OUT)
        progress = 0
        for i in range(self.targetsize):
            self.write_val(i, self.prog_data[i])
            # Give a printed progress status:
            if self.targetsize // i != progress:
                progress = (self.targetsize // 10) // i # Should be in 10% blocks:
                print("\r[" + ("=" * progress) + (" " * (10 - progress)) + "]", end="")
        print(" Done!")

        #TODO: once writing works, do a verify.



''' OLD:
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
        busy_led.on()
        ready_led.off()
        act_led.on()
        self.data_bus.set_mode("output")
        for i in range(self.rom.size):
            self.address_bus.set_value(i)
            self.data_bus.write_value(self.rom.file_data[i])
            self.rom.write_pulse()
            act_led.off()
            if i % 100:
                print(".", end="")
            self.rom.end_write_pulse()
            act_led.on()
        print("Done! Verifying!")
        self.data_bus.set_mode("input")
        
        for i in range(self.rom.size):
            pass

    def loop(self):
        # For now, just do one file, hardcoded.
        ready_led.on()
        busy_led.off()
        act_led.off()



        while True:
            if self.error: # Hard loop, requiring a reset. 
                busy_led.on()
                ready_led.off()
                act_led.off()
                sleep_ms(500)
                busy_led.off()
                act_led.on()
                sleep_ms(500)
                continue
            

'''
# generates a rom for testing our writer:

count = bytearray(1)
with open("sequence.bin", "wb") as romfile:
    for i in range(0x8000):
        romfile.write(count)
        if count[0] == 0xFF:
            count[0] = 0
        else:    
            count[0] = count[0] + 1
        

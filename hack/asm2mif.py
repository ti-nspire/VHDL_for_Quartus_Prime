import sys
from Hack_Assembler import *

class asm2mif:
    def __init__(
        self,
        asm_file_path,
        mif_name = "rom_init.mif",
        rom_words = 4096,
        screen_address = 8192,
        keyboard_address = 8576,
        out_port_address = 8577):

        file_path = ""
        try:
            file_path = sys.argv[1]
        except:
            file_path = asm_file_path
        hack_assembler = Hack_Assembler(
            asm_file_path = file_path,
            screen_address = screen_address,
            keyboard_address = keyboard_address,
            out_port_address = out_port_address)
        
        self.hack_file = hack_assembler.get_hack_file()

        self.__generate_mif(self.hack_file,
                            mif_name,
                            rom_words = rom_words)

    def __generate_mif(self, bit_strings, mif_path, rom_words):
        f = open(mif_path, "w")
        f.write("WIDTH=%d;\n" % 16)
        f.write("DEPTH=%d;\n" % rom_words)
        f.write("ADDRESS_RADIX=UNS;\n")
        f.write("DATA_RADIX=BIN;\n")
        f.write("CONTENT BEGIN\n")
        for i in range(len(bit_strings)):
            f.write("%10d: %s;\n" % (i, bit_strings[i]))
        f.write("END;\n")
        f.close()

if __name__ == "__main__":
    asm2mif(
        asm_file_path = "test.asm",
        mif_name = "rom_init.mif",
        rom_words = 4096,
        screen_address = 8192,
        keyboard_address = 8576,
        out_port_address = 8577)

def generate_mif(file_name, width, depth, rom):
    f = open(file_name, "w")
    f.write("WIDTH=%d;\n" % width)
    f.write("DEPTH=%d;\n" % depth)
    f.write("ADDRESS_RADIX=UNS;\n")
    f.write("DATA_RADIX=BIN;\n")
    f.write("CONTENT BEGIN\n")
    format_of_code = "0" + str(width) + "b"
    for i in range(depth):
        machine_code = format(rom[i], format_of_code)
        f.write("%10d   :   %s;\n" % (i, machine_code))
    f.write("END;\n")
    f.close()

def LD_A(Data)   : return ( 0 << 4)|(Data & 0xF)    # A ← [Data]
def LD_B(Data)   : return ( 1 << 4)|(Data & 0xF)    # B ← [Data]
def LD_AB()      : return ( 2 << 4)                 # A ← B
def LD_BA()      : return ( 3 << 4)                 # B ← A
def ADD_AB()     : return ( 4 << 4)                 # A ← A + B
def SUB_AB()     : return ( 5 << 4)                 # A ← A - B
def ADD_A(Data)  : return ( 6 << 4)|(Data & 0xF)    # A ← A + [Data]
def SUB_A(Data)  : return ( 7 << 4)|(Data & 0xF)    # A ← A - [Data]
def OUT_A()      : return ( 8 << 4)                 # OUT ← A
def OUT_B()      : return ( 9 << 4)                 # OUT ← B
def OUT(Data)    : return (10 << 4)|(Data & 0xF)    # OUT ← [Data]
def IN_A()       : return (11 << 4)                 # A ← IN
def JUMP(Address): return (12 << 4)|(Address & 0xF) # PC ← [Address]
def JNC(Address) : return (13 << 4)|(Address & 0xF) # PC ← [Address] if NOT Carry
def JNZ(Address) : return (14 << 4)|(Address & 0xF) # PC ← [Address] if NOT Zero
def HALT()       : return (15 << 4)                 # HALT

FILE_NAME = "rom_init.mif"
WIDTH =  8
DEPTH = 16
_ = [0] * DEPTH

#1～5の総和を求める
pc = -1
_[(pc:=pc+1)] = LD_A(1)
_[(pc:=pc+1)] = OUT_A()
_[(pc:=pc+1)] = ADD_A(2)
_[(pc:=pc+1)] = OUT_A()
_[(pc:=pc+1)] = ADD_A(3)
_[(pc:=pc+1)] = OUT_A()
_[(pc:=pc+1)] = ADD_A(4)
_[(pc:=pc+1)] = OUT_A()
_[(pc:=pc+1)] = ADD_A(5)
_[(pc:=pc+1)] = OUT_A()
_[(pc:=pc+1)] = LD_A(0)
_[(pc:=pc+1)] = LD_A(0)
_[(pc:=pc+1)] = LD_A(0)
_[(pc:=pc+1)] = LD_A(0)
_[(pc:=pc+1)] = LD_A(0)
_[(pc:=pc+1)] = OUT(0)

generate_mif(FILE_NAME, WIDTH, DEPTH, _)

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


# テキストのプログラム例(2)
# インポートとアウトポートとを直結しておく。
# 5+4+3+2+1=15を計算する。
# 0101(5)、1001(9)、1100(12)、1110(14)、1111(15)の順に出力される。
_[0] = LD_A(0)  # 総数の初期値と
_[1] = LD_B(5)  # ループ回数、兼、足される数と
_[2] = ADD_AB() # を足して、
_[3] = OUT_A()  # それを出力して、
_[4] = LD_AB()  # ループ回数、兼、足される数をAレジスタに退避して
_[5] = SUB_A(1) # それをデクリメントして、
_[6] = JNZ(8)   # それが0でなければ、
_[7] = HALT()
_[8] = LD_BA()  # それをBレジスタに戻して、
_[9] = IN_A()   # 総数(今OUTレジスタにある)をAレジスタに読み込んで、
_[10] = JUMP(2) # また加算を繰り返す。


generate_mif(FILE_NAME, WIDTH, DEPTH, _)

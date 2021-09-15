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


# テキストのプログラム例(4)
# インポートとアウトポートとを直結しておく。
# 9/2=4(0100)余り1を計算する。
# 0111(9-2=7)、0101(9-2-2=5)、0011(9-2-2-2=3)、0001(9-2-2-2-2=1)の順に表示されたあと、
# 0100(9/2=4)と表示される。
_[0] = LD_A(9)  # 割られる数
_[1] = LD_B(0)  # 何回引き算ができたかの初期値
_[2] = SUB_A(2) # 割る数(引く数)
_[3] = JNC(10)  # 引いた結果が負なら、ループを抜けて10番地へ
_[4] = OUT_A()  # 今の引き算結果(すなわち余り)を出力して、
_[5] = LD_AB()  # 引き算できた回数をこの3行でインクリメントして、
_[6] = ADD_A(1)
_[7] = LD_BA()
_[8] = IN_A()   # 今の引き算結果(すなわち余り)(今OUTレジスタにある)を読み込んで、
_[9] = JUMP(2)  # 引き算を繰り返す。
_[10] = IN_A()  # (引いた結果が負なら3番地から)余り(今OUTレジスタにある)をAに格納し、
_[11] = OUT_B() # 商(何回引き算ができたか)を出力する。
_[12] = HALT()

generate_mif(FILE_NAME, WIDTH, DEPTH, _)

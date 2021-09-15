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

############################################
# テキストの障害物回避ロボットのプログラム #
############################################

# 両輪を前転して(前進して)、
_[0] = OUT(0b1010)
    
# 何かにぶつかってマイクロスイッチが押されるまで(0が入力されるまで)その状態を続けて、
_[1] = IN_A()
_[2] = SUB_A(0)
_[3] = JNZ(1)
    
# 何かにぶつかったら(スイッチが押されたら)両輪を後転して(後進して)、
_[4] = OUT(0b0101)
    
# 少しの間、その状態を続けて、
_[5] = LD_A(7)
_[6] = SUB_A(1)
_[7] = JNZ(6)
    
# 両輪にブレーキをかけて、
_[8] = OUT(0b1111) # OUT(0b0000)にすればブレーキではなく空転。ただしwormギヤなのでどちらでもほぼ関係ない。
    
# 少しの間、その状態を続けて、
_[9] = LD_A(3)
_[10] = SUB_A(1)
_[11] = JNZ(10)
    
# 右輪前転、左輪後転して(左回転して)、
_[12] = OUT(0b0110)
    
# 少しの間、その状態を続けて、
_[13] = LD_A(9)
_[14] = SUB_A(1)
_[15] = JNZ(14)
# 0番地に戻る。


generate_mif(FILE_NAME, WIDTH, DEPTH, _)

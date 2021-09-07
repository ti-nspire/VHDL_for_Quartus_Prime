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

def MOV_A(Im): return ( 3 << 4) | (Im & 0xF) # AレジスタにImを転送
def MOV_B(Im): return ( 7 << 4) | (Im & 0xF) # BレジスタにImを転送
def MOV_AB() : return ( 1 << 4)              # AレジスタにBレジスタを転送
def MOV_BA() : return ( 4 << 4)              # BレジスタにAレジスタを転送
def ADD_A(Im): return ( 0 << 4) | (Im & 0xF) # AレジスタにImを加算
def ADD_B(Im): return ( 5 << 4) | (Im & 0xF) # BレジスタにImを加算
def IN_A()   : return ( 2 << 4)              # 入力ポートからAレジスタへ転送
def IN_B()   : return ( 6 << 4)              # 入力ポートからBレジスタへ転送
def OUT(Im)  : return (11 << 4) | (Im & 0xF) # 出力ポートへImを転送
def OUT_B()  : return ( 9 << 4)              # 出力ポートへBレジスタを転送
def JMP(Im)  : return (15 << 4) | (Im & 0xF) # Im番地へジャンプ
def JNC(Im)  : return (14 << 4) | (Im & 0xF) # Cフラグが1ではないときにIm番地へジャンプ

FILE_NAME = "rom_init.mif"
WIDTH =  8
DEPTH = 16
_ = [0] * DEPTH

_[0] = IN_B()
_[1] = OUT_B()
_[2] = JMP(0)

generate_mif(FILE_NAME, WIDTH, DEPTH, _)

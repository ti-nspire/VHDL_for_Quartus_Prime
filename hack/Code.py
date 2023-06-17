class Code:
    def __init__(self):
        pass
        
    # dest=comp;jumpのdestをバイナリコードに変える。
    def dest(self, mnemonic):
        adm = 0
        if "A" in mnemonic: adm |= 1 << 2
        if "D" in mnemonic: adm |= 1 << 1
        if "M" in mnemonic: adm |= 1

        return bin(adm)[2:].zfill(3)

    # dest=comp;jumpのcompをバイナリコードに変える。
    def comp(self, mnemonic):
        cccccc = ""
        if mnemonic == "0"                       : cccccc = "101010"
        if mnemonic == "1"                       : cccccc = "111111"
        if mnemonic == "-1"                      : cccccc = "111010"
        if mnemonic == "D"                       : cccccc = "001100"
        if mnemonic == "A"   or mnemonic == "M"  : cccccc = "110000"
        if mnemonic == "!D"                      : cccccc = "001101"
        if mnemonic == "!A"  or mnemonic == "!M" : cccccc = "110001"
        if mnemonic == "-D"                      : cccccc = "001111"
        if mnemonic == "-A"  or mnemonic == "-M" : cccccc = "110011"
        if mnemonic == "D+1"                     : cccccc = "011111"
        if mnemonic == "A+1" or mnemonic == "M+1": cccccc = "110111"
        if mnemonic == "D-1"                     : cccccc = "001110"
        if mnemonic == "A-1" or mnemonic == "M-1": cccccc = "110010"
        if mnemonic == "D+A" or mnemonic == "D+M": cccccc = "000010"
        if mnemonic == "D-A" or mnemonic == "D-M": cccccc = "010011"
        if mnemonic == "A-D" or mnemonic == "M-D": cccccc = "000111"
        if mnemonic == "D&A" or mnemonic == "D&M": cccccc = "000000"
        if mnemonic == "D|A" or mnemonic == "D|M": cccccc = "010101"

        acccccc = ""
        if "M" in mnemonic: acccccc = "1" + cccccc
        else              : acccccc = "0" + cccccc
        return acccccc

    # dest=comp;jumpのjumpをバイナリコードに変える。
    def jump(self, mnemonic):
        jjj = [
            "",
            "JGT",
            "JEQ",
            "JGE",
            "JLT",
            "JNE",
            "JLE",
            "JMP",
            ]
        jjj_index = jjj.index(mnemonic)
        return bin(jjj_index)[2:].zfill(3)
        
#########################################################################
if __name__ == "__main__":
    inst = Code()
    
    print(inst.dest(""))
    print(inst.dest("M"))
    print(inst.dest("D"))
    print(inst.dest("DM"))
    print(inst.dest("A"))
    print(inst.dest("AM"))
    print(inst.dest("AD"))
    print(inst.dest("ADM"))
    print("")

    print(inst.comp("0"))
    print(inst.comp("A"))
    print(inst.comp("!A"))
    print(inst.comp("!M"))
    print(inst.comp("D|A"))
    print(inst.comp("D|M"))
    print("")

    print(inst.jump(""))
    print(inst.jump("JGT"))
    print(inst.jump("JEQ"))
    print(inst.jump("JGE"))
    print(inst.jump("JLT"))
    print(inst.jump("JNE"))
    print(inst.jump("JLE"))
    print(inst.jump("JMP"))
    print("")
    

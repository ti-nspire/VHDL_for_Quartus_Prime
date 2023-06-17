from Parser import *
from Code import *

class Hack_Assember_Basic:
    def __init__(self, input_file_path):
        # 出力ファイル名は入力ファイル名の拡張子を.hackに変える。
        self.output_file_path = input_file_path.split(".")[0] + ".hack"
        
        self.parser = Parser(input_file_path)
        self.code = Code()
        
        # 出力ファイルを開く。
        self.output_file = open(self.output_file_path, "w")

        self.__create_hack_file()

    def __create_hack_file(self):
        while (self.parser.has_more_lines()):
            self.parser.advance()

            # C命令の場合:
            if self.parser.inst_type() == "C":
                comp_part = self.code.comp(self.parser.comp())
                dest_part = self.code.dest(self.parser.dest())
                jump_part = self.code.jump(self.parser.jump())
                
                processed_string = "111" + comp_part + dest_part + jump_part

            # A命令の場合:
            elif self.parser.inst_type() == "A":
                address_part = self.parser.current_inst.split("@")[1]
                processed_string = "0" + bin(int(address_part))[2:].zfill(15)

            print(processed_string)
            self.output_file.write(processed_string + "\n")

        self.parser.file.close()
        self.output_file.close()


####################################################################
if __name__ == "__main__":
    Hack_Assember_Basic("test.asm")

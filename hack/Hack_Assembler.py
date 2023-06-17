from Parser import *
from Code import *
from Symbol_Table import *

class Hack_Assembler:
    def __init__(self,
                 asm_file_path,
                 screen_address=8192,
                 keyboard_address=8576,
                 out_port_address=8577):
        
        # 出力ファイル名は入力ファイル名の拡張子を.hackに変えたものにする。
        self.output_file_path = self.__replace_file_extension(asm_file_path, "hack")
        self.output_file = open(self.output_file_path, "w")
        
        self.parser = Parser(asm_file_path)
        self.code = Code()
        self.symbol_table = Symbol_Table(
            screen_address=screen_address,
            keyboard_address=keyboard_address,
            out_port_address=out_port_address)

        self.hack_file = [] # .hackファイルを出力するだけでなくリストとしても持っておく。
        
        self.__first_pass()
        self.__second_pass()

    def __first_pass(self):
        self.parser.file.seek(0) # ファイルの先頭に移動して、
        line_number = -1 # 行番号の初期値を設定して、
        
        while (self.parser.has_more_lines()):
            self.parser.advance() # 次の行に移動して、

            if (self.parser.inst_type() == "C") or (self.parser.inst_type() == "A"):
                line_number += 1 # A命令なら何もせずに行番号を先へ進めるだけにして、

            elif self.parser.inst_type() == "L":
                self.symbol_table.add_entry(self.parser.symbol(), line_number + 1) # L命令ならラベルをシンボルテーブルに追加する。

    def __second_pass(self):
        self.parser.file.seek(0) # ファイルの先頭に移動して、
        
        while (self.parser.has_more_lines()):
            self.parser.advance() # 次の行に移動して、

            if self.parser.inst_type() == "C":
                self.__second_pass_for_C_inst() # C命令ならそれに応じた処理をして、

            elif self.parser.inst_type() == "A":
                self.__second_pass_for_A_inst() # A命令ならそれに応じた処理をして、

        self.parser.close()
        self.close()

    def __second_pass_for_C_inst(self):
        # dest=comp;jumpの各部をバイナリコードに変えて、
        comp_part = self.code.comp(self.parser.comp())
        dest_part = self.code.dest(self.parser.dest())
        jump_part = self.code.jump(self.parser.jump())

        # 16ビットのC命令に変えてファイルに書き込む。
        processed_string = "111" + comp_part + dest_part + jump_part
        self.output_file.write(processed_string + "\n") 
        
        self.hack_file.append(processed_string)

    def __second_pass_for_A_inst(self):
        address_part = self.parser.symbol()
        try:
            int(address_part)
        except:
            # シンボルがシンボルテーブルに登録済みであったら
            if self.symbol_table.contains(address_part):
                # それを取り出すが、
                address_part = self.symbol_table.get_address(address_part)
            # シンボルテーブルに登録していなかったら、
            else:
                # そのシンボルと、空いているRAMのうち一番若いRAMの番地とをペアにして
                # シンボルテーブルに登録して、
                self.symbol_table.increment_ram_last_address()
                self.symbol_table.add_entry(address_part, self.symbol_table.get_ram_last_address())
                #address_part = self.symbol_table.ram_last_address
                address_part = self.symbol_table.get_ram_last_address()
                        
        # 16ビットのA命令に変えてファイルに書き込む。
        processed_string = "0" + bin(int(address_part))[2:].zfill(15)
        self.output_file.write(processed_string + "\n")
        
        self.hack_file.append(processed_string)


    def get_hack_file(self):
        return self.hack_file

    def close(self):
        self.output_file.close()
        return self

    def __replace_file_extension(self, file_name, new_extension):
        return file_name.split(".")[0] + "." + new_extension
    
             

####################################################################
if __name__ == "__main__":
    Hack_Assembler("test.asm")

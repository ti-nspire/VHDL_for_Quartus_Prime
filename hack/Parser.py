class Parser:
    def __init__(self, file_path):
        self.file = open(file_path, "r")
        self.EOF_POS = self.__get_EOF_position(self.file)
        self.current_inst = ""

    def has_more_lines(self):
        return self.file.tell() != self.EOF_POS

    def advance(self):
        self.current_inst = self.__readline_then_strip()
        return self

    def inst_type(self):
        if not self.current_inst:
            return ""
        elif "@" in self.current_inst:
            return "A"
        elif "(" in self.current_inst and ")" in self.current_inst:
            return "L"
        else:
            return "C"

    def symbol(self):
        if self.inst_type() == "A":
            return self.__get_right_hand(self.current_inst, "@")
        elif self.inst_type() == "L":
            return self.current_inst[1:-1] # (LABEL)のLABELだけを抜いて返す。
        else:
            return ""

    def dest(self):
        # dest=comp;jump
        if self.inst_type() == "C" and self.__has_destination():
            return self.__get_left_hand(self.current_inst, "=") # destだけを抜いて返す。
        else:
            return ""

    def comp(self):
        # dest=comp;jump
        if self.inst_type() == "C":
            comp_part = self.__get_right_hand(self.current_inst, "=") # dest=を切り落として、
            comp_part = self.__get_left_hand(comp_part, ";") # さらに;jumpを切り落としてcompだけを抜いて返す。
            return comp_part
        else:
            return ""

    def jump(self):
        # dest=comp;jump
        if self.inst_type() == "C" and self.__has_jump_to():
            return self.__get_right_hand(self.current_inst, ";") # jumpだけを抜いて返す。
        else:
            return ""

    def close(self):
        self.file.close()
        return self


    def __readline_then_strip(self):
        line = self.file.readline()
        line = line.strip() # 先頭の空白と末尾の改行記号とを削除する。
        line = self.__get_left_hand(line, "//") # コメントを削除する
        line = line.replace(" ", "") # 文字列中の半角スペースを削除する。
        line = line.replace("　", "") # 文字列中の全角スペースを削除する。
        line = line.replace("\t", "") # 文字列中のタブ文字を削除する。
        return line if line else ""
    def __has_jump_to(self):
        return (";" in self.current_inst)
    def __has_destination(self):
        return ("=" in self.current_inst)
    def __get_left_hand(self, strings, delimiter):
        return strings.split(delimiter)[0]
    def __get_right_hand(self, strings, delimiter):
        return strings.split(delimiter)[-1]
    def __get_EOF_position(self, file):
        file.seek(0, 2) # ファイル末尾に移動して、
        pos = file.tell() # その位置を取得して、
        self.file.seek(0) # 再度ファイル先頭に戻って、
        return pos # 取得したファイル末尾位置を返す。


if __name__ == "__main__":
    s = Parser("test.asm")
    while (s.has_more_lines()):
        s.advance()
        print("--------------------------")
        print("命令        :", s.current_inst)
        print("命令タイプ  :", s.inst_type())
        print("シンボル    :", s.symbol())
        print("格納先      :", s.dest())
        print("ALU出力     :", s.comp())
        print("ジャンプ命令:", s.jump())
    s.close()

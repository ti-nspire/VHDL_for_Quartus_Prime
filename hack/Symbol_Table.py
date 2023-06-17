class Symbol_Table:
    def __init__(self, screen_address=8192, keyboard_address=8576, out_port_address=8577):
        self.symbol_dict = {
            "SP":0,
            "LCL":1,
            "ARG":2,
            "THIS":3,
            "THAT":4,
            "SCREEN":screen_address,
            "KBD":keyboard_address,
            "OUT_PORT":out_port_address}
        
        self.ram_last_address = 15

        # 疑似汎用レジスタとして使うR0～R15とアドレスとのペアをシンボルテーブルに追加する。
        for i in range(self.ram_last_address+1):
            self.symbol_dict["R" + str(i)] = i

    def add_entry(self, symbol, address):
        if not self.contains(symbol):
            self.symbol_dict[symbol] = address
        else:
            print("symbol already exists")
        return self

    def contains(self, symbol):
        return symbol in self.symbol_dict
    
    def get_address(self, symbol):
        return self.symbol_dict[symbol]





    def get_symbol_dict(self):
        return self.symbol_dict
    def get_ram_last_address(self):
        return self.ram_last_address
    def increment_ram_last_address(self):
        self.ram_last_address += 1
        return self


##################################################
if __name__ == "__main__":
    s = Symbol_Table(screen_address=8192, keyboard_address=8576, out_port_address=8577)
    print("初期化直後:", s.get_symbol_dict())

    s.add_entry("LOOP",10)

    s.increment_ram_last_address()
    s.add_entry("sum", s.get_ram_last_address())

    s.increment_ram_last_address()
    s.add_entry("i", s.get_ram_last_address())

    s.add_entry("LOOP2",20)
    print("エントリ追加後: ", s.get_symbol_dict())

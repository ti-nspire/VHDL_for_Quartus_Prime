参考: Interface (インターフェース), 2009年09月号, pp.116-118, CQ出版

受信した1バイトをそのまま送り返すサンプル。
UART.vhdをトップレベルエンティティとしてコンパイルする。

注意:
正論理の場合はUART.vhdをPOL_INV: std_logic := '0' にしてコンパイルする。
負論理の場合はUART.vhdをPOL_INV: std_logic := '1' にしてコンパイルする。

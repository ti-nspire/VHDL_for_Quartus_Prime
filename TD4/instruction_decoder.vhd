library ieee;
use ieee.std_logic_1164.all;

entity instruction_decoder is
	port(
		c_flag_n: in std_logic;
		op_code : in std_logic_vector(3 downto 0);

		-- "00"のときA_REGを選択、"01"のときB_REGを選択、"10"のときINポートを選択 
		sel: out std_logic_vector(1 downto 0);

		-- "1110"のときA_REGにロード、"1101"のときB_REGにロード、
		-- "1011"のときOUT_REGにロード、"0111"のときPCにロード  
		load_n: out std_logic_vector(3 downto 0)
	);
end entity;

architecture rtl of instruction_decoder is 
	signal load_n_sel: std_logic_vector(5 downto 0);
begin

	-- ページ242の真理値表を書き写す。
	-- 最適化された最終的な回路に合わせてc_flagは反転してc_flag_nにした。
	load_n_sel <= "1110" & "00" when op_code = "0000" else -- ADD A, Im
	              "1110" & "01" when op_code = "0001" else -- MOV A, B
	              "1110" & "10" when op_code = "0010" else -- IN A
	              "1110" & "11" when op_code = "0011" else -- MOV A, Im
	              "1101" & "00" when op_code = "0100" else -- MOV B, A
	              "1101" & "01" when op_code = "0101" else -- ADD B, Im
	              "1101" & "10" when op_code = "0110" else -- IN B
	              "1101" & "11" when op_code = "0111" else -- MOV B, Im
	              "1011" & "01" when op_code = "1001" else -- OUT B
	              "1011" & "11" when op_code = "1011" else -- OUT Im
	              "0111" & "11" when op_code = "1110" and c_flag_n = '1' else -- JNC (C=0)
	              "1111" & "--" when op_code = "1110" and c_flag_n = '0' else -- JNC (C=1)
	              "0111" & "11" when op_code = "1111"; -- JMP

	-- A、B、OUTの各レジスタおよびPCへ与える!ロード信号を抜いて返す。
	load_n <= load_n_sel(5 downto 2);
	
	-- マルチプレクサへ与えるセレクト信号を抜いて返す。
	sel <= load_n_sel(1 downto 0);

/*
	-- 最適化された回路(ページ272)をVHDLで表現した例
	sel(1) <= op_code(1);
	sel(0) <= op_code(0) or op_code(3);

	load_n(0) <= op_code(2) or op_code(3);
	load_n(1) <= (not op_code(2)) or op_code(3);
	load_n(2) <= (not op_code(2)) nand op_code(3);
	load_n(3) <= not((c_flag_n or op_code(0)) and op_code(2) and op_code(3));
*/

end architecture;
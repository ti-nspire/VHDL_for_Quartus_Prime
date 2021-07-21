library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.subprograms_pkg.all;

entity example_slv_to_bcd is
	generic(
		INT: positive := 98765432 -- この整数をBCDに変換してみる。
	);
	port(
		bcd_out: out std_logic_vector(positive(floor(log10(real(INT))+1.0))*4-1 downto 0)
	);
end entity;

architecture rtl of example_slv_to_bcd is
	-- 元の数の2進数表現でのビット数
	constant LEN_SLV: positive := positive(floor(log2(real(INT))+1.0));
	-- 元の数の2進数表現
	constant SLV: std_logic_vector(LEN_SLV-1 downto 0) := std_logic_vector(to_unsigned(INT, LEN_SLV));
begin
	bcd_out <= slv_to_bcd(SLV);
end architecture;
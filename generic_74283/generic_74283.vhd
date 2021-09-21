library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_74283 is
	generic(
		NUM_BITS: natural := 4
	);
	port(
		cin: in std_logic;
		a  : in std_logic_vector(NUM_BITS-1 downto 0);
		b  : in std_logic_vector(NUM_BITS-1 downto 0);

		sum : out std_logic_vector(NUM_BITS-1 downto 0);
		cout: out std_logic
	);
end entity;

architecture rtl of generic_74283 is
	-- 和の假置き信号。キャリーアウトを得たいので1ビット拡張して5ビット幅。
	signal temp_sum: unsigned(NUM_BITS downto 0);
begin
	-- キャリーアウトを得たいので1ビット拡張して5ビット幅にしてから足し合わせる。
	-- どのオペランドも長さは最長オペランドに合わせて拡張される。
	-- Quartus Prime Liteではシングルビットが加算できなかったので('0' & cin)のようにベクタにした。
	temp_sum <= ('0' & unsigned(a)) + unsigned(b) + ('0' & cin);

	-- 和だけを抜いて返す。
	sum <= std_logic_vector(temp_sum(NUM_BITS-1 downto 0));

	-- キャリーアウトだけを抜いて返す。
	cout <= temp_sum(NUM_BITS);
end architecture;

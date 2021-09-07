-- 複数のstd_logic_vectorから成る排列型を定義する。
-- ここでしか使わない型なので別ファイルに分けなかった。
library ieee;
use ieee.std_logic_1164.all;
package typedef_pkg is
	type array_slv is array(natural range <>) of std_logic_vector;
end package;
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.typedef_pkg.all;

entity generic_multiplexer is
	generic(
		NUM_BITS    : natural := 4;
		NUM_WORDS   : natural := 3;
		NUM_SEL_BITS: natural := 2  -- ceil(log2(NUM_WORDS))
	);
	port(
		sel   : in std_logic_vector(NUM_SEL_BITS-1 downto 0 );
		inp   : in array_slv(0 to NUM_WORDS-1)(NUM_BITS-1 downto 0);
		strobe: in std_logic; -- Hiのときに強制的に出力を全部Loにする。
		
		outp: out std_logic_vector(NUM_BITS-1 downto 0)
	);
end entity;

architecture rtl of generic_multiplexer is
begin

	process(all)
		variable which_word: natural;
	begin

		-- ストローブ機能
		if strobe = '1' then
			outp <= (others => '0');

		-- マルチプレクサ機能。
		-- セレクト信号に応じて、どの入力を出力するのかを選択する。
		else
			which_word := to_integer(unsigned(sel));
			case which_word is
				when 0 to NUM_WORDS-1 => outp <= inp(which_word); -- which_wordは要するに排列のインデックス
				when others           => outp <= (others => '0');
			end case;
		end if;
	end process;

end architecture;
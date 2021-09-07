library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity auto_clk is
	generic(
		F_CLK  : natural := 48_000_000;
		FREQ_LO: natural := 1;
		FREQ_HI: natural := 10
	);
	port(
		clk    : in  std_logic;
		sel    : in  std_logic; -- 0のときFREQ_LOを出力、1のときFREQ_HIを出力
		clk_out: out std_logic
	);
end entity;

architecture rtl of auto_clk is
begin

	process(all)
		variable count_max: natural range 0 to F_CLK/2-1;
		variable counter  : natural range 0 to F_CLK/2-1 := 0;
	begin

		case sel is -- セレクト信号に応じてカウンターのトップ値を入れ換える。
			when '0'    => count_max := F_CLK/(FREQ_LO*2)-1;
			when '1'    => count_max := F_CLK/(FREQ_HI*2)-1;
			when others => count_max := F_CLK/2-1; -- 1 Hz
		end case;

		-- カウンター
		if rising_edge(clk) then
			if counter >= count_max then -- オーバーフローするたびに
				clk_out <= not clk_out;   -- 出力をトグルする。
				counter := 0;
			else
				counter := counter + 1;
			end if;
		end if;
	end process;

end architecture;

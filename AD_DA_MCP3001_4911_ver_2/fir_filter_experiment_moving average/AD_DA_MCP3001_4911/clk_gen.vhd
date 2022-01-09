library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_gen is
	generic(
		F_CLK   : positive := 48_000_000;
		OUT_FREQ: natural  := 9600
	);
	port(
		aclr_n  : in  std_logic;
		clk     : in  std_logic;
		pwm_clk : out std_logic
	);
end entity;

architecture rtl of clk_gen is
begin

	process(aclr_n, clk)
		constant TOP_VAL: natural                    := F_CLK/(OUT_FREQ * 2) - 1;
		variable count  : natural range 0 to TOP_VAL := 0;
	begin
		if aclr_n = '0' then
			count := 0;
		elsif rising_edge(clk) then
			if count >= TOP_VAL then
				pwm_clk <= not pwm_clk;
				count := 0;
			else
				count := count + 1;
			end if;
		end if;
	end process;

end architecture;
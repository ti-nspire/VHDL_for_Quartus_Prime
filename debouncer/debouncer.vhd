library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
	generic(
		F_CLK      : natural := 48_000_000;
		BOUNCE_msec: natural := 15; -- the estimated bounce period in msec.
		IS_INVERTED: boolean := false
	);
	port(
		clk         : in  std_logic;
		bounce_in   : in  std_logic;
		debounce_out: out std_logic
	);
end entity;

architecture rtl of debouncer is
	constant COUNT_MAX: natural := F_CLK * BOUNCE_msec/1000 - 1; -- an exact value not needed.
	signal in_reg: std_logic;
begin

	process(clk)
		variable count: natural := 0;
	begin
		if rising_edge(clk) then
			-- the register, in_reg, is to synchronize an input signal.
			-- not necessarily needed.
			case IS_INVERTED is
				when false  => in_reg <=     bounce_in;
				when true   => in_reg <= not bounce_in;
				when others => in_reg <=     bounce_in;
			end case;

			if debounce_out = in_reg then
				count := 0;
			else
				count := count + 1;
			end if;
		elsif falling_edge(clk) then
			if count >= COUNT_MAX then
				debounce_out <= not debounce_out;
			end if;
		end if;
	end process;

end architecture;

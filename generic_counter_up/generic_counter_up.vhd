library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_counter_up is
	generic(
		TOP_uns    : unsigned := d"20";
		BOTTOM_uns : unsigned := d"5"
	);
	port(
		clk    : in  std_logic;
		aclr_n : in  std_logic;
		count  : out std_logic_vector(TOP_uns'reverse_range)
	);
end entity;

architecture rtl of generic_counter_up is
begin

	process(aclr_n, clk)
		constant BOTTOM     : unsigned(count'reverse_range) := resize(BOTTOM_uns, count'length);
		variable count_temp : unsigned(count'reverse_range) := BOTTOM;
	begin
		if aclr_n = '0' then
			count_temp := BOTTOM;
		elsif rising_edge(clk) then
			if count_temp  >= TOP_uns then
				count_temp := BOTTOM;
			else
				count_temp := count_temp + 1;
			end if;
		end if;
		count <= std_logic_vector(count_temp);
	end process;

end architecture;

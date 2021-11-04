library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_counter_up is
	generic(
		TOP_uns    : unsigned := d"20";
		BOTTOM_nat : natural  := 5
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
		constant TOP_nat    : natural := to_integer(TOP_uns);
		variable count_temp : natural range BOTTOM_nat to TOP_nat := BOTTOM_nat;
	begin
		if aclr_n = '0' then
			count_temp := BOTTOM_nat;
		elsif rising_edge(clk) then
			if count_temp >= TOP_nat then
				count_temp := BOTTOM_nat;
			else
				count_temp := count_temp + 1;
			end if;
		end if;
		count <= std_logic_vector(to_unsigned(count_temp, count'length));
	end process;

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_updown is
	generic(
		TOP_uns    : unsigned := d"100";
		BOTTOM_nat : natural  := 0
	);
	port(
		aclr_n      : in  std_logic;
		pwm_clk         : in  std_logic;
		is_climbing : out std_logic;
		count       : out std_logic_vector(TOP_uns'reverse_range)
	);
end entity;

architecture rtl of counter_updown is
begin

	process(pwm_clk, aclr_n)
		constant TOP_nat          : natural := to_integer(TOP_uns);
		variable count_temp       : natural range BOTTOM_nat to TOP_nat := BOTTOM_nat;
		variable diff             : integer range -1 to 1 := 1;
		variable is_climbing_temp : std_logic := '1';
	begin
		if aclr_n = '0' then
			count_temp := BOTTOM_nat;
			is_climbing_temp := '1';
		elsif rising_edge(pwm_clk) then
			if    count_temp <= BOTTOM_nat then diff :=  1;
			elsif count_temp >= TOP_nat    then diff := -1;
			end if;
			count_temp := count_temp + diff;
		elsif falling_edge(pwm_clk) then
			if    count_temp <= BOTTOM_nat then is_climbing_temp := '1';
			elsif count_temp >= TOP_nat    then is_climbing_temp := '0';
			end if;
		end if;
		count       <= std_logic_vector(to_unsigned(count_temp, count'length));
		is_climbing <= is_climbing_temp;
	end process;

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_counter_updown is
	generic(
		TOP_VAL   : natural := 10;
		BOTTOM_VAL: natural := 5;
		NUM_BITS  : natural := 4 -- ceil(log2(TOP_VAL + 1))
	);
	port(
		aclr_n: in  std_logic;
		clk   : in  std_logic;
		q     : out std_logic_vector(NUM_BITS-1 downto 0)
	);
end entity;

architecture rtl of generic_counter_updown is
begin
	process(clk, aclr_n)
		variable count: natural range BOTTOM_VAL to TOP_VAL := BOTTOM_VAL;
		variable diff : integer range -1 to 1 := 1;
	begin
		if aclr_n = '0' then
			count := BOTTOM_VAL;

		elsif rising_edge(clk) then
			if    count <= BOTTOM_VAL then diff :=  1;
			elsif count >= TOP_VAL    then diff := -1;
			end if;
			count := count + diff;

		end if;

		q <= std_logic_vector(to_unsigned(count, NUM_BITS));
	end process;
end architecture;
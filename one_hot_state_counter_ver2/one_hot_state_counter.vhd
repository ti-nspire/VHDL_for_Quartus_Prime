library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity one_hot_state_counter is
	generic(
		NUM_PHASES: natural := 16
	);
	port(
		aclr_n: in std_logic;
		sclr_n: in std_logic;
		clk   : in std_logic;

		n_phase_clk: out std_logic_vector(NUM_PHASES-1 downto 0)
	);
end entity;

architecture rtl of one_hot_state_counter is
begin

	process(all)
		constant uns_1  : unsigned(NUM_PHASES-1 downto 0) := to_unsigned(1, NUM_PHASES);
		variable one_hot: unsigned(NUM_PHASES-1 downto 0) := uns_1;
	begin
		if aclr_n = '0' then -- asynchronous reset
			one_hot := uns_1;
		elsif rising_edge(clk) then
			if sclr_n = '0' then -- synchronous reset
				one_hot := uns_1;
			else -- when not reseting, synchronous rotate left.
				one_hot := one_hot rol 1;
			end if;
		end if;
		n_phase_clk <= std_logic_vector(one_hot);
	end process;

end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity one_hot_state_counter is
	generic(NUM_PHASES: natural := 16);
	port(
		clk        : in     std_logic;
		n_phase_clk: buffer std_logic_vector(NUM_PHASES-1 downto 0)
	);
end entity;

architecture rtl of one_hot_state_counter is

	function nand_reduction(slv: std_logic_vector) return std_logic	is
	begin
		if unsigned(slv)=0 then return '1';
		else                    return '0';
		end if;
	end function;

begin

	process(clk)
	begin
		if rising_edge(clk) then
			n_phase_clk <= n_phase_clk(NUM_PHASES-2 downto 0) &
			               nand_reduction(n_phase_clk(NUM_PHASES-2 downto 0));
		end if;
	end process;

end architecture;

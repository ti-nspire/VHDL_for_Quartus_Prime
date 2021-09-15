library ieee;
use ieee.std_logic_1164.all;

entity state_machine is
	port(
		halt_n    : in std_logic;
		pc_ld     : in std_logic;
		clk_inside: in std_logic;
		aclr_n    : in std_logic;

		clk_en: out std_logic;
		halt  : out std_logic;
		pc_up : out std_logic;
		ld_en : out std_logic
	);
end entity;

architecture rtl of state_machine is
begin
	process(all)
		variable halt_temp : std_logic;
		variable pc_up_temp: std_logic;
	begin

		halt_temp := (halt_n nor pc_up); 
		pc_up_temp:= (pc_ld  nor pc_up);

		if aclr_n = '0' then
			halt   <= '0';
			clk_en <= '1';
			pc_up  <= '0';
			ld_en  <= '1';

		elsif rising_edge(clk_inside) then
			halt   <=     halt_temp;
			clk_en <= not halt_temp;
			pc_up  <=     pc_up_temp;
			ld_en  <= not pc_up_temp;
		end if;

	end process;
end architecture;
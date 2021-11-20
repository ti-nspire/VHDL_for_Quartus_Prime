library ieee;
use ieee.std_logic_1164.all;

entity gen_one_shot is
	port(
		clk   : in  std_logic;
		p_in  : in  std_logic;
		p_out : out std_logic
	);
end entity;

architecture rtl of gen_one_shot is
	signal temp_0 : std_logic;
	signal temp_1 : std_logic;
	signal temp_2 : std_logic;
begin
	p_out <= temp_1 and (not temp_2);

	process(clk)
	begin
		if rising_edge(clk) then
			temp_0 <= p_in;
			temp_1 <= temp_0;
			temp_2 <= temp_1;
		end if;
	end process;
end architecture;

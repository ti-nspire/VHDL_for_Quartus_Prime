library ieee;
use ieee.std_logic_1164.all;

entity edge_detector_sub is
	port(
		clk   : in  std_logic;
		p_in  : in  std_logic;
		p_out : out std_logic
	);
end entity;

architecture rtl of edge_detector_sub is
	signal q0 : std_logic;
	signal q1 : std_logic;
begin
	
	---------------
	--Edge detector
	---------------
	process(p_in, p_out)
	begin
		if p_out then
			q0 <= '0';
		elsif rising_edge(p_in) then
			q0 <= '1';
		end if;
	end process;

	---------------
	-- Synchronizer
	---------------
	process(clk)
	begin
		if rising_edge(clk) then
			q1    <= q0;
			p_out <= q1;
		end if;
	end process;

end architecture;
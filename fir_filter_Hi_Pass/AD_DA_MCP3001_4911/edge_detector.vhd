library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
	port(
		clk  : in std_logic;
		p_in : in std_logic;
		
		p_out_both_edge : out std_logic
	);
end entity;

architecture rtl of edge_detector is
	signal p_out_pos : std_logic;
	signal p_out_neg : std_logic;
begin

	p_out_both_edge <= p_out_pos or p_out_neg;
	
	----------------------------------
	u1 : entity work.edge_detector_sub
	port map(
		clk   => clk,
		p_in  => p_in, 
		p_out => p_out_pos
	);
	----------------------------------
	u2 : entity work.edge_detector_sub
	port map(
		clk   => clk,
		p_in  => not p_in, 
		p_out => p_out_neg
	);
	----------------------------------

end architecture;
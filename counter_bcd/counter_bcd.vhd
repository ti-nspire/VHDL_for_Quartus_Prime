library ieee;
use ieee.std_logic_1164.all;

entity counter_bcd is
	generic(
		NUM_BCD: natural := 4 -- BCDカウンターの連結数
	);
	port(
		clr_n: in  std_logic;
		clk  : in  std_logic;
		bcd  : out std_logic_vector(NUM_BCD*4-1 downto 0)
	);
end entity;

architecture rtl of counter_bcd is
	component counter_10 is
		port(
			aclr	: IN STD_LOGIC ;
			cin	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			cout	: OUT STD_LOGIC ;
			q	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
		);
	end component;
	
	signal carry_temp: std_logic_vector(NUM_BCD downto 0);
	
begin
	carry_temp(0) <= '1';

	gen: for i in 0 to NUM_BCD-1 generate
		c: counter_10 port map(
			aclr  => not clr_n,
			cin   => carry_temp(i),
			clock => clk,
			cout  => carry_temp(i+1), 
			q     => bcd(i*4+3 downto i*4)
		);
	end generate;

end architecture;

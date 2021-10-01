library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.my_conv_pkg.all;

entity my_conv_pkg_test is
	port(
		slv_in: std_logic_vector(13 downto 0);
		
		bcd_out: out std_logic_vector(15 downto 0);
		outp   : out std_logic_vector(15 downto 0)
	);
end entity;

architecture rtl of my_conv_pkg_test is
	signal bcd_out_temp: std_logic_vector(15 downto 0) := (others => '0');
	signal int_out_temp: natural := 0;
begin
	bcd_out_temp <= slv_to_bcd(slv_in, 4);
	bcd_out      <= bcd_out_temp;
	
	int_out_temp <= bcd_to_int(bcd_out_temp);
	outp         <= std_logic_vector(to_unsigned(int_out_temp, 16));
end architecture;
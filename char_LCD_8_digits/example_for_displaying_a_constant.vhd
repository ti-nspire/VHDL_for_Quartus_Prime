library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

entity example_for_displaying_a_constant is
	port(
		clk   : in std_logic;
		rst_n : in std_logic;
		--bin_in: in std_logic_vector(31 downto 0);
		
		E : out std_logic;
		RS: out std_logic;
		DB: out std_logic_vector(7 downto 4)
	);
end entity;

architecture rtl of example_for_displaying_a_constant is
begin

	c1: entity work.char_LCD_8_digits
		generic map(
			F_CLK => 1_000_000
		)
		port map(
			clk    => clk,
			rst_n  => rst_n,
			--bin_in => bin_in,
			bin_in => x"abef_0189",
			E      => E,
			RS     => RS,
			DB     => DB
		);

end architecture;

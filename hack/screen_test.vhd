library ieee;
use ieee.std_logic_1164.all;

entity screen_test is
    port (
        reset: in std_logic;
        clk:  in std_logic;
        screen_sel: in std_logic_vector(8 downto 0);
        screen_out: out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of screen_test is
begin
    u: entity work.screen384
    port map (
        aclr => reset,
		clock => clk,
		data => "1111000011110000",
		rdaddress => screen_sel,
		wraddress => "000001111",
		wren => '1',
		q=> screen_out	
    
    );
        
        
        
end architecture;
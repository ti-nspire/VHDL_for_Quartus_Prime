LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;            
use ieee.numeric_std_unsigned.all;
use ieee.numeric_std.all;                      

ENTITY n_bits_adder_lookahead_vhd_tst IS
END n_bits_adder_lookahead_vhd_tst;
ARCHITECTURE n_bits_adder_lookahead_arch OF n_bits_adder_lookahead_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL c0 : STD_LOGIC;
SIGNAL cout : STD_LOGIC;
SIGNAL s : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL x : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL y : STD_LOGIC_VECTOR(3 DOWNTO 0);
COMPONENT n_bits_adder_lookahead
	PORT (
	c0 : IN STD_LOGIC;
	cout : OUT STD_LOGIC;
	s : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
	x : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	y : IN STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : n_bits_adder_lookahead
	PORT MAP (
-- list connections between master ports and signals
	c0 => c0,
	cout => cout,
	s => s,
	x => x,
	y => y
	);

process begin
    for k in 0 to 1 loop
    for i in 0 to 15 loop
    for j in 0 to 15 loop
        c0 <= to_std_logic_vector(k, 1)(0);
        x <= to_std_logic_vector(i, 4);
        y <= to_std_logic_vector(j, 4);
        wait for 10 ns;
    end loop;
    end loop;
    end loop;
    wait;
end process;    
    
END n_bits_adder_lookahead_arch;

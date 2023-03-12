LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;            
use ieee.numeric_std_unsigned.all;
use ieee.numeric_std.all;                                 

ENTITY multiplier_unsigned_vhd_tst IS
END multiplier_unsigned_vhd_tst;
ARCHITECTURE multiplier_unsigned_arch OF multiplier_unsigned_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL m : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL q : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL p : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL p_lib_used : STD_LOGIC_VECTOR(15 DOWNTO 0);

COMPONENT multiplier_unsigned
	PORT (
	m : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	q : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	p : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	p_lib_used : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)

	);
END COMPONENT;
BEGIN
	i1 : multiplier_unsigned
	PORT MAP (
-- list connections between master ports and signals
	m => m,
	q => q,
    p => p,
	p_lib_used => p_lib_used
	);

    
process begin
    for i in 0 to 63 loop
    for j in 0 to 63 loop
        m <= to_std_logic_vector(i, 8);
        q <= to_std_logic_vector(j, 8);
        wait for 10 ns;
    end loop;
    end loop;
    wait;
end process;      

END multiplier_unsigned_arch;

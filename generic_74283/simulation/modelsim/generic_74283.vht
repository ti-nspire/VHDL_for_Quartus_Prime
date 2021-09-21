LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                
USE ieee.numeric_std.all;     

ENTITY generic_74283_vhd_tst IS
END generic_74283_vhd_tst;

ARCHITECTURE generic_74283_arch OF generic_74283_vhd_tst IS

	SIGNAL a   : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL b   : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL cin : STD_LOGIC;
	SIGNAL cout: STD_LOGIC;
	SIGNAL sum : STD_LOGIC_VECTOR(3 DOWNTO 0);

	COMPONENT generic_74283
	PORT (
		a   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		b   : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		cin : IN  STD_LOGIC;
		cout: OUT STD_LOGIC;
		sum : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
	END COMPONENT;

BEGIN

	i1 : generic_74283
	PORT MAP (
		a    => a,
		b    => b,
		cin  => cin,
		cout => cout,
		sum  => sum
	);

	cin <= '0';

	process begin
		for i in 0 to 15 loop
			a <= std_logic_vector(to_unsigned(i, 4)); wait for 10 ns;
		end loop;
	end process;

	process begin
		for i in 0 to 15 loop
			b <= std_logic_vector(to_unsigned(i, 4)); wait for 160 ns;
		end loop;
	end process;

END generic_74283_arch;

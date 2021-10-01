LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                
use ieee.numeric_std.all;

ENTITY pwm_gen_vhd_tst IS
END pwm_gen_vhd_tst;
ARCHITECTURE pwm_gen_arch OF pwm_gen_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL aclr_n : STD_LOGIC;
SIGNAL clk : STD_LOGIC;
SIGNAL duty : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL pol_inv : STD_LOGIC;
SIGNAL pwm_out : STD_LOGIC;
COMPONENT pwm_gen
	PORT (
	aclr_n : IN STD_LOGIC;
	clk : IN STD_LOGIC;
	duty : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
	pol_inv : IN STD_LOGIC;
	pwm_out : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : pwm_gen
	PORT MAP (
-- list connections between master ports and signals
	aclr_n => aclr_n,
	clk => clk,
	duty => duty,
	pol_inv => pol_inv,
	pwm_out => pwm_out
	);

process
begin
	aclr_n  <= '1';
	pol_inv <= '0';
	
	duty <= std_logic_vector(to_unsigned(20, duty'length));

	wait;
end process;

process	
begin
	clk <= '1'; wait for 10417 ps; -- (1/F_CLK)/2
	clk <= '0'; wait for 10417 ps; -- (1/F_CLK)/2
end process;	
	
END pwm_gen_arch;


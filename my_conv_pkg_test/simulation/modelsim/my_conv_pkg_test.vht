-- Copyright (C) 2020  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "10/02/2021 07:52:04"
                                                            
-- Vhdl Test Bench template for design  :  my_conv_pkg_test
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY my_conv_pkg_test_vhd_tst IS
END my_conv_pkg_test_vhd_tst;
ARCHITECTURE my_conv_pkg_test_arch OF my_conv_pkg_test_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL bcd_out : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL outp : STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL slv_in : STD_LOGIC_VECTOR(13 DOWNTO 0);
COMPONENT my_conv_pkg_test
	PORT (
	bcd_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	outp : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
	slv_in : IN STD_LOGIC_VECTOR(13 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : my_conv_pkg_test
	PORT MAP (
-- list connections between master ports and signals
	bcd_out => bcd_out,
	outp => outp,
	slv_in => slv_in
	);

	
process
begin
	slv_in <= d"9876"; --b"10_0110_1001_0100"                           
	wait;
end process;    

                                              
END my_conv_pkg_test_arch;

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
-- Generated on "10/02/2021 10:41:14"
                                                            
-- Vhdl Test Bench template for design  :  clk_gen
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY clk_gen_vhd_tst IS
END clk_gen_vhd_tst;
ARCHITECTURE clk_gen_arch OF clk_gen_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL aclr_n : STD_LOGIC;
SIGNAL clk : STD_LOGIC;
SIGNAL clk_out : STD_LOGIC;
COMPONENT clk_gen
	PORT (
	aclr_n : IN STD_LOGIC;
	clk : IN STD_LOGIC;
	clk_out : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : clk_gen
	PORT MAP (
-- list connections between master ports and signals
	aclr_n => aclr_n,
	clk => clk,
	clk_out => clk_out
	);

	
process
begin
	aclr_n <= '1';
	wait;
end process;
	
process
begin
	clk <= '1'; wait for 10417 ps;
	clk <= '0'; wait for 10417 ps;
end process;
	
	
END clk_gen_arch;

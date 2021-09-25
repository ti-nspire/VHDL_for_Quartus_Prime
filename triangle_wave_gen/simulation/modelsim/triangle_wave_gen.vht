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
-- Generated on "09/25/2021 10:19:03"
                                                            
-- Vhdl Test Bench template for design  :  triangle_wave_gen
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY triangle_wave_gen_vhd_tst IS
END triangle_wave_gen_vhd_tst;
ARCHITECTURE triangle_wave_gen_arch OF triangle_wave_gen_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL aclr_n : STD_LOGIC;
SIGNAL clk : STD_LOGIC;
SIGNAL freq : STD_LOGIC_VECTOR(16 DOWNTO 0);
SIGNAL q : STD_LOGIC_VECTOR(7 DOWNTO 0);
COMPONENT triangle_wave_gen
	PORT (
	aclr_n : IN STD_LOGIC;
	clk : IN STD_LOGIC;
	freq : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
	q : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;
BEGIN
	i1 : triangle_wave_gen
	PORT MAP (
-- list connections between master ports and signals
	aclr_n => aclr_n,
	clk => clk,
	freq => freq,
	q => q
	);

process
begin
	aclr_n <= '1';
	freq   <= "11000011010100000"; -- 100kHz
	wait;
end process;	

process
begin
	clk <= '0'; wait for 10417 ps; -- (1/48MHz)/2
	clk <= '1'; wait for 10416 ps;
end process;
	
END triangle_wave_gen_arch;

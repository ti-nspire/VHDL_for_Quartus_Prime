library ieee;
use ieee.std_logic_1164.all;

entity instruction_decoder is
	port(
		data: in std_logic_vector(7 downto 4);

		zero: in std_logic;
		cout: in std_logic;
		
		ld_en: in std_logic;
		
		a_reg_ld : out std_logic;
		b_reg_ld : out std_logic;
		b_reg_oe : out std_logic;
		rom_oe   : out std_logic;
		alu_as   : out std_logic;
		alu_oe   : out std_logic;
		alu_ld   : out std_logic;
		alu_mux_a: out std_logic;
		alu_mux_b: out std_logic;
		in_oe    : out std_logic;
		out_ld   : out std_logic;
		halt_n   : out std_logic;
		
		pc_ld: out std_logic
	);
end entity;

architecture rtl of instruction_decoder is
	subtype ascending_vect_t is std_logic_vector(0 to 11);
	signal truth_tbl: ascending_vect_t;
begin

	with data select
	truth_tbl <=
		ascending_vect_t'("100101001001") when 4d"0",  -- LD A, [Data]
		ascending_vect_t'("010101001001") when 4d"1",  -- LD B, [Data]
		ascending_vect_t'("101001001001") when 4d"2",  -- LD A, B
		ascending_vect_t'("01-001010001") when 4d"3",  -- LD B, A
		ascending_vect_t'("101001111001") when 4d"4",  -- ADD A, B
		ascending_vect_t'("101011111001") when 4d"5",  -- SUB A, B
		ascending_vect_t'("100101111001") when 4d"6",  -- ADD A, [Data]
		ascending_vect_t'("100111111001") when 4d"7",  -- SUB A, [Data]
		ascending_vect_t'("00-001010011") when 4d"8",  -- OUT A
		ascending_vect_t'("001001001011") when 4d"9",  -- OUT B
		ascending_vect_t'("000101001011") when 4d"10", -- OUT [Data]
		ascending_vect_t'("10-00000-101") when 4d"11", -- IN A
		ascending_vect_t'("000101001001") when 4d"12", -- JUMP [Address]
		ascending_vect_t'("000101001001") when 4d"13", -- JNC [Address]
		ascending_vect_t'("000101001001") when 4d"14", -- JNZ [Address]
		ascending_vect_t'("000-0-00-000") when 4d"15", -- HALT
		ascending_vect_t'(12b"0")         when others;

	a_reg_ld  <= truth_tbl(0) and ld_en;
	b_reg_ld  <= truth_tbl(1) and ld_en;
	b_reg_oe  <= truth_tbl(2);
	rom_oe    <= truth_tbl(3);
	alu_as    <= truth_tbl(4);
	alu_oe    <= truth_tbl(5);
	alu_ld    <= truth_tbl(6) and ld_en;
	alu_mux_a <= truth_tbl(7);
	alu_mux_b <= truth_tbl(8);
	in_oe     <= truth_tbl(9);
	out_ld    <= truth_tbl(10) and ld_en;
	halt_n    <= truth_tbl(11);

	pc_ld <=
		'1' when data = 4d"12"                else -- JUMP [Address]
		'1' when data = 4d"13" and cout = '0' else -- JNC [Address]
		'1' when data = 4d"14" and zero = '0' else -- JNZ [Address]
		'0';

end architecture;

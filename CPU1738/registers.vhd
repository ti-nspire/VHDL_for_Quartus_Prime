library ieee;
use ieee.std_logic_1164.all;

entity registers is
	generic(
		NUM_BITS: natural := 4
	);
	port(
		inp: in std_logic_vector(NUM_BITS-1 downto 0);

		a_reg_ld: in std_logic;
		b_reg_ld: in std_logic;
		out_ld  : in std_logic;
		pc_ld   : in std_logic;
		
		clk_inside: in std_logic;
		aclr_n    : in std_logic;
		
		pc_up: in std_logic;

		a_reg  : out std_logic_vector(NUM_BITS-1 downto 0);
		b_reg  : out std_logic_vector(NUM_BITS-1 downto 0);
		out_reg: out std_logic_vector(NUM_BITS-1 downto 0);
		pc     : out std_logic_vector(NUM_BITS-1 downto 0)
	);
end entity;

architecture rtl of registers is
begin
	-- A_REGを実体化
	a_register: entity work.counter_register
		generic map(
			NUM_BITS => NUM_BITS
		)
		port map(
			clk       => clk_inside,
			aclr_n    => aclr_n,
			sload     => a_reg_ld,
			d         => inp,
			ena_count => '0', -- カウンターを無効化
			q         => a_reg
		);

	-- B_REGを実体化
	b_register: entity work.counter_register
		generic map(
			NUM_BITS => NUM_BITS
		)
		port map(
			clk       => clk_inside,
			aclr_n    => aclr_n,
			sload     => b_reg_ld,
			d         => inp,
			ena_count => '0',  -- カウンターを無効化
			q         => b_reg
		);

	-- OUT_REGを実体化
	out_register: entity work.counter_register
		generic map(
			NUM_BITS => NUM_BITS
		)
		port map(
			clk       => clk_inside,
			aclr_n    => aclr_n,
			sload     => out_ld,
			d         => inp,
			ena_count => '0',  -- カウンターを無効化
			q         => out_reg
		);

	-- PCを実体化
	program_counter: entity work.counter_register
		generic map(
			NUM_BITS => NUM_BITS
		)
		port map(
			clk       => clk_inside,
			aclr_n    => aclr_n,
			sload     => pc_ld,
			d         => inp,
			ena_count => pc_up,  -- カウンターを有効化
			q         => pc
		);

end architecture;
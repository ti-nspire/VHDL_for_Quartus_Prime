library ieee;
use ieee.std_logic_1164.all;

entity registers is
	generic(
		NUM_BITS: natural := 4
	);
	port(
		clk    : in std_logic;
		aclr_n : in std_logic;

		-- "1110"のときA_REGにロード、"1101"のときB_REGにロード、
		-- "1011"のときOUT_REGにロード、"0111"のときPCにロード 
		sload_n: in std_logic_vector(NUM_BITS-1 downto 0);
		
		from_74283: in std_logic_vector(NUM_BITS-1 downto 0);

		a_reg  : out std_logic_vector(NUM_BITS-1 downto 0);
		b_reg  : out std_logic_vector(NUM_BITS-1 downto 0);
		out_reg: out std_logic_vector(NUM_BITS-1 downto 0);
		pc     : out std_logic_vector(NUM_BITS-1 downto 0)
	);
end entity;

architecture rtl of registers is
begin
	-- A_REGを実体化
	a_register: entity work.generic_74161
		generic map(NUM_BITS => NUM_BITS)
		port map(
			clk     => clk,
			aclr_n  => aclr_n,
			sload_n => sload_n(0),
			d       => from_74283,
			p=>'0',t=>'0', -- カウンターを無効化
			q       => a_reg
		);

	-- B_REGを実体化
	b_register: entity work.generic_74161
		generic map(NUM_BITS => NUM_BITS)
		port map(
			clk     => clk,
			aclr_n  => aclr_n,
			sload_n => sload_n(1),
			d       => from_74283,
			p=>'0',t=>'0',  -- カウンターを無効化
			q       => b_reg
		);

	-- OUT_REGを実体化
	out_register: entity work.generic_74161
		generic map(NUM_BITS => NUM_BITS)
		port map(
			clk     => clk,
			aclr_n  => aclr_n,
			sload_n => sload_n(2),
			d       => from_74283,
			p=>'0',t=>'0',  -- カウンターを無効化
			q       => out_reg
		);

	-- PCを実体化
	program_counter: entity work.generic_74161
		generic map(NUM_BITS => NUM_BITS)
		port map(
			clk     => clk,
			aclr_n  => aclr_n,
			sload_n => sload_n(3),
			d       => from_74283,
			p=>'1',t=>'1',  -- カウンターを有効化
			q       => pc
		);

end architecture;
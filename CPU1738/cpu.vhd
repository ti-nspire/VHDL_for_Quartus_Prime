library ieee;
use ieee.std_logic_1164.all;

entity cpu is
	port(
		aclr_n : in std_logic;
		inp    : in std_logic_vector(3 downto 0);
		data   : in std_logic_vector(7 downto 0);
		clk    : in std_logic;

		halt   : out std_logic;
		a_reg  : out std_logic_vector(3 downto 0);
		b_reg  : out std_logic_vector(3 downto 0);
		address: out std_logic_vector(3 downto 0);
		outp   : out std_logic_vector(3 downto 0)
	);
end entity;

architecture rtl of cpu is

	signal alu_b     : std_logic_vector(3 downto 0);
	signal alu_mux_a : std_logic;
	signal alu_mux_b : std_logic;
	signal alu_as    : std_logic;
	signal alu_ld    : std_logic;
	signal clk_inside: std_logic;
	signal add_sub   : std_logic_vector(3 downto 0);
	signal zero      : std_logic;
	signal cout      : std_logic;
	
	signal ld_en    : std_logic;
	signal a_reg_ld : std_logic;
	signal b_reg_ld : std_logic;
	signal b_reg_oe : std_logic;
	signal rom_oe   : std_logic;
	signal alu_oe   : std_logic;
	signal in_oe    : std_logic;
	signal out_ld   : std_logic;
	signal halt_n   : std_logic;
	signal pc_ld    : std_logic;
	
	signal clk_en: std_logic;
	signal pc_up : std_logic;
	
	signal registers_in: std_logic_vector(3 downto 0);
	
	signal a_reg_inside: std_logic_vector(3 downto 0);

begin

	module_alu: entity work.alu
	port map(
		a          => a_reg_inside,
		b          => alu_b,
		mux_a      => alu_mux_a,
		mux_b      => alu_mux_b,
		as         => alu_as,  -- when 0, add; when 1, sub;
		ld         => alu_ld,
		clk_inside => clk_inside,
		aclr_n     => aclr_n, -- 外部へ接続
		add_sub    => add_sub,
		zero       => zero,
		cout       => cout
	);
	
	module_id:entity work.instruction_decoder
	port map(
		data      => data(7 downto 4), -- 外部へ配線
		zero      => zero,
		cout      => cout,
		ld_en     => ld_en ,
		a_reg_ld  => a_reg_ld,
		b_reg_ld  => b_reg_ld,
		b_reg_oe  => b_reg_oe,
		rom_oe    => rom_oe,
		alu_as    => alu_as,
		alu_oe    => alu_oe,
		alu_ld    => alu_ld,
		alu_mux_a => alu_mux_a,
		alu_mux_b => alu_mux_b,
		in_oe     => in_oe,
		out_ld    => out_ld,
		halt_n    => halt_n,
		pc_ld     => pc_ld
	);
	
	module_state_machine:entity work.state_machine
	port map(
		halt_n     => halt_n,
		pc_ld      => pc_ld,
		clk_inside => clk_inside,
		aclr_n     => aclr_n, -- 外部へ配線
		clk_en     => clk_en,
		halt       => halt, -- 外部へ配線
		pc_up      => pc_up,
		ld_en      => ld_en
	);

	module_registers:entity work.registers
	port map(
		inp        => registers_in,
		a_reg_ld   => a_reg_ld,
		b_reg_ld   => b_reg_ld,
		out_ld     => out_ld,
		pc_ld      => pc_ld,
		clk_inside => clk_inside,
		aclr_n     => aclr_n, -- 外部へ配線
		pc_up      => pc_up,
		a_reg      => a_reg_inside,
		b_reg      => b_reg,
		out_reg    => outp, -- 外部へ配線
		pc         => address  -- 外部へ配線
	);
	
	clk_inside <= clk_en and clk;
	
	-- これがトライステートバッファーから代えたマルチプレクサ
	-- ALUの出力かインポートかいずれかをレジスタ群へ渡す。
	registers_in <=
		add_sub when alu_oe else
		inp     when in_oe  else
		(others => '0');

	-- これもトライステートバッファーから代えたマルチプレクサ
	-- Bレジスタかプログラムメモリーに含まれるオペランドかいずれかをALUへ渡す。
	alu_b <=
		b_reg            when b_reg_oe else
		data(3 downto 0) when rom_oe   else
		(others => '0');

	-- A、Bレジスタも確認のため外へ出す。
	a_reg <= a_reg_inside;
	b_reg <= b_reg;
end architecture;

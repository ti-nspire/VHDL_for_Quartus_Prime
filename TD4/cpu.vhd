library ieee;
use ieee.std_logic_1164.all;

entity cpu is
	port(
		clk   : in std_logic;
		aclr_n: in std_logic;
		inp   : in std_logic_vector(3 downto 0); -- INポート
		data  : in std_logic_vector(7 downto 0); -- ROM (プログラムメモリー)から与えられる命令+オペランド。
		
		a_reg  : out std_logic_vector(3 downto 0); -- 確認として信号が出力できるよう端子を設けておく。
		b_reg  : out std_logic_vector(3 downto 0); -- 確認として信号が出力できるよう端子を設けておく。
		outp   : out std_logic_vector(3 downto 0); -- OUTポート
		address: out std_logic_vector(3 downto 0) -- ROM (プログラムメモリー)へ与えるアドレス。
	);
end entity;

architecture rtl of cpu is
	-- モジュール同士を配線するための内部信号
	signal load_n      : std_logic_vector(3 downto 0);
	signal adder_reg   : std_logic_vector(3 downto 0);
	signal a_reg_inside: std_logic_vector(3 downto 0);
	signal b_reg_inside: std_logic_vector(3 downto 0);
	signal mux_adder_a : std_logic_vector(3 downto 0);
	signal cout        : std_logic;
	signal sel         : std_logic_vector(1 downto 0);
	signal c_flag_n    : std_logic;
begin

	-- A、B、OUTの各レジスタおよびPCを実体化
	module_registers: entity work.registers
		port map(
			clk        => clk,    -- 外部へ配線
			aclr_n     => aclr_n, -- 外部へ配線
			sload_n    => load_n,
			from_74283 => adder_reg,
			a_reg      => a_reg_inside,
			b_reg      => b_reg_inside,
			out_reg    => outp,   -- 外部へ配線
			pc         => address -- 外部へ配線
		);

	-- ALUを実体化
	module_adder: entity work.generic_74283
		port map(
			cin  => '0',
			a    => mux_adder_a,
			b    => data(3 downto 0), -- 外部へ配線
			sum  => adder_reg,
			cout => cout	
		);

	-- 命令デコーダーを実体化
	module_id: entity work.instruction_decoder
		port map(
			c_flag_n => c_flag_n,
			op_code  => data(7 downto 4), -- 外部へ配線
			sel      => sel,
			load_n   => load_n
		);

	-- マルチプレクサを実体化
	module_mux: entity work.generic_multiplexer
		port map(
			sel => sel,
			inp(0) => a_reg_inside,
			inp(1) => b_reg_inside,
			inp(2) => inp, -- 外部へ配線
			strobe => '0',
			outp => mux_adder_a
		);
		
	-- ALU (ここでは加算器)のキャリーアウトはDFFに1回通してから命令デコーダーへ渡す。
	-- テキストで言えば7474の回路である。
	process(clk)
	begin
		if rising_edge(clk) then
			c_flag_n <= not cout;
		end if;
	end process;
	
	-- 確認のためA、Bレジスタも外へ出しておく。
	a_reg <= a_reg_inside; -- 外部へ配線
	b_reg <= b_reg_inside; -- 外部へ配線

end architecture;
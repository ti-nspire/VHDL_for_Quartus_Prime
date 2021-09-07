library ieee;
use ieee.std_logic_1164.all;

entity td4 is
	generic(
		F_CLK  : natural := 48_000_000;
		FREQ_LO: natural := 1;
		FREQ_HI: natural := 10
	);
	port(
		aclr_n       : in std_logic;
		inp          : in std_logic_vector(3 downto 0);
		source_clk   : in std_logic;
		manual_clk_in: in std_logic;
		sel          : in std_logic_vector(1 downto 0);
		
		a_reg  : out std_logic_vector(3 downto 0);
		b_reg  : out std_logic_vector(3 downto 0);
		outp   : out std_logic_vector(3 downto 0);
		clk_out: out std_logic
	);
end entity;

architecture rtl of td4 is
	-- モジュール同士を配線するための内部信号	
	signal clk_inside   : std_logic;
	signal delayed_clk_0: std_logic;
	signal delayed_clk_1: std_logic;
	signal data         : std_logic_vector(7 downto 0);
	signal address      : std_logic_vector(3 downto 0);
begin
	-- クロックジェネレーターを実体化
	module_clk_gen: entity work.clk_gen
		generic map(
			F_CLK   => F_CLK,
			FREQ_LO => FREQ_LO,
			FREQ_HI => FREQ_HI
		)
		port map(
			clk           => source_clk,    -- 外部へ配線
			manual_clk_in => manual_clk_in, -- 外部へ配線
			sel           => sel,           -- 外部へ配線
			clk_out       => clk_inside
		);

	-- CPUを実体化
	module_cpu: entity work.cpu
		port map(
			clk     => delayed_clk_1,
			aclr_n  => aclr_n, -- 外部へ配線
			inp     => inp,    -- 外部へ配線
			data    => data,
			a_reg   => a_reg,  -- 外部へ配線
			b_reg   => b_reg,  -- 外部へ配線
			outp    => outp,   -- 外部へ配線
			address => address
		);

	-- ROM (プログラムメモリー)を実体化
	module_rom: entity work.rom
		port map(
			address => address,
			q       => data,
			clock   => clk_inside
		);
		
   -- ROMへ与えるクロックよりもCPUへ与えるクロックを遅らせるためDFFに2回通す。
	process(source_clk)
	begin
		if rising_edge(source_clk) then
			delayed_clk_0 <= clk_inside;
			delayed_clk_1 <= delayed_clk_0;
		end if;
	end process;

   -- 確認用としてクロックを出力できるようにしておく。
	clk_out <= clk_inside; 
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity cpu1738 is
	port(
		source_clk   : in std_logic;
		manual_clk_in: in std_logic;
		sel          : in std_logic_vector(1 downto 0);
		aclr_n       : in std_logic;
		inp          : in std_logic_vector(3 downto 0);

		halt   : out std_logic;
		a_reg  : out std_logic_vector(3 downto 0);
		b_reg  : out std_logic_vector(3 downto 0);
		outp   : out std_logic_vector(3 downto 0);
		clk_out: out std_logic
	);
end entity;

architecture rtl of cpu1738 is
	signal address      : std_logic_vector(3 downto 0);
	signal data         : std_logic_vector(7 downto 0);
	signal clk_inside   : std_logic;
	signal delayed_clk_0: std_logic;
	signal delayed_clk_1: std_logic;
begin
	module_cpu: entity work.cpu
	port map(
		aclr_n  => aclr_n, -- 外部へ配線
		inp     => inp, -- 外部へ配線
		data    => data,
		clk     => delayed_clk_1,
		halt    => halt, -- 外部へ配線
		a_reg   => a_reg, -- 外部へ配線
		b_reg   => b_reg, -- 外部へ配線
		address => address,
		outp    => outp -- 外部へ配線
	);
	
	module_clk_gen: entity work.clk_gen
	port map(
		clk           => source_clk,
		manual_clk_in => manual_clk_in,
		sel           => sel,
		clk_out       => clk_inside
	);
	
	module_rom: entity work.rom
	port map(
		clock   => clk_inside,
		address => address,
		q       => data
	);

	-- 確認のためクロックジェネレーターの出力を外へ出す。
	clk_out <= clk_inside;

	--『CPUの創りかた』と同じく、CPUへ与えるクロックを少し遅らせる。
	process(clk_out)
	begin
		if rising_edge(source_clk) then
			delayed_clk_0 <= clk_inside;
			delayed_clk_1 <= delayed_clk_0;
		end if;
	end process;
end architecture;
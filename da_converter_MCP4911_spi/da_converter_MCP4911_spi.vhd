library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity da_converter_MCP4911_spi is 
	generic(
		F_CLK : positive := 48_000_000;

		F_UPDATE   : positive  := 16_000; --Hz。この頻度でAD変換する。
		NUM_SLAVES : positive  := 1;
		NUM_BITS   : positive  := 16; --(start, buf, !ga, !shdn), 10ビット, (don'tcare 2ビット)
		CLK_DIV    : positive  := 4; --ソースクロックを何分周してsclkにするか。偶数で指定する。奇数は偶数へ切り捨てられる。
		CPOL       : std_logic := '0';
		CPHA       : std_logic := '0'
	);
	port(
		d_para_in : in std_logic_vector(9 downto 0); -- この10ビット値をDA変換する。
		
		aclr_n : in     std_logic;
		clk    : in     std_logic;
		sclk   : buffer std_logic;
		ss_n   : buffer std_logic_vector(NUM_SLAVES - 1 downto 0);
		mosi   : out    std_logic/*;
		--miso   : in     std_logic;
		--busy   : out    std_logic; --確認用
		--enable_one_shot : out std_logic  --確認用*/
	);
end entity;

architecture rtl of da_converter_MCP4911_spi is
	signal enable_inside : std_logic;
begin
	------------------------------------------------------
	--データ更新のタイミング生成
	------------------------------------------------------
	u0 : entity work.clk_gen
	generic map(
		F_CLK    => F_CLK,
		OUT_FREQ => F_UPDATE
	)
	port map(
		aclr_n  => aclr_n,
		clk     => clk,
		clk_out => enable_inside
	);
	------------------------------------------------------
	--Digi-Key TechForumの記事を利用したSPIマスター
	------------------------------------------------------
	u1 : entity work.spi_master
	generic map(
		NUM_SLAVES     => NUM_SLAVES,
		NUM_BITS       => NUM_BITS,
		MAX_DIV_FACTOR => CLK_DIV
	)
	port map(
		aclr_n  => aclr_n,
		clk     => clk,
		enable  => enable_inside,
		cpol    => CPOL,
		cpha    => CPHA,
		cont    => '0',
		clk_div => CLK_DIV,
		addr    => 0,

		tx_data => "0111" & d_para_in & "--", --(start, buf, !ga, !shdn), 10ビット, (don'tcare 2ビット)
		--rx_data =>,

		mosi => mosi,
		miso => '-',

		sclk => sclk,
		ss_n => ss_n/*,

		busy            => busy, --確認用
		enable_one_shot => enable_one_shot --確認用*/
	);
	------------------------------------------------------

end architecture;
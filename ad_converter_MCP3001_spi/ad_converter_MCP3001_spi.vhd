library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ad_converter_MCP3001_spi is 
	generic(
		F_CLK : positive := 48_000_000;

		F_UPDATE   : positive  := 16_000; --Hz。この頻度でAD変換する。
		NUM_SLAVES : positive  := 1;
		NUM_BITS   : positive  := 13; --3ビット + AD変換値10ビット
		CLK_DIV    : positive  := 48; --ソースクロックを何分周してsclkにするか。偶数で指定する。奇数は偶数へ切り捨てられる。
		CPOL       : std_logic := '0';
		CPHA       : std_logic := '0'
	);
	port(
		aclr_n : in     std_logic;
		clk    : in     std_logic;
		sclk   : buffer std_logic;
		ss_n   : buffer std_logic_vector(NUM_SLAVES - 1 downto 0);
		--mosi   : out    std_logic;
		miso   : in     std_logic;
		ad_val : out    std_logic_vector(9 downto 0)/*; 10ビットADC
		busy   : out    std_logic; --確認用
		enable_one_shot : out std_logic  --確認用*/
	);
end entity;

architecture rtl of ad_converter_MCP3001_spi is
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

		tx_data               => (others =>'-'), --tx_data => 13b"-",
		rx_data(ad_val'range) => ad_val,

		--mosi =>
		miso => miso,

		sclk => sclk,
		ss_n => ss_n/*,

		busy            => busy, --確認用
		enable_one_shot => enable_one_shot --確認用*/
	);
	------------------------------------------------------

end architecture;
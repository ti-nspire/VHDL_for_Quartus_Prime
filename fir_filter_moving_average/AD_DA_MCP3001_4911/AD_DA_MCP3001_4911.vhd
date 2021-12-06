library ieee;
use ieee.std_logic_1164.all;

entity AD_DA_MCP3001_4911 is

	generic(
		F_CLK : positive := 48_000_000; --システムクロックHz。

		F_UPDATE   : positive  := 48_000; --Hz。この頻度で(AD変換、DA変換)を繰り返す。
		NUM_SLAVES : positive  := 2;
		NUM_BITS   : positive  := 16; --1回のトランザクションで何ビットやり取りするか。
		SCLK_AD    : positive  := 1_000_000;
		SCLK_DA    : positive  := 12_000_000;
		CPOL       : std_logic := '0';
		CPHA       : std_logic := '0'
	);
	port(
		aclr_n : in std_logic; --非同期クリア
		clk    : in std_logic; --システムクロック

		sclk : out std_logic; --SPIクロック

		ss_n_ad : out std_logic;
		ss_n_da : out std_logic;

		mosi : out std_logic;
		miso : in  std_logic;
		
		rx_data : out std_logic_vector(NUM_BITS - 1 downto 0);
		tx_data : in  std_logic_vector(NUM_BITS - 1 downto 0)
		
	);
end entity;

architecture rtl of AD_DA_MCP3001_4911 is
	signal enable_inside  : std_logic;
	signal clk_div_inside : positive;
	signal addr_inside    : natural;
	signal data_inside    : std_logic_vector(9 downto 0);
begin
	------------------------------------------------------
	--ADC、DACコントローラー
	------------------------------------------------------
	u0 : entity work.ad_da_controller
	generic map(
		F_CLK         => F_CLK,
		F_UPDATE      => F_UPDATE,
		DIV_FACTOR_AD => F_CLK / SCLK_AD,
		DIV_FACTOR_DA => F_CLK / SCLK_DA
	)
	port map(
		aclr_n  => aclr_n,
		clk     => clk,
		enable  => enable_inside,
		addr    => addr_inside,
		clk_div => clk_div_inside
	);
	------------------------------------------------------
	--Digi-Key TechForumの記事を利用したSPIマスター
	------------------------------------------------------
	u1 : entity work.spi_master
	generic map(
		NUM_SLAVES     => NUM_SLAVES,
		NUM_BITS       => NUM_BITS,
		DIV_FACTOR_MAX => F_CLK / SCLK_AD
	)
	port map(
		aclr_n  => aclr_n,
		clk     => clk,
		enable  => enable_inside,
		cpol    => CPOL,
		cpha    => CPHA,
		cont    => '0',
		clk_div => clk_div_inside,
		addr    => addr_inside,

		rx_data => rx_data,
		tx_data => tx_data,

		mosi => mosi,
		miso => miso,
		sclk => sclk,

		--ss_n => ss_n
		ss_n(0) => ss_n_ad,
		ss_n(1) => ss_n_da
	);
	------------------------------------------------------
	
end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fir_filter_experiment is
	generic(
		F_CLK    : positive := 48_000_000;
		F_UPDATE : positive :=     40_000;
		SCLK_AD  : positive :=  1_000_000;
		SCLK_DA  : positive := 12_000_000;
		
		COEFF_WIDTH : integer := 16;
		TAPS        : integer := 101;
		DATA_WIDTH  : integer := 10
	);
	port(
		aclr_n  : in  std_logic;
		clk     : in  std_logic;
		sclk    : out std_logic;
		ss_n_ad : out std_logic;
		ss_n_da : out std_logic;
		mosi    : out std_logic;
		miso    : in  std_logic
	);
end entity;

architecture rtl of fir_filter_experiment is

	constant RESULTS_WIDTH : natural := DATA_WIDTH + COEFF_WIDTH + integer(ceil(log2(real(TAPS))));

	signal ad_val : std_logic_vector(DATA_WIDTH-1 downto 0);
	signal da_val : std_logic_vector(DATA_WIDTH-1 downto 0);

	signal data_inside   : std_logic_vector(DATA_WIDTH   -1 downto 0);
	signal result_inside : std_logic_vector(RESULTS_WIDTH-1 downto 0);

	signal ss_n_ad_inside : std_logic;
	
begin
	
	ss_n_ad <= ss_n_ad_inside;

	--AD変換値(0～1023)を(-512～511)にずらしてからFIRモジュールへ渡す。
	data_inside <= std_logic_vector(unsigned(ad_val) - 512);
	
	--計算結果の上位10ビット(-512～511)を(0～1023)にずらしてからDA変換する。
	--da_val <= std_logic_vector(signed(result_inside(RESULTS_WIDTH-1 downto RESULTS_WIDTH-10))+512);
	da_val <= std_logic_vector(signed(result_inside(RESULTS_WIDTH-9 downto RESULTS_WIDTH-18))+512);

	u1 : entity work.AD_DA_MCP3001_4911
	generic map(
		F_CLK    => F_CLK,
		F_UPDATE => F_UPDATE,
		SCLK_AD  => SCLK_AD,
		SCLK_DA  => SCLK_DA
	)
	port map(
		aclr_n  => aclr_n,
		clk     => clk,
		sclk    => sclk,
		ss_n_ad => ss_n_ad_inside,
		ss_n_da => ss_n_da,
		mosi    => mosi,
		miso    => miso,
		
		rx_data(12 downto 3) =>          ad_val,
		tx_data              => "0111" & da_val & "--"
	);
	
	u2 : entity work.fir_filter
	generic map(
		TAPS        => TAPS,
		DATA_WIDTH  => DATA_WIDTH,
		COEFF_WIDTH => COEFF_WIDTH
	)
	port map(
		clk    => ss_n_ad_inside,
		aclr_n => aclr_n,
		data   => data_inside,
		result => result_inside,
				
coefficients =>
((16d"65503"),(16d"65504"),(16d"65508"),(16d"65516"),(16d"65525"),(16d"0"),(16d"10"),(16d"16"),(16d"17"),(16d"11"),(16d"0"),(16d"65521"),(16d"65508"),(16d"65502"),(16d"65510"),(16d"0"),(16d"45"),(16d"105"),(16d"172"),(16d"234"),(16d"276"),(16d"287"),(16d"259"),(16d"195"),(16d"102"),(16d"0"),(16d"65446"),(16d"65392"),(16d"65388"),(16d"65440"),(16d"0"),(16d"116"),(16d"213"),(16d"249"),(16d"186"),(16d"0"),(16d"65226"),(16d"64819"),(16d"64368"),(16d"63947"),(16d"63638"),(16d"63520"),(16d"63649"),(16d"64047"),(16d"64697"),(16d"0"),(16d"931"),(16d"1836"),(16d"2592"),(16d"3093"),(16d"3269"),(16d"3093"),(16d"2592"),(16d"1836"),(16d"931"),(16d"0"),(16d"64697"),(16d"64047"),(16d"63649"),(16d"63520"),(16d"63638"),(16d"63947"),(16d"64368"),(16d"64819"),(16d"65226"),(16d"0"),(16d"186"),(16d"249"),(16d"213"),(16d"116"),(16d"0"),(16d"65440"),(16d"65388"),(16d"65392"),(16d"65446"),(16d"0"),(16d"102"),(16d"195"),(16d"259"),(16d"287"),(16d"276"),(16d"234"),(16d"172"),(16d"105"),(16d"45"),(16d"0"),(16d"65510"),(16d"65502"),(16d"65508"),(16d"65521"),(16d"0"),(16d"11"),(16d"17"),(16d"16"),(16d"10"),(16d"0"),(16d"65525"),(16d"65516"),(16d"65508"),(16d"65504"),(16d"65503"))

	);

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.types.all;

entity fir_filter_experiment is
	generic(
		F_CLK      : natural := 48_000_000;
		F_UPDATE   : natural :=     40_000;
		SCLK_AD    : natural :=  1_000_000;
		SCLK_DA    : natural := 12_000_000;
		DATA_WIDTH : natural := 10
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

	------------------------------------------------------------------
	constant coeffs_list : coefficient_array := (
		16d"17",16d"27",16d"34",16d"36",16d"30",16d"17",16d"0",16d"65521",16d"65514",16d"65519",16d"0",16d"21",16d"36",16d"31",16d"0",16d"65479",16d"65411",16d"65351",16d"65323",16d"65340",16d"65398",16d"65475",16d"0",16d"11",16d"65491",16d"65377",16d"65246",16d"65157",16d"65163",16d"65295",16d"0",16d"289",16d"535",16d"654",16d"601",16d"397",16d"137",16d"65495",16d"0",16d"338",16d"948",16d"1689",16d"2331",16d"2615",16d"2342",16d"1437",16d"0",16d"63828",16d"62211",16d"61057",16d"27756",16d"61057",16d"62211",16d"63828",16d"0",16d"1437",16d"2342",16d"2615",16d"2331",16d"1689",16d"948",16d"338",16d"0",16d"65495",16d"137",16d"397",16d"601",16d"654",16d"535",16d"289",16d"0",16d"65295",16d"65163",16d"65157",16d"65246",16d"65377",16d"65491",16d"11",16d"0",16d"65475",16d"65398",16d"65340",16d"65323",16d"65351",16d"65411",16d"65479",16d"0",16d"31",16d"36",16d"21",16d"0",16d"65519",16d"65514",16d"65521",16d"0",16d"17",16d"30",16d"36",16d"34",16d"27",16d"17"
	);
	constant BITS_NEEDED : natural := 25;
	------------------------------------------------------------------

	constant COEFF_WIDTH   : natural := coeffs_list(0)'length;
	constant TAPS          : natural := coeffs_list'length;
	constant RESULTS_WIDTH : natural := DATA_WIDTH + COEFF_WIDTH + integer(ceil(log2(real(TAPS))));

	signal ad_val         : std_logic_vector(DATA_WIDTH    - 1 downto 0);
	signal da_val         : std_logic_vector(DATA_WIDTH    - 1 downto 0);
	signal data_inside    : std_logic_vector(DATA_WIDTH    - 1 downto 0);
	signal result_inside  : std_logic_vector(RESULTS_WIDTH - 1 downto 0);
	signal ss_n_ad_inside : std_logic;
	
begin
	
	ss_n_ad <= ss_n_ad_inside;

	--AD変換値(0～1023)を(-512～511)にずらしてからFIRモジュールへ渡す。
	data_inside <= std_logic_vector(unsigned(ad_val) - 512);
	
	--計算結果の10ビット分(-512～511)を(0～1023)にずらしてからDACへ渡す。
	--da_val <= std_logic_vector(signed(result_inside(RESULTS_WIDTH-1 downto RESULTS_WIDTH-10))+512);
	da_val <= std_logic_vector(signed(result_inside(BITS_NEEDED-1 downto BITS_NEEDED-10))+512);


	-------------------------------------------------------
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
	-------------------------------------------------------
	u2 : entity work.fir_filter
	generic map(
		TAPS        => TAPS,
		DATA_WIDTH  => DATA_WIDTH,
		COEFF_WIDTH => COEFF_WIDTH
	)
	port map(
		clk          => ss_n_ad_inside,
		aclr_n       => aclr_n,
		data         => data_inside,
		result       => result_inside,
		coefficients => coeffs_list
	);
	-------------------------------------------------------

end architecture;

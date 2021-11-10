library ieee;
use ieee.std_logic_1164.all;

entity potentio_meter_AD8402_spi is 
	generic(
		F_CLK : positive := 48_000_000;

		F_UPDATE   : positive  := 20_000; --Hz。この頻度でワイパーの位置を更新する。
		NUM_SLAVES : positive  := 1;
		NUM_BITS   : positive  := 10;
		CLK_DIV    : positive  := 12; --ソースクロックを何分周してsclkにするか。偶数で指定する。奇数は偶数へ切り捨てられる。
		CPOL       : std_logic := '0';
		CPHA       : std_logic := '0'
	);
	port(
		ch    : in std_logic;
		wiper : in std_logic_vector(7 downto 0);

		aclr_n : in     std_logic;
		clk    : in     std_logic;
		sclk   : buffer std_logic;
		ss_n   : buffer std_logic_vector(NUM_SLAVES-1 downto 0);
		mosi   : out    std_logic;
		--miso   : in     std_logic;
		busy   : out    std_logic; --確認用

		enable_one_shot : out std_logic  --確認用
	);
end entity;

architecture rtl of potentio_meter_AD8402_spi is
	signal enable_sq_inside : std_logic;
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
		clk_out => enable_sq_inside
	);
	------------------------------------------------------
	--Digi-Key tech forumの記事を利用したSPIマスター
	------------------------------------------------------
	u1 : entity work.spi_master
	generic map(
		NUM_SLAVES     => NUM_SLAVES,
		NUM_BITS       => NUM_BITS,
		MAX_DIV_FACTOR => CLK_DIV
	)
	port map(
		aclr_n    => aclr_n,
		clk       => clk,
		enable_sq => enable_sq_inside,
		cpol      => CPOL,
		cpha      => CPHA,
		cont      => '0',
		clk_div   => CLK_DIV,
		addr      => 0,
		tx_data   => '0' & ch & wiper, --MSBは0固定。
		miso      => '-', --misoは関係ないので何でもよい。
		sclk      => sclk,
		ss_n      => ss_n,
		mosi      => mosi,
		busy      => busy, --確認用
		
		enable_one_shot => enable_one_shot/*, --確認用
		rx_data => ,*/
	);
	------------------------------------------------------

end architecture;

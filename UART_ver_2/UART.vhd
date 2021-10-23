library ieee;
use ieee.std_logic_1164.all;

entity UART is
	generic(
		F_CLK  : positive  := 48_000_000; -- 評価ボードに載っているクロックをそのまま使う。
		BAUD   : positive  := 9600;
		POL_INV: std_logic := '1' -- 0: 正論理, 1: 負論理
	);
	port(
		clk   : in std_logic;
		aclr_n: in std_logic;

		rx: in  std_logic;
		tx: out std_logic;
		
		rx_data: out std_logic_vector(7 downto 0); -- 受信したデータ
		tx_data: in  std_logic_vector(7 downto 0); -- 送信するデータ
		
		rd: out std_logic; -- 受信完了信号
		wr: in  std_logic; -- 送信命令
		
		tx_ready: out std_logic -- 送信可能か
	);
end entity;

architecture rtl of UART is
begin
	module_rx: entity work.serial_rx
	generic map(
		F_CLK   => F_CLK,
		BAUD    => BAUD,
		POL_INV => POL_INV
	)
	port map(
		clk    => clk,
		aclr_n => aclr_n,
		rd     => rd,
		din    => rx,
		dout   => rx_data
	);

	module_tx: entity work.serial_tx
	generic map(
		F_CLK   => F_CLK,
		BAUD    => BAUD,
		POL_INV => POL_INV
	)
	port map(
		clk    => clk,
		aclr_n => aclr_n,
		wr     => wr,
		din    => tx_data,
		dout   => tx,
		ready  => tx_ready
	);
end architecture;
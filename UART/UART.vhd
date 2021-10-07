-- 受信した1バイトをそのまま送り返すサンプル

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART is
	generic(
		F_CLK  : positive  := 48_000_000; -- 評価ボードに載っているクロックをそのまま使う。
		BAUD   : positive  := 9600;
		POL_INV: std_logic := '0' -- 0: 正論理, 1: 負論理
	);
	port(
		clk   : in std_logic;
		aclr_n: in std_logic;

		rx: in  std_logic;
		tx: out std_logic
	);
end entity;

architecture rtl of UART is
	signal data_inside   : std_logic_vector(7 downto 0);
	signal trigger_inside: std_logic;
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
		rd     => trigger_inside,
		din    => rx,
		dout   => data_inside
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
		wr     => trigger_inside,
		din    => data_inside,
		dout   => tx
		--ready  => ready_inside
	);
end architecture;

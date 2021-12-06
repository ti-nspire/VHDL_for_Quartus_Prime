library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ad_da_controller is
	generic(
		F_CLK    : positive := 48_000_000;
		F_UPDATE : positive := 16_000;
		
		DIV_FACTOR_AD  : positive := 48;
		DIV_FACTOR_DA  : positive := 4
	);
	port(
		aclr_n  : in std_logic;
		clk     : in std_logic;
		enable  : out std_logic;

		addr    : out natural  range 0 to 1;
		clk_div : out positive range 2 to DIV_FACTOR_AD --分周比。偶数で指定する。
	);
end entity;

architecture rtl of ad_da_controller is
	signal trigger : std_logic := '0';
begin
	
	--トリガーパルスの0、1をそのままアドレスに使う。
	addr <=
		0 when trigger = '0' else
		1 when trigger = '1' else
		0;
	
	--アドレスに応じて分周比を切り換える。
	clk_div <=
		DIV_FACTOR_AD when trigger = '0' else
		DIV_FACTOR_DA when trigger = '1' else
		DIV_FACTOR_AD;

	------------------------------------
	u1 : entity work.pwm_gen_saw
	generic map(
		F_CLK        => F_CLK,
		DUTY_MAX_uns => d"10",
		NUM_PWM_OUTS => 1,
		PWM_FREQ     => F_UPDATE
	)
	port map(
		aclr_n      => aclr_n,
		clk         => clk,
		pol_inv     => '0',
		right_align => '0',
		duties(0)   => 4d"1",
		pwm_outs(0) => trigger
	);
	------------------------------------
	u2 : entity work.edge_detector
	port map(
		clk             => clk, 
		p_in            => trigger,
		p_out_both_edge => enable
	);
	------------------------------------

end architecture;
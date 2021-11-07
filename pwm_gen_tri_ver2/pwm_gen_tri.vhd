library ieee;
use ieee.std_logic_1164.all;
package typedef_pkg is
	type array_slv is array(natural range <>) of std_logic_vector;
end package;
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.typedef_pkg.all;

entity pwm_gen_tri is
	generic(
		F_CLK        : positive := 48_000_000;
		DUTY_MAX_uns : unsigned := d"100"; --デューティはDUTY_MAXぶんのいくつで指定する。
		
		NUM_PWM_OUTS : positive := 2; --PWMモジュールの個数
		
		--pwm_clkの最大値はF_CLK / 2 Hz。
		--DUTY_MAX_unsの最小値は3。したがって1 pwm周期にpwm_clkは最低でも6クロック必要。
		--よってPWM_FREQの最大値は((F_CLK / 2) / DUTY_MAX) / 6 Hz
		PWM_FREQ : positive := 4_000
	);
	port(
		aclr_n  : in  std_logic;
		clk     : in  std_logic;
		pol_inv : in  std_logic; -- 0: 正転出力; 1: 反転出力
		
		duties   : in  array_slv(0 to NUM_PWM_OUTS - 1)(DUTY_MAX_uns'reverse_range);
		pwm_outs : out std_logic_vector(0 to NUM_PWM_OUTS - 1)
	);
end entity;

architecture rtl of pwm_gen_tri is
	signal pwm_clk     : std_logic;
	signal is_climbing : std_logic;
	signal count       : std_logic_vector(DUTY_MAX_uns'reverse_range);
begin
	u0 : entity work.clk_gen
	generic map(
		F_CLK    => F_CLK,
		OUT_FREQ => PWM_FREQ * to_integer(DUTY_MAX_uns * 2)
	)
	port map(
		aclr_n  => aclr_n,
		clk     => clk,
		pwm_clk => pwm_clk
	);

	u1 : entity work.counter_updown
	generic map(
		TOP_uns    => DUTY_MAX_uns,
		BOTTOM_nat => 0
	)
	port map(
		aclr_n      => aclr_n,
		pwm_clk     => pwm_clk,
		is_climbing => is_climbing,
		count       => count
	);
	
	u2 : for i in pwm_outs'range generate
	comparators: entity work.pwm_comparator
	generic map(
		DUTY_MAX_uns => DUTY_MAX_uns
	)
	port map(
		aclr_n      => aclr_n,
		pwm_clk     => pwm_clk,
		count       => count,
		is_climbing => is_climbing,
		duty        => duties(i),
		pol_inv     => pol_inv,
		pwm_out     => pwm_outs(i)
	);
	end generate;
	
end architecture;

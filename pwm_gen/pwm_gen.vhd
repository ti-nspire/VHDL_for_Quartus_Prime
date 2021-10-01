library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pwm_gen is
	generic(
		F_CLK   : positive := 48_000_000;
		DUTY_MAX: positive := 100;
		PWM_FREQ: positive := 1000
	);
	port(
		aclr_n : in std_logic;
		clk    : in std_logic;
		pol_inv: in std_logic; -- 0: そのまま出力; 1: 反転して出力
		duty   : in std_logic_vector(integer(ceil(log2(real(DUTY_MAX+1)))) - 1 downto 0);
	
		pwm_out: out std_logic
	);
end entity;

architecture rtl of pwm_gen is
	constant DIV_FACTOR: positive := F_CLK/(PWM_FREQ * DUTY_MAX);
	
	signal clk_divided   : std_logic                       := '1';
	signal counter_mod   : natural range 0 to DUTY_MAX - 1 := 0;
	signal pwm_out_inside: std_logic                       := '0';
begin

	-- クロック数DUTY_MAXで所望のpwm周期になるようソースクロック(F_CLK)を分周する。
	process(clk)
		constant TOP_VAL: natural                    := DIV_FACTOR/2 - 1;
		variable count  : natural range 0 to TOP_VAL := 0;
	begin
		if rising_edge(clk) then
			if count >= TOP_VAL then
				count := 0;
				clk_divided <= not clk_divided;
			else
				count := count + 1;
			end if;
		end if;
	end process;
	
	-- 分周したクロックをDUTY_MAX進カウンターでカウント(0 ～ (DUTY_MAX-1))する。
	process(clk_divided, aclr_n)
		constant TOP_VAL: natural := DUTY_MAX - 1;
	begin
		if aclr_n = '0' then
			counter_mod <= 0;
		elsif rising_edge(clk_divided) then
			if counter_mod >= TOP_VAL then
				counter_mod <= 0;
			else
				counter_mod <= counter_mod + 1;
			end if;
		end if;
	end process;

	-- pwm波を生成する。
	process(duty, clk_divided)
	begin

		-- 指定デューティが0ならLを出力し、
		if unsigned(duty) = 0 then
			pwm_out_inside <= '0';

		-- 指定デューティがDUTY_MAXならHを出力し、
		elsif unsigned(duty) = DUTY_MAX then
			pwm_out_inside <= '1';

		elsif rising_edge(clk_divided) then

			-- DUTY_MAX進カウンターがオーバーフローしていたら次のクロックでHを出力し、
			if counter_mod = 0 then
				pwm_out_inside <= '1';

			-- DUTY_MAX進カウンターが指定デューティに達していたら次のクロックでLを出力し、
			elsif counter_mod = unsigned(duty) then
				pwm_out_inside <= '0';

			end if;
		end if;
	end process;

	-- pwm波をそのまま出力または反転出力する。
	pwm_out <=
		    pwm_out_inside when pol_inv = '0' else
		not pwm_out_inside when pol_inv = '1' else
		'0';

end architecture;
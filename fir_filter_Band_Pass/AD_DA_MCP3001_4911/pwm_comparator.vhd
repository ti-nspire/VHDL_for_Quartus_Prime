library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_comparator is
	generic(
		DUTY_MAX_uns : unsigned := d"100" --デューティはDUTY_MAXぶんのいくつで指定する。
	);
	port(
		aclr_n      : in  std_logic;
		pwm_clk     : in  std_logic;
		count       : in  std_logic_vector(DUTY_MAX_uns'reverse_range);
		duty        : in  std_logic_vector(DUTY_MAX_uns'reverse_range);
		pol_inv     : in  std_logic;
		right_align : in  std_logic; -- 0: 左寄せ; 1: 右寄せ
		pwm_out     : out std_logic
	);
end entity;

architecture rtl of pwm_comparator is
begin

	process(aclr_n, pwm_clk, duty, right_align, pol_inv)
		constant COUNTER_TOP : unsigned := DUTY_MAX_uns - 1;
	begin

		if aclr_n ='0' then
			pwm_out <= '0' xor pol_inv;
		
		--指定デューティがMAXのとき
		elsif unsigned(duty) >= DUTY_MAX_uns then
			pwm_out <= '1' xor pol_inv;

		--指定デューティが0のとき
		elsif unsigned(duty) <= 0 then
			pwm_out <= '0' xor pol_inv;

		--pwmを生成
		elsif rising_edge(pwm_clk) then

			--位相重心を左寄せにする場合
			if right_align = '0' then
				if unsigned(count) >= unsigned(duty) then
					pwm_out <= '0' xor pol_inv;
				elsif unsigned(count) >= 0 then
					pwm_out <= '1' xor pol_inv;
				end if;
			end if;

			--位相重心を右寄せにする場合
			if right_align = '1' then
				if unsigned(count) >= DUTY_MAX_uns - unsigned(duty) then
					pwm_out <= '1' xor pol_inv;
				elsif unsigned(count) >= 0 then
					pwm_out <= '0' xor pol_inv;
				end if;
			end if;
	
		end if;

	end process;
end architecture;
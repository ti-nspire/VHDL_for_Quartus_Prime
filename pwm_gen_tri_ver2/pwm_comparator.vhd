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
		is_climbing : in  std_logic;
		pol_inv     : in  std_logic;
		pwm_out     : out std_logic
	);
end entity;

architecture rtl of pwm_comparator is
begin

process(aclr_n, pwm_clk, duty, pol_inv)
		variable threshold : unsigned(DUTY_MAX_uns'reverse_range) := unsigned(duty);
	begin
		threshold := unsigned(duty);

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
			if is_climbing = '0' and unsigned(count) <= threshold + 1 then
				pwm_out <= '1' xor pol_inv;
			elsif is_climbing = '1' and unsigned(count) >= threshold - 1 then
				pwm_out <= '0' xor pol_inv;
			end if;
		end if;
	end process;

end architecture;
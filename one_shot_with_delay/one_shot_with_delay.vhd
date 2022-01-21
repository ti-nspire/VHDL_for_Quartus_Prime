library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity one_shot_with_delay is
	generic(
		F_CLK : natural := 48_000_000;
		
		--最短3クロック強周期～4クロック弱周期、以後1クロック周期刻み
		--F_CLK = 48 MHzなら遅延最短62.5 ～ 83.3 ns、以後20.8 ns刻み
		DELAY_ns : natural := 2000;
		
		--最短1クロック周期、以後1クロック周期刻み
		--F_CLK = 48 MHzなら20.8 ns刻み
		PULSE_ns : natural := 3000
	);
	port(
		aclr_n   : in  std_logic;
		clk      : in  std_logic;
		trigger  : in  std_logic;
		one_shot : out std_logic
	);
end entity;

architecture rtl of one_shot_with_delay is
	type state_type is (idle_state, delay_state, pulse_state);
	signal state : state_type;
	
	--triggerシグナルをクロック1周期長のワンショットパルス化するためのシグナル
	signal q0, d0, p_out : std_logic;
	
begin
	process(clk, aclr_n)
		constant DELAY_COUNTS: natural:= integer(ceil((real(DELAY_ns)*real(F_CLK))/real(1E9)));
		constant PULSE_COUNTS: natural:= integer(ceil((real(PULSE_ns)*real(F_CLK))/real(1E9)));
		constant TOTAL_COUNTS: natural:= DELAY_COUNTS + PULSE_COUNTS;
		
		variable counter      : natural;
		constant counter_init : natural := 2;

	begin
		--triggerシグナルをクロック1周期長のワンショットパルス化するための回路
		p_out <= d0 and (not q0);
	
		if not aclr_n then
			counter  := counter_init;
			one_shot <= '0';
			state    <= idle_state;
		
		elsif rising_edge(clk) then
			--triggerシグナルをクロック1周期長のワンショットパルス化するための回路
			q0 <= d0; d0 <= trigger;
			
			case state is
			when idle_state =>
				counter  := counter_init;
				one_shot <= '0';

				if p_out then
					state <= delay_state;
				end if;
				
			when delay_state =>
				one_shot <= '0';

				if DELAY_COUNTS = 0 then
					state <= pulse_state;
				elsif counter >= DELAY_COUNTS - 1 then
					state <= pulse_state;
				else
					counter := counter + 1;
					state   <= delay_state;
				end if;
				
			when pulse_state =>
				one_shot <= '1';

				if counter >= TOTAL_COUNTS - 1 then
					one_shot <= '0';
					counter  := counter_init;
					state    <= idle_state;
				else
					counter := counter + 1;
					state   <= pulse_state;
				end if;
			end case;

		end if;

	end process;
end architecture;

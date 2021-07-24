library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity one_hot_state_counter is
	generic(
		NUM_PHASES: natural := 16
	);
	port(
		aclr_n: in std_logic;
		sclr_n: in std_logic;
		clk   : in std_logic;
	
		n_phase_clk: out std_logic_vector(NUM_PHASES-1 downto 0)
	);
end entity;

architecture rtl of one_hot_state_counter is
begin

	process(all)
		variable count: natural := 0;
	begin
		-- 非同期リセット
		if aclr_n = '0' then
			count := 0;
		elsif rising_edge(clk) then
			-- 同期リセット
			if sclr_n = '0' then
				count := 0;
			-- オーバーフローしたらリセット
			elsif count >= NUM_PHASES-1 then
				count := 0;
			-- オーバーフローするまでカウントアップ
			else
				count := count + 1;
			end if;
		end if;
		-- N相クロックを出力
		n_phase_clk <= std_logic_vector(to_unsigned(2 ** count, NUM_PHASES)); -- 1倍、2倍、4倍、8倍...でone hotを移動
		--n_phase_clk <= std_logic_vector(shift_left(to_unsigned(1, NUM_PHASES), count)); -- シフトでone hotを移動
	end process;

end architecture;

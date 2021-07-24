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
	procedure reset is
	begin
		n_phase_clk(NUM_PHASES-1 downto 1) <= (others => '0');
		n_phase_clk(0) <= '1';
	end procedure;
begin
	process(all)
	begin
		-- 非同期リセット
		if aclr_n = '0' then
			reset;
		elsif rising_edge(clk) then
			-- 同期リセット
			if sclr_n = '0' then
				reset;
			-- MSBに1が立ったら次のクロックでリセット
			elsif n_phase_clk(NUM_PHASES-1) then
				reset;
			-- MSBに1が立っていなければ左へシフト
			elsif n_phase_clk(NUM_PHASES-1) = '0' then
				n_phase_clk <= n_phase_clk(NUM_PHASES-2 downto 0) & '0';
			-- いずれでもなければLSBに1を立てる。
			else
				reset;
			end if;
		end if;
	end process;
end architecture;

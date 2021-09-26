library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity triangle_wave_gen_bcd is
	generic(
		F_CLK       : positive := 48_000_000;
		F_OUT_MAX   : positive := 9999; -- 最大出力周波数
		NUM_OUT_BITS: positive := 8;    -- 三角波出力のビット数
		TO_RAIL     : positive := 45    -- 出力レールまでの余裕
	);
	port(
		aclr_n  : in std_logic;
		clk     : in std_logic;
		freq_bcd: in std_logic_vector(15 downto 0); -- 4桁bcdで周波数を設定する。

		triangle_out: out std_logic_vector(NUM_OUT_BITS-1 downto 0)
	);
end entity;

architecture rtl of triangle_wave_gen_bcd is
	constant Q_MAX: positive := 2**NUM_OUT_BITS - 1;
	signal top_val: positive range 1 to F_CLK / 2;
begin

	-- 出力周波数の設定値が変化したらカウンターのトップ値を入れ換える。
	process(freq_bcd)
		variable freq_temp: positive range 1 to F_OUT_MAX := F_OUT_MAX;
	begin
		if unsigned(freq_bcd) > 0 then
			freq_temp := to_integer(unsigned(freq_bcd( 3 downto  0))
				+ unsigned'(d"10")  *unsigned(freq_bcd( 7 downto  4))
				+ unsigned'(d"100") *unsigned(freq_bcd(11 downto  8))
				+ unsigned'(d"1000")*unsigned(freq_bcd(15 downto 12)));
		else
			freq_temp := F_OUT_MAX;
		end if;
		top_val <= F_CLK / (2 * freq_temp);
	end process;

	process(clk, aclr_n)
		variable count: natural range  0 to F_CLK / 2 := 0;
		variable diff : integer range -1 to 1         := 1;
	begin
		-- 非同期クリア
		if aclr_n = '0' then
			count := 0;
		-- 同期カウントアップダウン
		elsif rising_edge(clk) then
			if count    <= 0       then diff :=  1;
			elsif count >= top_val then diff := -1;
			end if;
			count := count + diff;
		end if;

		-- スケーリングして出力
		triangle_out <= std_logic_vector(to_unsigned((count*(Q_MAX-2*TO_RAIL))/top_val+TO_RAIL, NUM_OUT_BITS));

	end process;
end architecture;
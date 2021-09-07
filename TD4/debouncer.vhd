library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer is
	generic(
		F_CLK      : natural := 48_000_000;
		BOUNCE_msec: natural := 15;   -- 想定されるバウンス時間(ミリ秒単位)
		IS_INVERTED: boolean := false -- 極性を反転するかしないか
	);
	port(
		clk         : in  std_logic;
		bounce_in   : in  std_logic;
		debounce_out: out std_logic
	);
end entity;

architecture rtl of debouncer is
	-- 想定されるバウンス時間までカウントするためのカウンターのトップ値。厳密に設定する必要はない。
	constant COUNT_MAX: natural := F_CLK * BOUNCE_msec/1000 - 1; 
	
	-- 入力信号を同期化したあとの信号
	signal in_reg: std_logic;
begin

	process(clk)
		variable count: natural := 0;
	begin
		if rising_edge(clk) then
			-- 入力信号を同期化する。必ずしも必要ではない。
			-- 必要に応じて極性を反転する。
			case IS_INVERTED is
				when false  => in_reg <=     bounce_in;
				when true   => in_reg <= not bounce_in;
				when others => in_reg <=     bounce_in;
			end case;

			-- 入出力のロジックが一致している限り(バウンスが原因で偶然一致した場合も含む)、
			-- カウンターをリセットし続ける。
			if debounce_out = in_reg then
				count := 0;
			else
				count := count + 1;
			end if;
			
		-- 入出力のロジックの不一致状態が一定時間以上継続したら出力をトグルする。
		elsif falling_edge(clk) then
			if count >= COUNT_MAX then
				debounce_out <= not debounce_out;
			end if;
		end if;
	end process;

end architecture;

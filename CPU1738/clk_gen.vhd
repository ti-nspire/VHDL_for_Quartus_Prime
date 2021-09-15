library ieee;
use ieee.std_logic_1164.all;

entity clk_gen is
	generic(
		F_CLK: natural := 48_000_000;
		
		FREQ_LO: natural := 1;
		FREQ_HI: natural := 10
	);
	port(
		clk          : in  std_logic;
		manual_clk_in: in  std_logic;
		sel          : in  std_logic_vector(1 downto 0);
		
		clk_out: out std_logic
	);
end entity;

architecture rtl of clk_gen is
	signal manual_signal: std_logic;
	signal auto_signal  : std_logic;
begin

	-- ディバウンサーを実体化
	manual: entity work.debouncer
		generic map(
			F_CLK       => F_CLK,
			BOUNCE_msec => 15,
			IS_INVERTED => true
		)
		port map(
			clk          => clk,
			bounce_in    => manual_clk_in,
			debounce_out => manual_signal
		);

	-- 1Hz、10Hzクロック生成器を実体化
	auto: entity work.auto_clk
		generic map(
			F_CLK   => F_CLK,
			FREQ_LO => FREQ_LO,
			FREQ_HI => FREQ_HI
		)
		port map(
			clk     => clk,
			sel     => sel(1), -- 0のときFREQ_LOを、1のときFREQ_HIを出力
			clk_out => auto_signal
		);
		
	process(all)
	begin
		if rising_edge(clk) then
			case sel is
				when "00"      => clk_out <= manual_signal; -- セレクト信号が"00"のとき手動クロックを出力
				when "01"|"10" => clk_out <= auto_signal; -- "01"のときFREQ_LOを、"10"のときFREQ_HIを出力
				when others    => clk_out <= '0'; -- それ以外のときはクロック停止
			end case;
		end if;
	end process;
	
end architecture;

-- 参考: Interface (インターフェース), 2009年09月号, pp.116-118, CQ出版

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_rx is
	generic(
		F_CLK  : positive  := 48_000_000;
		BAUD   : positive  := 9600;
		POL_INV: std_logic := '0' -- 0: 正論理; 1: 負論理	
	);
	port(
		clk   : in std_logic;
		aclr_n: in std_logic;
		din   : in std_logic;

		rd  : out std_logic;
		dout: out std_logic_vector(7 downto 0)		
	);
end entity;

architecture rtl of serial_rx is
	signal buf  : std_logic_vector(7 downto 0);
	signal start: std_logic;
	signal cbit : natural range 0 to 159;
	signal rx_en: std_logic;
	
	signal din_temp: std_logic;
begin
	module_clk_gen: entity work.clk_gen
	generic map(
		F_CLK    => F_CLK,
		OUT_FREQ => BAUD * 16
	)
	port map(
		aclr_n  => aclr_n,
		clk     => clk,
		clk_out => rx_en
	);


	din_temp <= din when POL_INV = '0' else not din;

	process(aclr_n, rx_en)
	begin
		if aclr_n = '0' then
			start <= '0';
			cbit  <=  0 ;
			buf   <= (others => '0');
			dout  <= (others => '0');
		elsif rising_edge(rx_en) then
			if start = '0' then
				rd <= '0';
				if din_temp = '0' then -- RXラインがHからLに変化して、
					start <= '1';
				end if;
				cbit <= 0;
			else
				case cbit is
					when 6 => -- それが本当にスタートビットであったら、
						if din_temp = '1' then
							cbit  <=  0 ;
							start <= '0';
						else
							cbit <= cbit + 1;
						end if;
					when 22|38|54|70|86|102|118|134 => -- 16クロックごとに、
						buf  <= din_temp & buf(7 downto 1); -- lsbから順番に読み取って、
						cbit <= cbit + 1;
					when 135 =>
						dout <= buf; -- 全部読み取り終えたらすぐにデータを更新して、
						cbit <= cbit + 1;
					when 159 => -- ストップビットの末尾で、
						cbit  <=  0 ;
						start <= '0';
						rd    <= '1'; -- 受信完了信号を出す。
					when others =>
						cbit <= cbit + 1;
				end case;
			end if;
		end if;
	end process;
end architecture;

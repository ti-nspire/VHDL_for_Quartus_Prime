-- 参考: Interface (インターフェース), 2009年09月号, pp.116-118, CQ出版

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_tx is
	generic(
		F_CLK  : positive  := 48_000_000;
		BAUD   : positive  := 9600;
		POL_INV: std_logic := '0' -- 0: 正論理; 1: 負論理	
	);
	port(
		clk   : in std_logic;
		aclr_n: in std_logic;
		wr    : in std_logic;
		din   : in std_logic_vector(7 downto 0);

		dout : out std_logic;
		ready: out std_logic
	);
end entity;

architecture rtl of serial_tx is
	signal in_din: std_logic_vector(7 downto 0);
	signal buf   : std_logic_vector(7 downto 0);

	signal tx_en: std_logic;
	signal load : std_logic;
	signal run  : std_logic;

	signal cbit : natural range 0 to 7;
	signal state: natural range 0 to 2;
	
	signal dout_temp: std_logic;

begin
	module_clk_gen: entity work.clk_gen
	generic map(
		F_CLK    => F_CLK,
		OUT_FREQ => BAUD
	)
	port map(
		aclr_n  => aclr_n,
		clk     => clk,
		clk_out => tx_en
	);
	
	ready <= '1' when run = '0' and load = '0' else '0';
	
	dout <= dout_temp when POL_INV = '0' else not dout_temp;
	
	process(clk, aclr_n)
	begin
		if aclr_n = '0' then
			load <= '0';
		elsif rising_edge(clk) then
			if wr = '1' and run = '0' then 
				load   <= '1';
				in_din <= din;
			end if;
			if load = '1' and run = '1' then
				load <= '0';
			end if;
		end if;
	end process;
	
	process(tx_en, aclr_n)
	begin
		if aclr_n = '0' then
			dout_temp <= '1';
			cbit      <=  0 ;
			state     <=  0 ;
			run       <= '0';
		elsif rising_edge(tx_en) then
			case state is
				when 0 =>
					cbit <= 0;
					if load then
						dout_temp <= '0'; --スタートビット
						state <= state + 1;
						buf   <= in_din;
						run   <= '1';
					else
						dout_temp <= '1';
						run <= '0';
					end if;
				when 1 =>
					if cbit <= 6 then
						dout_temp <= buf(cbit); -- lsbから順番に送信する。
						cbit      <= cbit + 1;
					elsif cbit = 7 then
						dout_temp <= buf(cbit);
						state     <= state + 1;
					end if;
				when 2 =>
					dout_temp <= '1'; --ストップビット
					state     <=  0 ;
				when others =>
					state <= 0;
			end case;
		end if;
	end process;
	
end architecture;
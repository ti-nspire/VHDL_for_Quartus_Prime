library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_register is
	generic(
		NUM_BITS: natural := 4
	);
	port(
		clk   : in std_logic;
		aclr_n: in std_logic;
		sload : in std_logic;
		d     : in std_logic_vector(NUM_BITS-1 downto 0);
		
		ena_count: in std_logic;
		
		q: out std_logic_vector(NUM_BITS-1 downto 0)
	);
end entity;

architecture rtl of counter_register is
	signal count: natural range 0 to 2**NUM_BITS-1; -- この変数をカウンターとして使う。
	constant COUNT_MAX: natural := 2**NUM_BITS-1;   -- カウンターのトップ値。
begin
	-- カウント値をそのまま出力する。
	q <= std_logic_vector(to_unsigned(count, NUM_BITS));
	
	process(all)
	begin

		-- !非同期リセット
		if aclr_n = '0' then
			count <= 0;

		elsif rising_edge(clk) then

			-- 同期ロード
			if sload then
				count <= to_integer(unsigned(d));

			-- 同期カウント
			elsif ena_count then
				if count >= COUNT_MAX then
					count <= 0;
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;
	
end architecture;
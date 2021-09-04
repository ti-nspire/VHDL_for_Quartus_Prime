library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hc161 is
	generic(
		NUM_BITS: natural := 4
	);
	port(
		clk       : in std_logic;
		aclr_n    : in std_logic;
		sload_n   : in std_logic;
		d         : in std_logic_vector(NUM_BITS-1 downto 0);
		
		p, t: in std_logic;
		
		q  : out std_logic_vector(NUM_BITS-1 downto 0);
		rco: out std_logic
	);
end entity;

architecture rtl of hc161 is
	signal count: natural range 0 to 2**NUM_BITS - 1;
	constant COUNT_MAX: natural := 2**NUM_BITS - 1;
begin

	q   <= std_logic_vector(to_unsigned(count, NUM_BITS));
	rco <= '1' when t = '1' and count >= 2**NUM_BITS - 1 else '0';

	process(clk)
	begin

		-- 非同期リセット
		if aclr_n = '0' then
			count <= 0;

		elsif rising_edge(clk) then
			-- 同期ロード
			if sload_n = '0' then
				count <= to_integer(unsigned(d));
			-- 同期カウント
			elsif p and t then
				if count >= COUNT_MAX then
					count <= 0;
				else
					count <= count + 1;
				end if;
			end if;
		end if;
	end process;
	
end architecture;
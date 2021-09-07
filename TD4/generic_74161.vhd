library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_74161 is
	generic(
		NUM_BITS: natural := 4
	);
	port(
		clk       : in std_logic;
		aclr_n    : in std_logic; -- aはasynchronousの意味
		sload_n   : in std_logic; -- sはsynchronousの意味
		d         : in std_logic_vector(NUM_BITS-1 downto 0);
		
		p: in std_logic;
		t: in std_logic;
		
		q  : out std_logic_vector(NUM_BITS-1 downto 0);
		rco: out std_logic -- リプルキャリーアウト
	);
end entity;

architecture rtl of generic_74161 is
	signal count: natural range 0 to 2**NUM_BITS - 1; -- この変数をカウンターとして使う。
	constant COUNT_MAX: natural := 2**NUM_BITS - 1;   -- カウンターのトップ値。
begin
	-- カウント値をそのまま出力する。
	q <= std_logic_vector(to_unsigned(count, NUM_BITS));
	
	-- リプルキャリーアウト機能(出力の全ビットに1が立っている間、1を出力する)を実装する。
	rco <= '1' when t = '1' and count >= COUNT_MAX else '0';

	process(all)
	begin

		-- !非同期リセット
		if aclr_n = '0' then
			count <= 0;

		elsif rising_edge(clk) then

			-- !同期ロード
			if sload_n = '0' then
				count <= to_integer(unsigned(d));

			-- 同期カウント
			elsif p and t then
				if count >= COUNT_MAX then -- カウンターのトップ値に達していたら0にロールオーバーする。
					count <= 0;
				else
					count <= count + 1; -- カウンターのトップ値に達していなかったらカウントアップする。
				end if;
			end if;
		end if;
	end process;
	
end architecture;
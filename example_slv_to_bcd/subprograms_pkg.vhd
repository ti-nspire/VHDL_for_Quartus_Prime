library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package subprograms_pkg is
	function slv_to_bcd(slv: std_logic_vector) return std_logic_vector;
end package;

package body subprograms_pkg is

	function slv_to_bcd(slv: std_logic_vector) return std_logic_vector is
		-- 元の値の整数表現
		constant INT: natural := to_integer(unsigned(slv));
		-- BCD表現での桁数
		constant NUM_BCD: natural := to_integer(ceil(log10(real(INT + 1))));
		-- 出力に必要なビット数。
		constant NUM_OUT_BITS: natural := NUM_BCD*4;
		-- 出力値の假置き変数
		variable bcd: unsigned(NUM_OUT_BITS-1 downto 0) := (others => '0');
	begin
		for i in slv'length-1 downto 1 loop
			bcd := bcd(NUM_OUT_BITS-2 downto 0) & slv(i);
			for j in NUM_BCD downto 1 loop
				if bcd(j*4-1 downto j*4-4) > 4 then
					bcd(j*4-1 downto j*4-4) := bcd(j*4-1 downto j*4-4) + 3;
				end if;
			end loop;
		end loop;
		bcd := bcd(NUM_OUT_BITS-2 downto 0) & slv(0);
		return std_logic_vector(bcd);
	end function;
	
end package body;

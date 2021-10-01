library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package my_conv_pkg is
	function slv_to_bcd(slv: std_logic_vector; num_bcd: natural) return std_logic_vector;
	function bcd_to_int(bcd: std_logic_vector) return natural;
end package;

package body my_conv_pkg is


------------------------------------------------------------------------
function slv_to_bcd(slv: std_logic_vector; num_bcd: natural) return std_logic_vector is
	-- 出力に必要なビット数。
	constant NUM_OUT_BITS: natural := num_bcd * 4;
	-- 出力値の假置き変数
	variable bcd: unsigned(NUM_OUT_BITS-1 downto 0) := (others => '0');
begin
	for i in slv'length-1 downto 1 loop
		bcd := bcd(NUM_OUT_BITS-2 downto 0) & slv(i);
		for j in num_bcd downto 1 loop
			if bcd(j*4-1 downto j*4-4) > 4 then
				bcd(j*4-1 downto j*4-4) := bcd(j*4-1 downto j*4-4) + 3;
			end if;
		end loop;
	end loop;
	bcd := bcd(NUM_OUT_BITS-2 downto 0) & slv(0);
	return std_logic_vector(bcd);
end function;
------------------------------------------------------------------------



------------------------------------------------------------------------
function bcd_to_int(bcd: std_logic_vector) return natural is
	constant NUM_BCD: natural := bcd'length / 4;
	variable sum    : natural := to_integer(unsigned(bcd(3 downto 0)));
begin
	for i in 1 to NUM_BCD - 1 loop
		sum := sum + to_integer(unsigned(bcd(i*4+3 downto i*4))) * (10**i);
	end loop;
	return sum;
end function;
------------------------------------------------------------------------


	
end package body;
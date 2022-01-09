library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
	type coefficient_array is array (natural range <>) of std_logic_vector;
	type data_array        is array (natural range <>) of signed;
	type product_array     is array (natural range <>) of signed;
end package types;

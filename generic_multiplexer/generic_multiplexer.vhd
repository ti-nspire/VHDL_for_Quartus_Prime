-- Define a type of an array comprised of std_logic_vectors.
-- This type is only used in here, and not packaged as a separate file.
library ieee;
use ieee.std_logic_1164.all;
package typedef is
	type array_slv is array(natural range <>) of std_logic_vector;
end package;
----------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.typedef.all;

entity generic_multiplexer is
	generic(
		NUM_BITS    : natural := 4;
		NUM_WORDS   : natural := 3;
		NUM_SEL_BITS: natural := 2  -- ceil(log2(NUM_WORDS))
	);
	port(
		sel   : in std_logic_vector(NUM_SEL_BITS-1 downto 0 );
		inp   : in array_slv(0 to NUM_WORDS-1)(NUM_BITS-1 downto 0);
		strobe: in std_logic; -- when H, all Ls.
		
		outp: out std_logic_vector(NUM_BITS-1 downto 0)
	);
end entity;

architecture rtl of generic_multiplexer is
begin

	process(all)
		variable which_word: natural;
	begin
		which_word := to_integer(unsigned(sel));

		-- implement a strobe feature.
		if strobe = '1' then
			outp <= (others => '0');

		-- implement a mux feature.
		elsif which_word <= NUM_WORDS-1 then
			case which_word is
				when 0 to NUM_WORDS-1 => outp <= inp(which_word);
				when others           => outp <= (others => '0');
			end case;

		-- just to be safe.
		else
			outp <= (others => '0');
		end if;
	end process;

end architecture;
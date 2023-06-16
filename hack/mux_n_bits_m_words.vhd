--------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package mux_n_bits_m_words_pkg is
    type mux_t is array (natural range <>) of std_logic_vector;
    function num_sel_bits(num_words: positive) return positive;
end package;

package body mux_n_bits_m_words_pkg is
    function num_sel_bits(num_words: natural) return positive is
    begin
        return integer(ceil(log2(real(num_words))));
    end function;
end package body;
--------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mux_n_bits_m_words_pkg.all;

entity mux_n_bits_m_words is
    generic (
        NUM_BITS: positive := 16;
        NUM_WORDS: positive := 2
    );
    port (
        inp: in mux_t(0 to NUM_WORDS-1)(NUM_BITS-1 downto 0);
        sel: in std_logic_vector(num_sel_bits(NUM_WORDS)-1 downto 0);
        
        outp: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end entity;

architecture rtl of mux_n_bits_m_words is
begin
    outp <= inp(to_integer(unsigned(sel)));
end architecture;
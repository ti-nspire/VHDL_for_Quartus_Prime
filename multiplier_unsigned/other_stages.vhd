library ieee;
use ieee.std_logic_1164.all;

entity other_stages is
    generic (
        NUM_BITS: natural := 4
    );
    port (
        m: in std_logic_vector(NUM_BITS-1 downto 0);
        q: in std_logic;
        
        pp_in: in std_logic_vector(NUM_BITS-1 downto 0);
        pp_out: out std_logic_vector(NUM_BITS downto 0)
    );
end entity;

architecture logic of other_stages is
    signal mult_by_1_bit: std_logic_vector(NUM_BITS-1 downto 0);
begin
    u_0: entity work.multiplied_by_1_bit
    generic map (
        NUM_BITS => NUM_BITS
    )
    port map (
        m => m,
        q => q,
        p => mult_by_1_bit
    );
    
    u_1: entity work.adder_lookahead
    generic map (
        NUM_BITS => NUM_BITS
    )
    port map (
        x => mult_by_1_bit,
        y => pp_in,
        cout => pp_out(NUM_BITS),
        s => pp_out(NUM_BITS-1 downto 0)
    );
end architecture;
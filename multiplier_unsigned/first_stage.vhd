library ieee;
use ieee.std_logic_1164.all;

entity first_stage is
    generic (
        NUM_BITS: natural := 4
    );
    port (
        m: in std_logic_vector(NUM_BITS-1 downto 0);
        q: in std_logic;
        
        pp_out: out std_logic_vector(NUM_BITS downto 0)
    );
end entity;

architecture logic of first_stage is
begin
    u_first_stage: entity work.multiplied_by_1_bit
    generic map (
        NUM_BITS => NUM_BITS
    )
    port map (
        m => m,
        q => q,
        p => pp_out(NUM_BITS-1 downto 0)
    );
    
    pp_out(NUM_BITS) <= '0';
end architecture;
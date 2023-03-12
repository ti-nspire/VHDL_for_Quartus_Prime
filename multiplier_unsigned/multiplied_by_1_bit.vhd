library ieee;
use ieee.std_logic_1164.all;

entity multiplied_by_1_bit is
    generic (
        NUM_BITS: natural := 4
    );
    port (
        m: in std_logic_vector(NUM_BITS-1 downto 0);
        q: in std_logic;
        p: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end entity;

architecture logic of multiplied_by_1_bit is
    signal p_expand: std_logic_vector(m'range);
begin
    p_expand <= (others => q);
    p <= m and p_expand;
    
    -- VHDL2008以降はベクタとシングルビットとの論理演算ができるようになったはずだが
    -- Liteバージョンではできないようだ。and回路なので下のようにマルチプレクサにしてもよい。
    --p <= m when q = '1' else (others => '0');
    
end architecture;
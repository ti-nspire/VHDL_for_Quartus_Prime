library ieee;
use ieee.std_logic_1164.all;

entity register_n_bits is
    generic (
        NUM_BITS: positive := 16
    );
    port (
        clk: in std_logic;
        reset: in std_logic;
        load: in std_logic;
        d: in std_logic_vector(NUM_BITS-1 downto 0);
        
        q: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end entity;

architecture rtl of register_n_bits is
begin
    process (clk, reset, load)
    begin
        if rising_edge(clk) then
            if reset then
                q <= (others => '0'); -- 同期リセット
            elsif load then
                q <= d; -- 同期ロード
            end if;
        end if;
    end process;
end architecture;
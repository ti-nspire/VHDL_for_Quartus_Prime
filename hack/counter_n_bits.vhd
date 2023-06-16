library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_n_bits is
    generic (
        NUM_BITS: positive := 16
    );
    port (
        inp: in std_logic_vector(NUM_BITS-1 downto 0);
        clk: in std_logic;
        reset: in std_logic;
        load: in std_logic;
        
        outp: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end entity;

architecture rtl of counter_n_bits is
begin
    process (clk, reset, load)
    begin
        if rising_edge(clk) then
            if reset then
                outp <= (others => '0'); -- 同期リセット
            elsif load then
                outp <= inp; -- 同期ロード
            else
                outp <= std_logic_vector(unsigned(outp) + 1);
            end if;
        end if;
    end process;
end architecture;
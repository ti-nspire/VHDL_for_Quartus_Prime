library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity n_bits_adder_lookahead is
    generic (
        NUM_BITS: natural := 8
    );
    port (
        c0: in std_logic;
        x: in std_logic_vector(NUM_BITS-1 downto 0);
        y: in std_logic_vector(NUM_BITS-1 downto 0);
        
        cout: out std_logic;
        s: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end entity;

architecture logic of n_bits_adder_lookahead is
    signal g: std_logic_vector(NUM_BITS-1 downto 0);
    signal p: std_logic_vector(NUM_BITS-1 downto 0);
    signal c: std_logic_vector(NUM_BITS downto 0);
    
    type type_1dx1d is array(1 to NUM_BITS) of std_logic_vector(NUM_BITS-1 downto 0);
    signal term: type_1dx1d;

    -- 最適化されないようにする。
    attribute keep: boolean;
    attribute keep of g, p, c, term: signal is true;
begin
    c(0) <= c0;
    g <= x and y;
    p <= x or y;

    process(g, p, c, term)
    begin
        for i in 1 to NUM_BITS loop
        for j in 0 to i-1 loop
            if j=0 then
                term(i)(j) <= and_reduce(p(i-1 downto 0) & c(0));
            else
                term(i)(j) <= and_reduce(p(i-1 downto j) & g(j-1));
            end if;
            c(i) <= or_reduce(g(i-1) & term(i)(j downto 0));
        end loop;
        end loop;
    end process;
    
    cout <= c(NUM_BITS);
    s <= x xor y xor c(NUM_BITS-1 downto 0);

end architecture;
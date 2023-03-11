library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity n_bits_adder_lookahead is
    generic (
        NUM_BITS: natural := 4
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
begin

    process(c0, x, y)
        variable g: std_logic_vector(NUM_BITS-1 downto 0) := (others => '0');
        variable p: std_logic_vector(NUM_BITS-1 downto 0) := (others => '0');
        variable c: std_logic_vector(NUM_BITS downto 0) := (others => '0');
        
        type term_t is array(1 to NUM_BITS) of std_logic_vector(NUM_BITS-1 downto 0);
        variable term: term_t := (others => (others => '0'));
    begin
        c(0) := c0;
        g := x and y;
        p := x or y;

        for i in 1 to NUM_BITS loop
        for j in 0 to i-1 loop
            if (j > 0) then
                term(i)(j) := and_reduce(p(i-1 downto j) & g(j-1));
            else
                term(i)(0) := and_reduce(p(i-1 downto 0) & c(0));    
            end if;
            c(i) := or_reduce(g(i-1) & term(i)(j downto 0));
        end loop;
        end loop;
        
        cout <= c(NUM_BITS);
        s <= x xor y xor c(NUM_BITS-1 downto 0);
    end process;

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity n_bits_adder_lookahead is
    generic (
        NUM_BITS: natural := 4
    );
    port (
        c0: in std_logic;
        x, y: in std_logic_vector(NUM_BITS-1 downto 0);
        
        cout: out std_logic;
        s: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end entity;

architecture logic of n_bits_adder_lookahead is
begin

    process(c0, x, y)
        variable g, p: std_logic_vector(NUM_BITS-1 downto 0) := (others => '0');
        variable c: std_logic_vector(NUM_BITS downto 0) := (others => '0');

        type term_t is array(1 to NUM_BITS) of std_logic_vector(NUM_BITS-1 downto 0);
        variable term: term_t := (others => (others => '0'));
    begin
        c(0) := c0;
        g := x and y;
        p := x or y;

        for i in term'range loop
        for j in 0 to i-1 loop
            if (j > 0) then
                term(i)(j) := and_reduce(p(i-1 downto j) & g(j-1));
            else
                term(i)(0) := and_reduce(p(i-1 downto 0) & c(0));
            end if;
            c(i) := or_reduce(g(i-1) & term(i)(j downto 0));
        end loop;
        end loop;

        cout <= c(NUM_BITS);
        s <= x xor y xor c(x'range);
    end process;

end architecture;

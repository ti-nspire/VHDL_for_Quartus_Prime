library ieee;
use ieee.std_logic_1164.all;

entity ram8 is
    port (
        inp: in std_logic_vector(15 downto 0);
        clk: in std_logic;
        load: in std_logic;
        address: in std_logic_vector(2 downto 0);
        outp: out std_logic_vector(15 downto 0);
        

        
        out_port: out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of ram8 is
    type load_t is array (0 to 7) of std_logic;
    signal temp_load: load_t;
    
    type reg_q_t is array (0 to 7) of std_logic_vector(15 downto 0);
    signal temp_q: reg_q_t;
begin
    u0: entity work.dmux8way
    port map (
        inp => load,
        sel => address,
        a => temp_load(0),
        b => temp_load(1),
        c => temp_load(2),
        d => temp_load(3),
        e => temp_load(4),
        f => temp_load(5),
        g => temp_load(6),
        h => temp_load(7)
    );
    
    u1a: for i in 0 to 7 generate
        u1b: entity work.register_16_bit
        port map (
            clk => clk,
            reset => reset,
            load => temp_load(i),
            d => inp,
            q => temp_q(i)
        );
    end generate;
    out_port <= temp_q(0);
        
    u2: entity work.mux8way16
    port map (
        a => temp_q(0),
        b => temp_q(1),
        c => temp_q(2),
        d => temp_q(3),
        e => temp_q(4),
        f => temp_q(5),
        g => temp_q(6),
        h => temp_q(7),
        sel => address,
        outp => outp
    );
end architecture;
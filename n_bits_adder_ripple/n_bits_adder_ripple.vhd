library ieee;
use ieee.std_logic_1164.all;

entity n_bits_adder_ripple is
    generic (
        NUM_BITS: natural := 4
    );
    port (
        c0: in std_logic;
        x: in std_logic_vector(NUM_BITS-1 downto 0);
        y: in std_logic_vector(NUM_BITS-1 downto 0);
        
        cout: out std_logic_vector(NUM_BITS downto 1); -- リップルの様子が見えるよう端子に出しておく。
        s: out std_logic_vector(NUM_BITS-1 downto 0)
     );
end entity;

architecture rtl of n_bits_adder_ripple is
    signal c_inside: std_logic_vector(NUM_BITS downto 0);
begin

   --u1: for i in s'range generate
    u1: for i in 0 to NUM_BITS-1 generate
        fa: entity work.full_adder
        port map (
            cin => c_inside(i),
            x => x(i),
            y => y(i),
            cout => c_inside(i+1),
            s => s(i)
        );
    end generate;
    
    c_inside(0) <= c0;
    cout <= c_inside(NUM_BITS downto 1);

end architecture;
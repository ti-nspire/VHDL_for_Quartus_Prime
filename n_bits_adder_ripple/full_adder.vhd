library ieee;
use ieee.std_logic_1164.all;

entity full_adder is
    port (
        cin: in std_logic;
        x: in std_logic;
        y: in std_logic;
        
        cout: out std_logic;
        s: out std_logic
    );
end entity;

architecture logic of full_adder is
begin
    s <= x xor y xor cin;
    cout <= (x and y) or (x and cin) or (y and cin);
end architecture;
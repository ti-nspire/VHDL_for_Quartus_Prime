library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_74283 is
    generic(
        NUM_BITS natural = 4
    );
    port(
        cin  in  std_logic;
        a    in  std_logic_vector(NUM_BITS-1 downto 0);
        b    in  std_logic_vector(NUM_BITS-1 downto 0);
        
        sum  out std_logic_vector(NUM_BITS-1 downto 0);
        cout out std_logic
    );
end entity;

architecture rtl of generic_74283 is
   -- キャリーアウトを得たいので1ビット拡張する。
    signal temp_sum unsigned(NUM_BITS downto 0);
begin
   -- 各オペランドのビット数は最長ビットのオペランドに合わせて拡張される。
    temp_sum = ('0' & unsigned(a)) + unsigned(b) + ('0' & cin);

    sum  = std_logic_vector(temp_sum)(NUM_BITS-1 downto 0);
    cout = temp_sum(NUM_BITS);
end architecture;
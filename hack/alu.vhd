library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_misc.all;

entity alu is
    generic (
        NUM_BITS: positive := 16
    );
    port (
        x: in std_logic_vector(NUM_BITS-1 downto 0);
        y: in std_logic_vector(NUM_BITS-1 downto 0);
        
        zx_nx_zy_ny_f_no: in std_logic_vector(5 downto 0);
        
        outp: out std_logic_vector(NUM_BITS-1 downto 0);
        zr: out std_logic;
        ng: out std_logic
    );
end entity;

architecture rtl of alu is
    signal sx: signed(NUM_BITS-1 downto 0);
    signal sy: signed(NUM_BITS-1 downto 0);
    
    signal signed_outp: signed(NUM_BITS-1 downto 0);
begin
    outp <= std_logic_vector(signed_outp);
    
    sx <= signed(x);
    sy <= signed(y);    
    
    zr <= '1' when signed_outp = 0 else '0';
    ng <= '1' when signed_outp < 0 else '0';
    --zr <= nor_reduce(signed_outp) = '1';
    --ng <= temp_outp(signed_outp'length-1);

    signed_outp <=
        to_signed(0, NUM_BITS) when zx_nx_zy_ny_f_no = "101010" else
        to_signed(1, NUM_BITS) when zx_nx_zy_ny_f_no = "111111" else
        to_signed(-1, NUM_BITS) when zx_nx_zy_ny_f_no = "111010" else
        --(others => '0') when zx_nx_zy_ny_f_no = "101010" else
        --(0 => '1', others => '0') when zx_nx_zy_ny_f_no = "111111" else
        --(others => '1') when zx_nx_zy_ny_f_no = "111010" else
        
        sx when zx_nx_zy_ny_f_no = "001100" else
        sy when zx_nx_zy_ny_f_no = "110000" else
        
        not sx when zx_nx_zy_ny_f_no = "001101" else
        not sy when zx_nx_zy_ny_f_no = "110001" else
        
        0 - sx when zx_nx_zy_ny_f_no = "001111" else
        0 - sy when zx_nx_zy_ny_f_no = "110011" else
        
        sx + 1 when zx_nx_zy_ny_f_no = "011111" else
        sy + 1 when zx_nx_zy_ny_f_no = "110111" else
        
        sx - 1 when zx_nx_zy_ny_f_no = "001110" else
        sy - 1 when zx_nx_zy_ny_f_no = "110010" else
        
        sx + sy when zx_nx_zy_ny_f_no = "000010" else
        sx - sy when zx_nx_zy_ny_f_no = "010011" else
        sy - sx when zx_nx_zy_ny_f_no = "000111" else
        
        sx and sy when zx_nx_zy_ny_f_no = "000000" else
        sx or sy when zx_nx_zy_ny_f_no = "010101" else
        (others => '-');
    
end architecture;
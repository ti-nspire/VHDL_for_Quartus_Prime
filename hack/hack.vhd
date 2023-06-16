library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package hack_pkg is
    function num_sel_bits(num_words: positive) return positive;
    
    constant NUM_BITS_CONST: positive := 16;
    constant ROM_WORDS_CONST: positive := 4096;
    constant RAM_WORDS_CONST: positive := 8192;
    constant SCREEN_BASE_CONST: natural := RAM_WORDS_CONST + 0;
    constant SCREEN_WORDS_CONST: natural := 384;
    constant KEYBOARD_ADDRESS_CONST: natural := RAM_WORDS_CONST + SCREEN_WORDS_CONST;
    constant OUT_REG_ADDRESS_CONST: natural := KEYBOARD_ADDRESS_CONST + 1;
end package;

package body hack_pkg is
    function num_sel_bits(num_words: natural) return positive is
    begin
        return integer(ceil(log2(real(num_words))));
    end function;
end package body;
use work.hack_pkg.all;
--------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hack is
    generic (
        NUM_BITS: positive := NUM_BITS_CONST;
        ROM_WORDS: positive := ROM_WORDS_CONST;
        
        RAM_WORDS: positive := RAM_WORDS_CONST;
        SCREEN_WORDS: positive := SCREEN_WORDS_CONST;

        SCREEN_BASE_ADDRESS: natural := SCREEN_BASE_CONST;
        KEYBOARD_ADDRESS: natural := KEYBOARD_ADDRESS_CONST;
        OUT_REG_ADDRESS: natural := OUT_REG_ADDRESS_CONST
    );
    port (
        --monitor_load_a_reg: out std_logic;
        --monitor_load_d_reg: out std_logic;
        --monitor_load_pc: out std_logic;
        --monitor_zr: out std_logic;
        --monitor_ng: out std_logic;
        --monitor_d_reg_out: out std_logic_vector(NUM_BITS-1 downto 0)
    
        reset: in std_logic;
        clk: in std_logic;
        in_port: in std_logic_vector(NUM_BITS-1 downto 0);
        
        clk_out: out std_logic;
        
        screen_sel: in std_logic_vector(num_sel_bits(SCREEN_WORDS)-1 downto 0);
        screen_out: out std_logic_vector(NUM_BITS-1 downto 0);
        
        out_reg_out: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end entity;

architecture rtl of hack is
    signal in_m: std_logic_vector(in_port'range);
    signal instruction: std_logic_vector(in_port'range);
    signal write_m: std_logic;
    signal out_m: std_logic_vector(in_port'range);
    signal address_m: std_logic_vector(NUM_BITS-2 downto 0);
    signal out_pc: std_logic_vector(in_port'range);
begin
    clk_out <= clk;

    cpu: entity work.cpu
    port map (
        clk => not clk,
        reset => reset,
        instruction => instruction,
        in_m => in_m,
        out_m => out_m,
        address_m => address_m,
        write_m => write_m,
        pc => out_pc/*,
        
        monitor_load_a_reg => monitor_load_a_reg,
        monitor_load_d_reg => monitor_load_d_reg,
        monitor_load_pc => monitor_load_pc,
        monitor_zr => monitor_zr
        monitor_ng => monitor_ng,
        monitor_d_reg_out => monitor_d_reg_out
        */
    );
    
    memory: entity work.memory
    generic map (
        NUM_BITS => NUM_BITS,
        
        RAM_WORDS => RAM_WORDS,
        SCREEN_WORDS => SCREEN_WORDS,
        
        SCREEN_BASE_ADDRESS => SCREEN_BASE_ADDRESS,
        KEYBOARD_ADDRESS => KEYBOARD_ADDRESS,
        OUT_REG_ADDRESS => OUT_REG_ADDRESS        
    )
    port map (
        inp => out_m,
        clk => clk,
        reset => reset,
        address => address_m,
        load => write_m,
        outp => in_m,

        screen_sel => screen_sel,
        screen_out => screen_out,
        
        keyboard_in => in_port,
        
        out_reg_out => out_reg_out       
    );
    

    -----------------------------------------------------------
    gen_rom: case ROM_WORDS generate
        when 4096 =>
            rom: entity work.rom4k
            port map (
                address => out_pc(num_sel_bits(ROM_WORDS)-1 downto 0),
                clock => clk,
                q => instruction
            );
        when 8192 =>
            rom: entity work.rom8k
            port map (
                address => out_pc(num_sel_bits(ROM_WORDS)-1 downto 0),
                clock => clk,
                q => instruction
            );
        when 16384 =>
            rom: entity work.rom16k
            port map (
                address => out_pc(num_sel_bits(ROM_WORDS)-1 downto 0),
                clock => clk,
                q => instruction
            );
        when others =>
            rom: entity work.rom4k
            port map (
                address => out_pc(num_sel_bits(ROM_WORDS)-1 downto 0),
                clock => clk,
                q => instruction
            );
    end generate;
    -----------------------------------------------------------
   

end architecture;
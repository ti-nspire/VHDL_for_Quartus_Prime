library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package memory_pkg is
    function num_sel_bits(num_words: positive) return positive;
end package;
package body memory_pkg is
    function num_sel_bits(num_words: natural) return positive is
    begin
        return integer(ceil(log2(real(num_words))));
    end function;
end package body;
use work.memory_pkg.all;
--------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
    generic (
        NUM_BITS: positive := 16;
        
        RAM_WORDS: natural := 8192;
        SCREEN_WORDS: natural := 384;
        SCREEN_SEL_BITS: natural := 9;
        
        SCREEN_BASE_ADDRESS: natural := 8192;
        KEYBOARD_ADDRESS: natural := 8192 + 384;
        OUT_REG_ADDRESS: natural := 8192 + 384 + 1
    );
    port (
        inp: in std_logic_vector(NUM_BITS-1 downto 0);
        clk: in std_logic;
        reset: in std_logic;
        address: in std_logic_vector(NUM_BITS-2 downto 0);
        load: in std_logic;
        keyboard_in: in std_logic_vector(NUM_BITS-1 downto 0);
        
        outp: out std_logic_vector(NUM_BITS-1 downto 0);

        screen_sel: in std_logic_vector(SCREEN_SEL_BITS-1 downto 0);
        screen_out: out std_logic_vector(NUM_BITS-1 downto 0);
        
        out_reg_out: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end entity;

architecture rtl of memory is
    signal write_ram: std_logic;
    signal write_screen: std_logic;
    signal write_out_reg: std_logic;
    
    signal ram_out: std_logic_vector(NUM_BITS-1 downto 0);
    signal keyboard_out: std_logic_vector(NUM_BITS-1 downto 0);
    
    signal wraddress_offsetted: std_logic_vector(SCREEN_SEL_BITS-1 downto 0);
begin
    -------------------------------------------------------
    gen_ram: case RAM_WORDS generate
        when 8192 =>
            ram_module: entity work.ram8k
            port map (
                aclr => reset,
                address => address(num_sel_bits(RAM_WORDS)-1 downto 0),
                clock => clk,
                data => inp,
                wren => write_ram,
                q => ram_out
            );
        when 4096 =>
            ram_module: entity work.ram4k
            port map (
                aclr => reset,
                address => address(num_sel_bits(RAM_WORDS)-1 downto 0),
                clock => clk,
                data => inp,
                wren => write_ram,
                q => ram_out
            );
        when others =>
            ram_module: entity work.ram8k
            port map (
                aclr => reset,
                address => address(num_sel_bits(RAM_WORDS)-1 downto 0),
                clock => clk,
                data => inp,
                wren => write_ram,
                q => ram_out
            );
    end generate;
    -------------------------------------------------------        
          
   
    -- IPカタログのRAM: 2-PORTを使って作った。
    -- readアドレスとwriteアドレスと分けた。
    screen_module: entity work.screen384
    port map (
        aclr => reset,
		clock => clk,
		data => inp,
		rdaddress => screen_sel,
		wraddress => wraddress_offsetted,
		wren => write_screen,
		q => screen_out
    );
    
    keyboard_module: entity work.register_n_bits
    generic map (
        NUM_BITS => NUM_BITS
    )
    port map (
        clk => clk,
        reset => reset,
        load => '1',
        d => keyboard_in,
        q => keyboard_out
    );
    
    out_reg_module: entity work.register_n_bits
    generic map (
        NUM_BITS => NUM_BITS
    )
    port map (
        clk => clk,
        reset => reset,
        load => write_out_reg,
        d => inp,
        q => out_reg_out
    );
    
    mem_cnt: entity work.memory_controller
    generic map (
        NUM_BITS => NUM_BITS,
        
        SCREEN_WORDS => SCREEN_WORDS,
        SCREEN_SEL_BITS => SCREEN_SEL_BITS,
        
        SCREEN_BASE_ADDRESS => SCREEN_BASE_ADDRESS,
        KEYBOARD_ADDRESS => KEYBOARD_ADDRESS,
        OUT_REG_ADDRESS => OUT_REG_ADDRESS
    )
    port map (
        address => address,
        load => load,
        
        from_ram => ram_out,
        from_keyboard => keyboard_out,
        to_cpu => outp,
        
        screen_write_address => wraddress_offsetted,
        
        write_ram => write_ram,
        write_screen => write_screen,
        write_out_reg => write_out_reg
    );
   
end architecture;
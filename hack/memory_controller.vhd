library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory_controller is
    generic (
        NUM_BITS: positive := 16;
        
        SCREEN_WORDS: positive := 384;
        SCREEN_SEL_BITS: positive := 9;
        
        SCREEN_BASE_ADDRESS: natural := 8192;
        KEYBOARD_ADDRESS: natural := 8192 + 384;
        OUT_REG_ADDRESS: natural := 8192 + 384 + 1
    );
    port (
        address: in std_logic_vector(NUM_BITS-2 downto 0);
        load: in std_logic;
        
        from_ram: in std_logic_vector(NUM_BITS-1 downto 0);
        from_keyboard: in std_logic_vector(NUM_BITS-1 downto 0);
        to_cpu: out std_logic_vector(NUM_BITS-1 downto 0);
        
        screen_write_address: out std_logic_vector(SCREEN_SEL_BITS-1 downto 0);
        
        write_ram: out std_logic;
        write_screen: out std_logic;
        write_out_reg: out std_logic
    );
end entity;

architecture rtl of memory_controller is
    signal us_address: unsigned(address'range);
begin
    us_address <= unsigned(address);
    
    -- screen384へ与えるアドレスは、SCREEN_BASE_ADDRESSの分だけオフセットする。
    screen_write_address <=
        std_logic_vector(us_address - SCREEN_BASE_ADDRESS)(screen_write_address'range);

    write_ram <= '1'
        when
            load = '1' and
            us_address < SCREEN_BASE_ADDRESS
        else '0';
    write_screen <= '1'
        when
            load = '1' and
            SCREEN_BASE_ADDRESS <= us_address and
            us_address < KEYBOARD_ADDRESS
        else '0';
    write_out_reg <= '1'
        when
            load = '1' and
            us_address = OUT_REG_ADDRESS
        else '0';
    to_cpu <=
        from_ram when us_address < SCREEN_BASE_ADDRESS else
        from_keyboard when us_address = KEYBOARD_ADDRESS else
        (others => '-');

end architecture;
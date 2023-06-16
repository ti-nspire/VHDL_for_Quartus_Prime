library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram16k is
    port (
        inp: in std_logic_vector(15 downto 0);
        clk: in std_logic;
        load: in std_logic;
        address: in std_logic_vector(13 downto 0);
        outp: out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of ram16k is
    type memory_t is array (0 to 2**(address'length)-1) of std_logic_vector(inp'range);
    signal my_ram: memory_t;
    attribute ramstyle: string;
    attribute ramstyle of my_ram: signal is "M9K";
    
    signal temp_address: natural range my_ram'range;
begin
    temp_address <= to_integer(unsigned(address));
    
    --outp <= my_ram(address);
    process(clk, load)
    begin
        --outp <= my_ram(address);
        if rising_edge(clk) then
            outp <= my_ram(temp_address); -- 同期読み出しにしないとメモリーブロックに配置されない。
            if load='1' then
                my_ram(temp_address) <= inp; -- イネーブル時のみ同期書き込み
            end if;
        end if;
    end process;
end architecture;
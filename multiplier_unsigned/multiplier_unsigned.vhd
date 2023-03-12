library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_unsigned is
    generic (
        NUM_BITS: natural := 8
    );
    port (
        m, q: in std_logic_vector(NUM_BITS-1 downto 0);
        p: out std_logic_vector(NUM_BITS*2-1 downto 0);
        
        -- ieee.numeric_stdライブラリーによる計算結果も出力して比較する。
        p_lib_used: out std_logic_vector(NUM_BITS*2-1 downto 0)
    );
end entity;

architecture logic of multiplier_unsigned is
    type pp_t is array(0 to NUM_BITS-1) of std_logic_vector(NUM_BITS downto 0);
    signal pp: pp_t;
begin
    u_first_stage: entity work.first_stage
    generic map (
        NUM_BITS => NUM_BITS
    )
    port map (
        m => m,
        q => q(0),
        pp_out => pp(0)
    );

    u_other_stages: for i in 1 to NUM_BITS-1 generate
        u1: entity work.other_stages
        generic map (
            NUM_BITS => NUM_BITS
        )
        port map (
            m => m,
            q => q(i),
            pp_in => pp(i-1)(NUM_BITS downto 1),
            pp_out => pp(i)
        );
    end generate;

    u_output: for i in 0 to NUM_BITS-2 generate
        p(i) <= pp(i)(0);
    end generate;

    p(NUM_BITS*2-1 downto NUM_BITS-1) <= pp(NUM_BITS-1);

    -- ライブラリーを使えば乗算演算子を記述するだけで回路が出来上がる。
    p_lib_used <= std_logic_vector(unsigned(m) * unsigned(q));

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decoder is
    generic (
        NUM_BITS: positive := 16
    );
    port (
        instruction: in std_logic_vector(NUM_BITS-1 downto 0);
        zr: in std_logic;
        ng: in std_logic;
        
        sel_alu_inst: out std_logic;
        sel_a_m: out std_logic;

        load_a_reg: out std_logic;
        load_d_reg: out std_logic;
        load_pc: out std_logic;
        write_m: out std_logic;

        zx_nx_zy_ny_f_no: out std_logic_vector(5 downto 0)
    );
end entity;

architecture rtl of instruction_decoder is
    alias is_c_inst is instruction(instruction'length-1);
    
    alias a is instruction(12);
    --alias cccccc is instruction(11 downto 6);
    alias dest_a is instruction(5);
    alias dest_d is instruction(4);
    alias dest_m is instruction(3);
    alias jjj is instruction(2 downto 0);
    
    signal greater: std_logic;
    signal equal: std_logic;
    signal greater_equal: std_logic;
    signal less: std_logic;
    signal not_equal: std_logic;
    signal less_equal: std_logic;
begin
    -- c命令のときはalu_outをa regへ渡す。
    -- a命令のときはinstをa regへ渡す。
    sel_alu_inst <= not is_c_inst;

    -- c命令であり、かつinstructionのaビットが0ならa regを、1ならmを、aluに渡す。
    sel_a_m <= a and is_c_inst;
    
    -- c命令であり、かつストア先がa regのときに1を立てる(次のクロックでa regが更新される)。
    -- または、a命令であるときに1を立てる(次のクロックでa regが更新される)。
    load_a_reg <= (is_c_inst and dest_a) or (not is_c_inst);
    
    -- c命令であり、かつストア先がd regのときに1を立てる(次のクロックでd regが更新される)。
    load_d_reg <= is_c_inst and dest_d;
    
    -- c命令であり、かつストア先がramのときに1を立てる(次のクロックでramが更新される)。
    write_m <= is_c_inst and dest_m;
    
    -- aluへ与える命令を抜き出して出力する。
    zx_nx_zy_ny_f_no <= instruction(11 downto 6);

    greater <= (not zr) and (not ng);
    equal <= zr;
    greater_equal <= not ng;
    less <= ng;
    not_equal <= not zr;
    less_equal <= zr or ng;
    load_pc <=
        '1' when
            is_c_inst='1' and (
            (jjj=3d"1" and greater='1') or
            (jjj=3d"2" and equal='1') or
            (jjj=3d"3" and greater_equal='1') or
            (jjj=3d"4" and less='1') or
            (jjj=3d"5" and not_equal='1') or
            (jjj=3d"6" and less_equal='1') or
            (jjj=3d"7")) else
        '0';

end architecture;
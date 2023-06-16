library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    generic (
        NUM_BITS: positive := 16
    );
    port (
        clk: in std_logic;
        reset: in std_logic;
        
        instruction: in std_logic_vector(NUM_BITS-1 downto 0);
        in_m: in std_logic_vector(NUM_BITS-1 downto 0);

        out_m: out std_logic_vector(NUM_BITS-1 downto 0);
        address_m: out std_logic_vector(NUM_BITS-2 downto 0);
        write_m: out std_logic;

        pc: out std_logic_vector(NUM_BITS-1 downto 0);
        
        monitor_load_a_reg: out std_logic;
        monitor_load_d_reg: out std_logic;
        monitor_load_pc: out std_logic;
        monitor_zr: out std_logic;
        monitor_ng: out std_logic;
        monitor_d_reg_out: out std_logic_vector(NUM_BITS-1 downto 0)
    );
end entity;

architecture rtl of cpu is
    signal alu_out: std_logic_vector(NUM_BITS-1 downto 0);
    signal a_reg_in: std_logic_vector(NUM_BITS-1 downto 0);
    signal a_reg_out: std_logic_vector(NUM_BITS-1 downto 0);
    signal alu_x: std_logic_vector(NUM_BITS-1 downto 0);
    signal alu_y: std_logic_vector(NUM_BITS-1 downto 0);
    
    signal zx_nx_zy_ny_f_no: std_logic_vector(5 downto 0);
    signal zr: std_logic;
    signal ng: std_logic;
            
    signal sel_alu_inst: std_logic;
    signal sel_a_m: std_logic;
    
    signal load_a_reg: std_logic;
    signal load_d_reg: std_logic;
    signal load_pc: std_logic;
begin
    address_m <= a_reg_out(NUM_BITS-2 downto 0);
    out_m <= alu_out;

    monitor_load_a_reg <= load_a_reg;
    monitor_load_d_reg <= load_d_reg;
    monitor_load_pc <= load_pc;
    monitor_zr <= zr; 
    monitor_ng <= ng;
    monitor_d_reg_out <= alu_x;    

    mux_alu_inst: entity work.mux_n_bits_m_words
    generic map (
        NUM_BITS => NUM_BITS,
        NUM_WORDS => 2
    )
    port map (
        inp(0) => alu_out,
        inp(1) => instruction,
        sel(0) => sel_alu_inst,
        outp => a_reg_in
    );
    
    a_reg: entity work.register_n_bits
    generic map (
        NUM_BITS => NUM_BITS
    )
    port map (
        clk => clk,
        reset => reset,
        load => load_a_reg,
        d => a_reg_in,
        q => a_reg_out
    );
    
    d_reg: entity work.register_n_bits
    generic map (
        NUM_BITS => NUM_BITS
    )
    port map (
        clk => clk,
        reset => reset,
        load => load_d_reg,
        d => alu_out,
        q => alu_x
    );
    
    mux_a_m: entity work.mux_n_bits_m_words
    generic map (
        NUM_BITS => NUM_BITS,
        NUM_WORDS => 2
    )
    port map (
        inp(0) => a_reg_out,
        inp(1) => in_m,
        sel(0) => sel_a_m,
        outp => alu_y
    );
    
    alu: entity work.alu
    generic map (
        NUM_BITS => NUM_BITS
    )
    port map (
        x => alu_x,
        y => alu_y,
        
        zx_nx_zy_ny_f_no => zx_nx_zy_ny_f_no,
        zr => zr, 
        ng => ng, 
        
        outp => alu_out
    );
    
    id: entity work.instruction_decoder
    generic map (
        NUM_BITS => 16
    )
    port map (
        instruction => instruction,
        zr => zr,
        ng => ng,
        zx_nx_zy_ny_f_no => zx_nx_zy_ny_f_no,
        
        load_a_reg => load_a_reg,
        load_d_reg => load_d_reg,
        load_pc => load_pc,
        write_m => write_m,

        sel_alu_inst => sel_alu_inst,
        sel_a_m => sel_a_m
    );
    
    program_counter: entity work.counter_n_bits
    generic map (
        NUM_BITS => NUM_BITS
    )
    port map (
        inp => a_reg_out,
        clk => clk,
        reset => reset,
        load => load_pc,
        outp => pc
    );
 
end architecture;
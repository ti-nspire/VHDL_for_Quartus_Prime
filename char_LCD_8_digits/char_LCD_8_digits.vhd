library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity char_LCD_8_digits is
	generic(
		F_CLK : natural := 32_768
	);
	port(
		clk   : in std_logic;
		rst_n : in std_logic;
		bin_in: in std_logic_vector(31 downto 0);
		
		E : buffer std_logic;
		RS: out    std_logic;
		DB: out    std_logic_vector(7 downto 4);
		
		is_ready: out std_logic -- Whether the power_on_reset completed(1) or not(0).
	);
end entity;

architecture rtl of char_LCD_8_digits is

	type state_type is (
		power_on_reset1,
		/*power_on_reset2,
		power_on_reset3,
		power_on_reset4,
		power_on_reset5,
		power_on_reset6,
		power_on_reset7,*/
		power_on_reset8,

		FunctionSet1, FunctionSet2, FunctionSet3,
		FunctionSet4, FunctionSet5, FunctionSet6,

		ClearDisplay_H, DisplayControl_H, EntryMode_H,
		ClearDisplay_L, DisplayControl_L, EntryMode_L,

		W_10M_H, W_1M_H, W_100k_H, W_10k_H, W_1k_H, W_100_H, W_10_H, W_1_H,
		W_10M_L, W_1M_L, W_100k_L, W_10k_L, W_1k_L, W_100_L, W_10_L, W_1_L,
		
		ReturnHome_H, ReturnHome_L
	);
	
	
	signal pr_state, nx_state: state_type;
	/*
	attribute keep: boolean;
	attribute keep of pr_state, nx_state: signal is true;
	*/

	
	function upper_4(num: std_logic_vector(3 downto 0))
		return std_logic_vector is
	begin
		if   unsigned(num) < 10 then return "0011"; -- when 0-9
		else                         return "0100"; -- when A-F
		end if;
	end function;

	function lower_4(num: std_logic_vector(3 downto 0))
		return std_logic_vector	is
	begin
		if   unsigned(num) < 10 then return num;       -- when 0-9
		else return std_logic_vector(unsigned(num)-9); -- when A-F
		end if;
	end function;

begin

   -- generate a clock signal whose period is 2 ms or more.
	process(clk)
		constant count_max: natural := F_CLK / 900;
		variable count: natural range 0 to count_max;
	begin
		if rising_edge(clk) then
			count := count + 1;
			if count = count_max then
				count := 0;
				E <= not E;
			end if;
		end if;
	end process;

   -- a register for keeping a state.
	process(E, rst_n)
	begin
		if    rst_n = '0'    then pr_state <= power_on_reset1;
		elsif rising_edge(E) then pr_state <= nx_state;
		end if;
	end process;

   -- a combinational logic circuit for deciding a next state.
	process(all)
	begin
		RS       <= '0';
		DB       <= "0011";
		is_ready <= '0';
		
		case pr_state is
			when power_on_reset1 =>
				for i in 1 to 7 loop
					if    i < 7 then nx_state <= power_on_reset1;
					elsif i = 7 then nx_state <= power_on_reset8;
					end if;
				end loop;

			/*when power_on_reset1 => nx_state <= power_on_reset2;
			when power_on_reset2 => nx_state <= power_on_reset3;
			when power_on_reset3 => nx_state <= power_on_reset4;
			when power_on_reset4 => nx_state <= power_on_reset5;
			when power_on_reset5 => nx_state <= power_on_reset6;
			when power_on_reset6 => nx_state <= power_on_reset7;
			when power_on_reset7 => nx_state <= power_on_reset8;*/

			when power_on_reset8 => is_ready <= '1'; nx_state <= FunctionSet1;
			
			when FunctionSet1 => nx_state <= FunctionSet2;
			when FunctionSet2 => nx_state <= FunctionSet3;
			when FunctionSet3 => nx_state <= FunctionSet4;
			
			when FunctionSet4 => DB <= "0010"; nx_state <= FunctionSet5;
			when FunctionSet5 => DB <= "0010"; nx_state <= FunctionSet6;
			when FunctionSet6 => DB <= "1000"; nx_state <= ClearDisplay_H;
			
			when ClearDisplay_H => DB <= "0000"; nx_state <= ClearDisplay_L;
			when ClearDisplay_L => DB <= "0001"; nx_state <= DisplayCOntrol_H;
			
			when DisplayControl_H => DB <= "0000"; nx_state <= DisplayControl_L;
			when DisplayControl_L => DB <= "1100"; nx_state <= EntryMode_H;
			
			when EntryMode_H => DB <= "0000"; nx_state <= EntryMode_L;
			when EntryMode_L => DB <= "0110"; nx_state <= W_10M_H;

			when W_10M_H=>RS<='1';DB<=upper_4(bin_in(31 downto 28));nx_state<=W_10M_L;
			when W_10M_L=>RS<='1';DB<=lower_4(bin_in(31 downto 28));nx_state<=W_1M_H;

			when W_1M_H=>RS<='1';DB<=upper_4(bin_in(27 downto 24));nx_state<=W_1M_L;
			when W_1M_L=>RS<='1';DB<=lower_4(bin_in(27 downto 24));nx_state<=W_100k_H;

			when W_100k_H=>RS<='1';DB<=upper_4(bin_in(23 downto 20));nx_state<=W_100k_L;
			when W_100k_L=>RS<='1';DB<=lower_4(bin_in(23 downto 20));nx_state<=W_10k_H;

			when W_10k_H=>RS<='1';DB<=upper_4(bin_in(19 downto 16));nx_state<=W_10k_L;
			when W_10k_L=>RS<='1';DB<=lower_4(bin_in(19 downto 16));nx_state<=W_1k_H;

			when W_1k_H=>RS<='1';DB<=upper_4(bin_in(15 downto 12));nx_state<=W_1k_L;
			when W_1k_L=>RS<='1';DB<=lower_4(bin_in(15 downto 12));nx_state<=W_100_H;

			when W_100_H=>RS<='1';DB<=upper_4(bin_in(11 downto 8));nx_state<=W_100_L;
			when W_100_L=>RS<='1';DB<=lower_4(bin_in(11 downto 8));nx_state<=W_10_H;

			when W_10_H=>RS<='1';DB<=upper_4(bin_in(7 downto 4));nx_state<=W_10_L;
			when W_10_L=>RS<='1';DB<=lower_4(bin_in(7 downto 4));nx_state<=W_1_H;
				
			when W_1_H=>RS<='1';DB<=upper_4(bin_in(3 downto 0));nx_state<=W_1_L;
			when W_1_L=>RS<='1';DB<=lower_4(bin_in(3 downto 0));nx_state<=ReturnHome_H;

			when ReturnHome_H => DB <= "1000"; nx_state <= ReturnHome_L;
			when ReturnHome_L => DB <= "0000"; nx_state <= W_10M_H;
			
			when others => nx_state <= power_on_reset1;
		end case;
	end process;

end architecture;

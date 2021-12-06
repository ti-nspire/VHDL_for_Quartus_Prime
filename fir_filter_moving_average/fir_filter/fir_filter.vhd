--refer to https://forum.digikey.com/t/fir-filter-vhdl/12861

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package types is
	type coefficient_array is array (natural range <>) of std_logic_vector;  --array of all coefficients
	type data_array        is array (natural range <>) of signed;                    --array of historic data values
	type product_array     is array (natural range <>) of signed; --array of coefficient * data products
end package types;
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.types.all;

entity fir_filter is
	generic(
		TAPS        : integer := 10; --number of fir filter taps
		DATA_WIDTH  : integer := 10; --width of data input including sign bit
		COEFF_WIDTH : integer := 8 --width of coefficients including sign bit
	);
	port(
		clk          : in   std_logic;                                  --system clock
		aclr_n       : in   std_logic;                                  --active low asynchronous reset
		data         : in   std_logic_vector(DATA_WIDTH - 1 downto 0);    --data stream
		coefficients : in   coefficient_array(0 to TAPS - 1)(COEFF_WIDTH - 1 downto 0); --coefficient array
		result       : out  std_logic_vector(DATA_WIDTH + COEFF_WIDTH + integer(ceil(log2(real(TAPS)))) - 1 downto 0)  --filtered result
	);
end entity;

architecture rtl of fir_filter is
	signal coeff_int     : coefficient_array(0 to TAPS - 1)(COEFF_WIDTH - 1 downto 0); --array of latched in coefficient values
	signal data_pipeline : data_array(0 to TAPS - 1)(DATA_WIDTH-1 downto 0);        --pipeline of historic data values

	signal    products  : product_array(0 to TAPS - 1)(DATA_WIDTH + COEFF_WIDTH - 1 downto 0);     --array of coefficient*data products
	attribute multstyle : string;
	attribute multstyle of products : signal is "dsp";

begin

	process(clk, aclr_n)
		variable sum : signed(DATA_WIDTH + COEFF_WIDTH + integer(ceil(log2(real(TAPS)))) - 1 downto 0); --sum of products
	begin
	
		if not aclr_n then                                       --asynchronous reset
			data_pipeline <= (others => (others => '0'));                --clear data pipeline values
			coeff_int     <= (others => (others => '0'));                    --clear internal coefficient registers
			result        <= (others => '0');                                   --clear result output

		elsif rising_edge(clk) then                          --not reset
			coeff_int <= coefficients;                                   --input coefficients    
			data_pipeline <= signed(data) & data_pipeline(0 to TAPS - 2);  --shift new data into data pipeline

			sum := (others => '0');                                      --initialize sum
			for i in 0 to TAPS - 1 loop
				sum := sum + products(i);                                  --add the products
			end loop;
		  
			result <= std_logic_vector(sum);                             --output result
		end if;
	end process;
	
	--perform multiplies
	product_calc: for i in 0 to TAPS - 1 generate
		products(i) <= data_pipeline(i) * signed(coeff_int(i));
	end generate;
	
end architecture;

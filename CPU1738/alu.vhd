library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
	generic(
		NUM_BITS: natural := 4
	);
	port(
		a: in std_logic_vector(NUM_BITS-1 downto 0);
		b: in std_logic_vector(NUM_BITS-1 downto 0);
		
		mux_a: in std_logic;
		mux_b: in std_logic;

		as        : in std_logic; -- when 0, add; when 1, sub;
		ld        : in std_logic;
		clk_inside: in std_logic;
		aclr_n    : in std_logic;
	
		add_sub: out std_logic_vector(NUM_BITS-1 downto 0);
		zero   : out std_logic;
		cout   : out std_logic
	);
end entity;

architecture rtl of alu is
	signal a_temp   : unsigned(NUM_BITS-1 downto 0);
	signal b_temp   : unsigned(NUM_BITS-1 downto 0);
	signal calc_temp: unsigned(NUM_BITS   downto 0);
begin

	a_temp <=
		(others => '0') when mux_a = '0' else -- mux_aが0ならオペランドaを強制的に0にし、
		unsigned(a);

	b_temp <=
		(others => '0') when mux_b = '0' else -- mux_bが0ならオペランドbを強制的に0にし、
		0-unsigned(b)   when as    = '1' else -- 引き算のときはオペランドbを2の補数にし、
		unsigned(b);
	
	calc_temp <= ('0' & a_temp) + b_temp; -- 1ビット拡張して和(差)を計算して、

	process(clk_inside)
	begin
		
		if aclr_n = '0' then
			-- 非同期クリアして、
			add_sub <= (others => '0');
		else
			-- 和(差)を非同期更新して、
			add_sub <= std_logic_vector(calc_temp)(NUM_BITS-1 downto 0);
		
			if rising_edge(clk_inside) then
				if ld then
					-- キャリーアウトを同期更新して、
					cout <= calc_temp(NUM_BITS);

					-- ゼロフラグを同期更新する。
					if calc_temp(NUM_BITS-1 downto 0) = 0 then
						zero <= '1';
					else
						zero <= '0';
					end if;

				end if;
			end if;

		end if;
	end process;
end architecture;
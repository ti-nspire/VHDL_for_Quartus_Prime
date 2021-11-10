-- 参考: https://forum.digikey.com/t/spi-master-vhdl/12717

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.math_real.all;

entity spi_master is
	generic(
		NUM_SLAVES     : positive := 4;
		NUM_BITS       : positive := 8;
		MAX_DIV_FACTOR : positive := 100 --偶数で指定する。
	);
	port(
		clk       : in     std_logic;
		aclr_n    : in     std_logic;
		enable_sq : in     std_logic; --トランザクション開始命令
		cpol      : in     std_logic;
		cpha      : in     std_logic;
		cont      : in     std_logic; --連続モードコマンド
		clk_div   : in     positive range 2 to MAX_DIV_FACTOR ; --分周比。偶数で指定する。
		addr      : in     natural  range 0 to (NUM_SLAVES-1); --スレーブアドレス
		tx_data   : in     std_logic_vector(NUM_BITS-1 downto 0); --送信するデータ
		miso      : in     std_logic;
		sclk      : buffer std_logic;
		ss_n      : buffer std_logic_vector(NUM_SLAVES-1 downto 0); --!スレーブセレクト(ワンコールドステート)
		mosi      : out    std_logic;
		busy      : out    std_logic;                            --ビジー信号(データレディー信号)
		rx_data   : out    std_logic_vector(NUM_BITS-1 downto 0);  --受信したデータ
		
		enable_one_shot : out std_logic
	);
end entity;

architecture rtl of spi_master is
	type machine is (ready, execute);
	signal state : machine;

	signal slave       : natural;     --現在のトランザクションで選択されたスレーブ
	signal clk_ratio   : natural;                              --現在の分周比
	signal count       : natural;  --システムクロックからsclkをトリガーするためのカウンター
	signal clk_toggles : natural range 0 to NUM_BITS*2 + 1; -- spiクロックのトグルをカウントする
	signal assert_data : std_logic;                      --'1': tx sclkがトグル、'0': rx sclkがトグル
	signal continue    : std_logic;                            --トランザクションを継続するときのフラグ
	signal rx_buffer   : std_logic_vector(rx_data'range); --受信データバッファ
	signal tx_buffer   : std_logic_vector(tx_data'range); --送信データバッファ
	signal last_bit_rx : natural range 0 to NUM_BITS*2;         --最後の受信データビットの位置
begin
	module_one_shot : entity work.gen_one_shot
	port map(
		clk   => clk,
		p_in  => enable_sq,
		p_out => enable_one_shot
	);

	process(clk, aclr_n)
	begin

		if aclr_n = '0'  then
			busy    <= '1';
			ss_n    <= (others => '1');
			mosi    <= 'Z';
			rx_data <= (others => '0');
			state   <= ready;

		elsif rising_edge(clk) then
			case state is
			when ready =>
				busy     <= '0';
				ss_n     <= (others => '1');
				mosi     <= 'Z';
				continue <= '0';

				--トランザクションを開始
				if enable_one_shot then       

					if addr < NUM_SLAVES then   --スレーブアドレスが有効か確認
						slave <= addr;         --有効なら、クロックに同期して現在のスレーブを選択
					else
						slave <= 0;            --有効でないなら0番のスレーブを選択
					end if;
					if clk_div/2 = 0 then     --SPIクロック値が有効か確認
						clk_ratio <= 1;        --それが0なら最大周波数に設定
						count     <= 1;            --system-to-spiクロックカウンターを開始
					else
						clk_ratio <= clk_div/2;  --有効ならそれに応じてspiクロックを設定
						count     <= clk_div/2;      --system-to-spiクロックカウンターを開始
					end if;
					sclk        <= cpol;            --spiクロックの極性を設定
					assert_data <= not cpha; --spiクロックの位相を設定
					tx_buffer   <= tx_data;    --クロックに同期して送信データをバッファーに入れる
					clk_toggles <= 0;        --クロックトグルカウンターを開始

					if cpha = '1' then last_bit_rx <= NUM_BITS*2;
					else               last_bit_rx <= NUM_BITS*2 - 1;
					end if;
					
					state <= execute;
				else
					state <= ready;
				end if;
			when execute =>
				busy        <= '1';
				ss_n(slave) <= '0';

				--system clock to sclk ratio is met
				if count = clk_ratio then        
					count       <= 1;                     --reset system-to-spi clock counter
					assert_data <= not assert_data; --switch transmit/receive indicator
					if clk_toggles = NUM_BITS*2 + 1 then
						clk_toggles <= 0;               --reset spi clock toggles counter
					else
						clk_toggles <= clk_toggles + 1; --increment spi clock toggles counter
					end if;
					--spi clock toggle needed
					if (clk_toggles <= NUM_BITS*2) and (ss_n(slave) = '0') then 
						sclk <= not sclk; --toggle spi clock
					end if;
					--receive spi clock toggle
					if (assert_data = '0') and (clk_toggles < last_bit_rx + 1) and (ss_n(slave) = '0') then 
						rx_buffer <= rx_buffer(NUM_BITS-2 downto 0) & miso; --shift in received bit
					end if;
					--transmit spi clock toggle
					if (assert_data = '1') and (clk_toggles < last_bit_rx) then 
						mosi      <= tx_buffer(NUM_BITS-1);                     --clock out data bit
						tx_buffer <= tx_buffer(NUM_BITS-2 downto 0) & '0'; --shift data transmit buffer
					end if;
					--last data receive, but continue
					if (clk_toggles = last_bit_rx) and (cont = '1') then 
						tx_buffer   <= tx_data;                     --reload transmit buffer
						clk_toggles <= last_bit_rx - NUM_BITS*2 + 1; --reset spi clock toggle counter
						continue    <= '1';                         --set continue flag
					end if;
					--normal end of transaction, but continue
					if continue then  
						continue <= '0';       --clear continue flag
						busy     <= '0';       --clock out signal that first receive data is ready
						rx_data  <= rx_buffer; --clock out received data to output port    
					end if;
					--end of transaction
					if (clk_toggles = NUM_BITS*2 + 1) and (cont = '0') then   
						busy    <= '0';             --clock out not busy signal
						ss_n    <= (others => '1'); --set all slave selects high
						mosi    <= 'Z';             --set mosi output high impedance
						rx_data <= rx_buffer;       --clock out received data to output port
						state   <= ready;           --return to ready state
					else                            --not end of transaction
						state <= execute;           --remain in execute state
					end if;
				else        --system clock to sclk ratio not met
					count <= count + 1; --increment counter
					state <= execute;   --remain in execute state
				end if;
			end case;
		end if;
	end process; 
end architecture;

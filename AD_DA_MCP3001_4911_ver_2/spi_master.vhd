-- 参考: https://forum.digikey.com/t/spi-master-vhdl/12717

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.math_real.all;

entity spi_master is
	generic(
		NUM_SLAVES     : positive := 4;
		NUM_BITS       : positive := 8;
		DIV_FACTOR_MAX : positive := 100 --偶数で指定する。
	);
	port(
		clk     : in     std_logic;
		aclr_n  : in     std_logic;
		enable  : in     std_logic; --トランザクション開始命令
		cpol    : in     std_logic;
		cpha    : in     std_logic;
		cont    : in     std_logic; --連続モードコマンド
		clk_div : in     positive range 2 to DIV_FACTOR_MAX ; --分周比。偶数で指定する。
		addr    : in     natural  range 0 to (NUM_SLAVES - 1); --スレーブアドレス
		tx_data : in     std_logic_vector(NUM_BITS - 1 downto 0); --送信するデータ
		miso    : in     std_logic;
		sclk    : buffer std_logic;
		ss_n    : buffer std_logic_vector(NUM_SLAVES - 1 downto 0); --!スレーブセレクト(ワンコールドステート)
		mosi    : out    std_logic;
		busy    : out    std_logic;                            --ビジー信号(データレディー信号)
		rx_data : out    std_logic_vector(NUM_BITS - 1 downto 0)  --受信したデータ
		
		
	);
end entity;

architecture rtl of spi_master is
	type machine is (ready, execute);
	signal state : machine;

	signal slave       : natural;     --現在のトランザクションで選択されたスレーブ
	signal clk_ratio   : natural;                              --現在の分周比
	signal count       : natural;  --システムクロックからsclkをトリガーするためのカウンター
	signal clk_toggles : natural range 0 to NUM_BITS * 2 + 1; -- spiクロックのトグルをカウントする
	signal assert_data : std_logic;                      --'1': tx sclkがトグル、'0': rx sclkがトグル
	signal continue    : std_logic;                            --トランザクションを継続するときのフラグ
	signal rx_buffer   : std_logic_vector(rx_data'range); --受信データバッファ
	signal tx_buffer   : std_logic_vector(tx_data'range); --送信データバッファ
	signal last_bit_rx : natural range 0 to NUM_BITS * 2;         --最後の受信データビットの位置
begin
	

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
				if enable then       

					if addr < NUM_SLAVES then   --スレーブアドレスが有効か確認
						slave <= addr;         --有効なら、クロックに同期して現在のスレーブを選択
					else
						slave <= 0;            --有効でないなら0番のスレーブを選択
					end if;
					if clk_div / 2 = 0 then     --SPIクロック値が有効か確認
						clk_ratio <= 1;        --それが0なら最大周波数に設定
						count     <= 1;            --system-to-spiクロックカウンターを開始
					else
						clk_ratio <= clk_div / 2;  --有効ならそれに応じてspiクロックを設定
						count     <= clk_div / 2;      --system-to-spiクロックカウンターを開始
					end if;
					sclk        <= cpol;            --spiクロックの極性を設定
					assert_data <= not cpha; --spiクロックの位相を設定
					tx_buffer   <= tx_data;    --クロックに同期して送信データをバッファーに入れる
					clk_toggles <= 0;        --クロックトグルカウンターを開始

					if cpha = '1' then last_bit_rx <= NUM_BITS * 2;
					else               last_bit_rx <= NUM_BITS * 2 - 1;
					end if;
					
					state <= execute;
				else
					state <= ready;
				end if;
			when execute =>
				busy        <= '1';
				ss_n(slave) <= '0';

				--システムクロック対sclk比が一致したら
				if count = clk_ratio then        
					count       <= 1;                     --system-to-spiクロックカウンターをリセット
					assert_data <= not assert_data; --送信/受信インジケーターを切り換え
					if clk_toggles = NUM_BITS * 2 + 1 then
						clk_toggles <= 0;               --spiクロックトグルカウンターをリセット
					else
						clk_toggles <= clk_toggles + 1; --spiクロックトグルカウンターをインクリメント
					end if;
					--spiクロックのトグルが必要な場合は
					if (clk_toggles <= NUM_BITS * 2) and (ss_n(slave) = '0') then 
						sclk <= not sclk; --spi clockをトグル
					end if;
					--クロックトグルを受信したら
					if (assert_data = '0') and (clk_toggles < last_bit_rx + 1) and (ss_n(slave) = '0') then
						rx_buffer <= rx_buffer(NUM_BITS-2 downto 0) & miso; --受信したビットをシフトインして
					end if;
					--spiクロックトグルを送信する場合は
					if (assert_data = '1') and (clk_toggles < last_bit_rx) then 
						mosi      <= tx_buffer(NUM_BITS - 1);                     --データビットをクロックアウトして
						tx_buffer <= tx_buffer(NUM_BITS - 2 downto 0) & '0'; --データ送信バッファをシフトして
					end if;
					--最後のデータを受信したがまだ続ける場合は
					if (clk_toggles = last_bit_rx) and (cont = '1') then 
						tx_buffer   <= tx_data;                     --送信バッファーをリロードして
						clk_toggles <= last_bit_rx - NUM_BITS * 2 + 1; --spiクロックトグルカウンターをリセットして
						continue    <= '1';                         --継続フラグをセットして
					end if;
					--トランザクションが通常どおり終了したがまだ続ける場合は
					if continue then  
						continue <= '0';       --継続フラグをクリアして
						busy     <= '0';       --clock out signal that first receive data is ready
						rx_data  <= rx_buffer; --clock out received data to output port    
					end if;
					--end of transaction
					if (clk_toggles = NUM_BITS * 2 + 1) and (cont = '0') then   
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity fifo_counter is port(
	signal add_dram_fifo_cnt : in std_logic;
	signal sub_dram_fifo_cnt : in std_logic;
	signal add_data_fifo_cnt : in std_logic;
	signal sub_data_fifo_cnt : in std_logic;
	signal add_dram_wpage : in std_logic;
	signal add_dram_rpage : in std_logic;
	signal add_dram_cnt : in std_logic;
	signal sub_dram_cnt : in std_logic;
	signal latch_data_size : in std_logic;
	signal reset : in std_logic;
	signal reset_dram : in std_logic;
	signal clk : in std_logic;
	signal clk_dram : in std_logic;
	signal daq_busy: out std_logic;
	signal dram_fifo_empty : out std_logic;
	signal data_fifo_full : out std_logic;									
	signal data_fifo_empty : out std_logic;									
	signal dram_wpage : out std_logic_vector(16 downto 0);
	signal dram_rpage : out std_logic_vector(16 downto 0);
	signal dram_full : out std_logic;
	signal dram_empty : out std_logic;										
	signal data_size : out std_logic_vector(12 downto 0)
); end fifo_counter;

architecture Behavioral of fifo_counter is

component one_shot_inter_clock port(
	signal wsig : in std_logic;
	signal wclk : in std_logic;
	signal rclk : in std_logic;
	signal rsig : out std_logic
); end component;

signal dram_fifo_empty_reg : std_logic;
signal data_fifo_full_reg : std_logic;									
signal data_fifo_empty_reg : std_logic;									
signal dram_wpage_reg : std_logic_vector(16 downto 0);
signal dram_rpage_reg : std_logic_vector(16 downto 0);
signal dram_full_reg : std_logic;
signal dram_empty_reg : std_logic;										
signal data_size_reg : std_logic_vector(12 downto 0);

signal sub_dram_fifo_cnt_clk : std_logic;
signal add_data_fifo_cnt_clk : std_logic;
signal dram_fifo_cnt : std_logic_vector(6 downto 0);
signal idram_fifo_cnt : std_logic_vector(6 downto 0);
signal p2dram_fifo_empty : std_logic;
signal pdram_fifo_empty : std_logic;
signal dreset_dram : std_logic;
signal reset_fifo_cnt : std_logic;
signal cen_dram_cnt : std_logic;
signal dadd_dram_cnt : std_logic;
signal dram_size : std_logic_vector(17 downto 0);
signal data_fifo_cnt : std_logic_vector(4 downto 0);
signal idata_fifo_cnt : std_logic_vector(4 downto 0);
signal ddram_size : std_logic_vector(17 downto 0);
signal pdata_fifo_full : std_logic;
signal idata_cnt : std_logic_vector(17 downto 0);
signal data_cnt : std_logic_vector(12 downto 0);

begin

	osic_sub_dram_fifo_cnt_clk : one_shot_inter_clock port map(
		wsig => sub_dram_fifo_cnt,
		wclk => clk_dram,
		rclk => clk,
		rsig => sub_dram_fifo_cnt_clk
	);

	osic_add_data_fifo_cnt_clk : one_shot_inter_clock port map(
		wsig => add_data_fifo_cnt,
		wclk => clk_dram,
		rclk => clk,
		rsig => add_data_fifo_cnt_clk
	);

	process(clk) begin
	if (clk'event and clk = '1') then

		if (reset = '1') then
			dram_fifo_cnt <= (others => '0');
		else
			dram_fifo_cnt <= dram_fifo_cnt + idram_fifo_cnt;
		end if;
		
		p2dram_fifo_empty <= (not dram_fifo_cnt(6)) and (not dram_fifo_cnt(5)) 
		                 and (not dram_fifo_cnt(4)) and (not dram_fifo_cnt(3)) 
							  and (not dram_fifo_cnt(2)) and (not dram_fifo_cnt(1))
                       and (not dram_fifo_cnt(0));

		if (reset = '1') then
			data_fifo_cnt <= (others => '0');
		else
			data_fifo_cnt <= data_fifo_cnt + idata_fifo_cnt;
		end if;

		data_fifo_empty_reg <= (not data_fifo_cnt(4)) and (not data_fifo_cnt(3));

		ddram_size <= dram_size;
		
		data_cnt <= idata_cnt(17 downto 5);
		
		if (latch_data_size = '1') then
			data_size_reg <= data_cnt;
		end if;
		
	end if;
	end process;
	
	idram_fifo_cnt(0) <= sub_dram_fifo_cnt_clk;
	idram_fifo_cnt(1) <= sub_dram_fifo_cnt_clk;
	idram_fifo_cnt(2) <= sub_dram_fifo_cnt_clk;
	idram_fifo_cnt(3) <= sub_dram_fifo_cnt_clk;
	idram_fifo_cnt(4) <= sub_dram_fifo_cnt_clk;
	idram_fifo_cnt(5) <= sub_dram_fifo_cnt_clk or add_dram_fifo_cnt;
	idram_fifo_cnt(6) <= sub_dram_fifo_cnt_clk and (not add_dram_fifo_cnt);
	
	idata_fifo_cnt(0) <= add_data_fifo_cnt_clk;
	idata_fifo_cnt(1) <= '0';
	idata_fifo_cnt(2) <= '0';
	idata_fifo_cnt(3) <= sub_data_fifo_cnt;
	idata_fifo_cnt(4) <= sub_data_fifo_cnt;

	idata_cnt <= ddram_size + ("0000000000000" & data_fifo_cnt);

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then

		pdram_fifo_empty <= p2dram_fifo_empty;
		dram_fifo_empty_reg <= pdram_fifo_empty;
		
		if (dreset_dram = '1') then
			reset_fifo_cnt <= '0';
		elsif (reset_dram = '1') then
			reset_fifo_cnt <= '1';
		end if;

		if (reset_fifo_cnt = '1') then
			dram_wpage_reg <= (others => '0');
		elsif (add_dram_wpage = '1') then
			dram_wpage_reg <= dram_wpage_reg + 1;
		end if;

		if (reset_fifo_cnt = '1') then
			dram_rpage_reg <= (others => '0');
		elsif (add_dram_rpage = '1') then
			dram_rpage_reg <= dram_rpage_reg + 1;
		end if;

		cen_dram_cnt <= add_dram_cnt xor sub_dram_cnt;
		dadd_dram_cnt <= add_dram_cnt;
		
		if (reset_fifo_cnt = '1') then
			dram_size <= (others => '0');
		elsif (cen_dram_cnt = '1') then
			if (dadd_dram_cnt = '1') then
				dram_size <= dram_size + 1;
			else
				dram_size <= dram_size - 1;
			end if;
		end if;

		dram_full_reg <= dram_size(17);

		dram_empty_reg <= (not dram_size(17)) and (not dram_size(16)) and (not dram_size(15)) 
		              and (not dram_size(14)) and (not dram_size(13)) and (not dram_size(12))
		              and (not dram_size(11)) and (not dram_size(10)) and (not dram_size(9)) 
						  and (not dram_size(8)) and (not dram_size(7)) and (not dram_size(6)) 
						  and (not dram_size(5)) and (not dram_size(4)) and (not dram_size(3)) 
						  and (not dram_size(2)) and (not dram_size(1)) and (not dram_size(0));
						  
		pdata_fifo_full <= data_fifo_cnt(4);
		data_fifo_full_reg <= pdata_fifo_full;

	end if;
	end process;

	srl16e_dreset_dram : SRL16E
	generic map(INIT => x"0000")
	port map(
		d => reset_dram,
		a0 => '1',
		a1 => '1',
		a2 => '1',
		a3 => '1',
		ce => '1',
		clk => clk_dram,
		q => dreset_dram
	);
	
	daq_busy <= dram_fifo_cnt(6);
	dram_fifo_empty <= dram_fifo_empty_reg;
	data_fifo_full <= data_fifo_full_reg;
	data_fifo_empty <= data_fifo_empty_reg;
	dram_wpage <= dram_wpage_reg;
	dram_rpage <= dram_rpage_reg;
	dram_full <= dram_full_reg;
	dram_empty <= dram_empty_reg;
	data_size <= data_size_reg;

end Behavioral;

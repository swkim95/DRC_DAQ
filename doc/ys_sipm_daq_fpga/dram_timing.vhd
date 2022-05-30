library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_timing is port(
	signal dram_enable : in std_logic;
	signal dram_stop : in std_logic;
	signal dram_fifo_empty : in std_logic;
	signal data_fifo_full : in std_logic;
	signal dram_full : in std_logic;
	signal dram_empty : in std_logic;
	signal dram_test_wr : in std_logic;
	signal dram_test_rd : in std_logic;
	signal dram_test_on : in std_logic;
	signal clk_dram : in std_logic;
	signal write_dram : out std_logic;
	signal read_dram : out std_logic;
	signal refresh_dram : out std_logic;
	signal dram_ready : out std_logic
); end dram_timing;

architecture Behavioral of dram_timing is

signal write_dram_reg : std_logic;
signal read_dram_reg : std_logic;
signal refresh_dram_reg : std_logic;
signal dram_ready_reg : std_logic;

signal dram_cyc : std_logic;
signal rwcyc_start : std_logic;
signal fcyc_start : std_logic;
signal refresh_cnt : std_logic_vector(10 downto 0);
signal en_test_wr : std_logic;
signal en_test_rd : std_logic;
signal rwcyc_cen : std_logic;
signal rwcyc_cnt : std_logic_vector(8 downto 0);
signal rwcyc_clr : std_logic;
signal fcyc_cen : std_logic;
signal fcyc_cnt : std_logic_vector(5 downto 0);
signal fcyc_clr : std_logic;

begin

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then

		if (dram_stop = '1') then
			dram_ready_reg <= '0';
		elsif (dram_enable = '1') then
			dram_ready_reg <= '1';
		end if;

		rwcyc_start <= (dram_enable and (not dram_ready_reg)) or (fcyc_clr and dram_ready_reg);
		
		fcyc_start <= rwcyc_clr and dram_ready_reg;
		
		if (dram_ready_reg = '0') then
			dram_cyc <= '0';
		elsif (rwcyc_clr = '1') then
			dram_cyc <= not dram_cyc;
		end if;
		
		if (dram_ready_reg = '0') then
			refresh_cnt <= (others => '0');
		elsif (refresh_dram_reg = '1') then
			refresh_cnt <= (others => '0');
		else
			refresh_cnt <= refresh_cnt + 1;
		end if;
		 
		if (write_dram_reg = '1') then
			en_test_wr <= '0';
		elsif (dram_test_wr = '1') then
			en_test_wr <= dram_test_on;
		end if;
		
		if (read_dram_reg = '1') then
			en_test_rd <= '0';
		elsif (dram_test_rd = '1') then
			en_test_rd <= dram_test_on;
		end if;

		if (dram_ready_reg = '0') then
			rwcyc_cen <= '0';
		elsif (rwcyc_clr = '1') then
			rwcyc_cen <= '0';
		elsif (rwcyc_start = '1') then
			rwcyc_cen <= '1';
		end if;
		
		if (dram_ready_reg = '0') then
			rwcyc_cnt <= (others => '0');
		elsif (rwcyc_clr = '1') then
			rwcyc_cnt <= (others => '0');
		elsif (rwcyc_cen = '1') then
			rwcyc_cnt <= rwcyc_cnt + 1;
		end if;
		
		rwcyc_clr <= ((dram_full or dram_fifo_empty) and rwcyc_start and (not dram_cyc) and (not dram_test_on))
		          or ((data_fifo_full or dram_empty) and rwcyc_start and dram_cyc and (not dram_test_on))
		          or (rwcyc_cnt(8) and (not rwcyc_cnt(7)) and (not rwcyc_cnt(6))
					 and (not rwcyc_cnt(5)) and (not rwcyc_cnt(4)) and rwcyc_cnt(3)
					 and (not rwcyc_cnt(2)) and rwcyc_cnt(1) and rwcyc_cnt(0));

		if (dram_ready_reg = '0') then
			fcyc_cen <= '0';
		elsif (fcyc_clr = '1') then
			fcyc_cen <= '0';
		elsif (fcyc_start = '1') then
			fcyc_cen <= '1';
		end if;
		
		if (dram_ready_reg = '0') then
			fcyc_cnt <= (others => '0');
		elsif (fcyc_clr = '1') then
			fcyc_cnt <= (others => '0');
		elsif (fcyc_cen = '1') then
			fcyc_cnt <= fcyc_cnt + 1;
		end if;
		
		fcyc_clr <= (fcyc_start and (not refresh_cnt(10)))
		          or (fcyc_cnt(5) and (not fcyc_cnt(4)) and fcyc_cnt(3) 
					 and (not fcyc_cnt(2)) and (not fcyc_cnt(1)) and fcyc_cnt(0));
		
		write_dram_reg <= rwcyc_start and (not dram_cyc) 
		              and (((not dram_full) and (not dram_fifo_empty) and (not dram_test_on))
		                or (en_test_wr and dram_test_on));

		read_dram_reg <= rwcyc_start and dram_cyc 
		             and (((not data_fifo_full) and (not dram_empty) and (not dram_test_on))
		               or (en_test_rd and dram_test_on));
							 
		refresh_dram_reg <= fcyc_start and refresh_cnt(10);

	end if;
	end process;
	
	write_dram <= write_dram_reg;
	read_dram <= read_dram_reg;
	refresh_dram <= refresh_dram_reg;
	dram_ready <= dram_ready_reg;

end Behavioral;


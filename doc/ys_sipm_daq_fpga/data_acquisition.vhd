library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity data_acquisition is port(
	signal drs_fifo_rdata : in adc_data_array;
	signal run_number : in std_logic_vector(15 downto 0);
	signal local_ctime : in std_logic_vector(47 downto 0);
	signal local_ftime : in std_logic_vector(6 downto 0);
	signal trig_type : in std_logic_vector(1 downto 0);
	signal trig_number : in std_logic_vector(31 downto 0);
	signal trig_ctime : in std_logic_vector(47 downto 0);
	signal trig_ftime : in std_logic_vector(6 downto 0);
	signal mod_mid : in std_logic_vector(7 downto 0);
	signal trig_pattern : in std_logic_vector(31 downto 0);
	signal triged : in std_logic;
	signal drs_stop_addr : in std_logic_vector(9 downto 0);
	signal drs_read_end : in std_logic;
	signal add_dram_wpage : in std_logic;
	signal add_dram_rpage : in std_logic;
	signal add_dram_cnt : in std_logic;
	signal sub_dram_cnt : in std_logic;
	signal sub_dram_fifo_cnt : in std_logic;
	signal add_data_fifo_cnt : in std_logic;
	signal sub_data_fifo_cnt : in std_logic;
	signal latch_data_size : in std_logic;
	signal drs_calib : in std_logic;
	signal drs_on : in std_logic;
	signal start : in std_logic;
	signal stop : in std_logic;
	signal reset : in std_logic;
	signal reset_dram : in std_logic;
	signal clk : in std_logic;
	signal clk_dram : in std_logic;
	signal run : out std_logic;
	signal trig_armed : out std_logic;
	signal drs_fifo_raddr : out std_logic_vector(9 downto 0);
	signal dram_fifo_wdata : out std_logic_vector(511 downto 0);
	signal dram_fifo_waddr : out std_logic_vector(10 downto 0);
	signal dram_fifo_write : out std_logic;
	signal dram_wpage : out std_logic_vector(16 downto 0);
	signal dram_rpage : out std_logic_vector(16 downto 0);
	signal daq_busy : out std_logic;
	signal dram_fifo_empty : out std_logic;
	signal dram_full : out std_logic;
	signal dram_empty : out std_logic;										
	signal data_fifo_full : out std_logic;									
	signal data_fifo_empty : out std_logic;									
	signal data_size : out std_logic_vector(12 downto 0)
); end data_acquisition;

architecture Behavioral of data_acquisition is

component daq_control port(
	signal drs_fifo_rdata : in adc_data_array;
	signal run_number : in std_logic_vector(15 downto 0);
	signal local_ctime : in std_logic_vector(47 downto 0);
	signal local_ftime : in std_logic_vector(6 downto 0);
	signal trig_type : in std_logic_vector(1 downto 0);
	signal trig_number : in std_logic_vector(31 downto 0);
	signal trig_ctime : in std_logic_vector(47 downto 0);
	signal trig_ftime : in std_logic_vector(6 downto 0);
	signal mod_mid : in std_logic_vector(7 downto 0);
	signal trig_pattern : in std_logic_vector(31 downto 0);
	signal triged : in std_logic;
	signal drs_stop_addr : in std_logic_vector(9 downto 0);
	signal drs_read_end : in std_logic;
	signal drs_calib : in std_logic;
	signal drs_on : in std_logic;
	signal start : in std_logic;
	signal stop : in std_logic;
	signal reset : in std_logic;
	signal clk : in std_logic;
	signal run : out std_logic;
	signal trig_armed : out std_logic;
	signal drs_fifo_raddr : out std_logic_vector(9 downto 0);
	signal dram_fifo_wdata : out std_logic_vector(511 downto 0);
	signal dram_fifo_waddr : out std_logic_vector(10 downto 0);
	signal dram_fifo_write : out std_logic;
	signal add_dram_fifo_cnt : out std_logic
); end component;

signal add_dram_fifo_cnt : std_logic;

component fifo_counter port(
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
	signal daq_busy : out std_logic;
	signal dram_fifo_empty : out std_logic;
	signal data_fifo_full : out std_logic;									
	signal data_fifo_empty : out std_logic;									
	signal dram_wpage : out std_logic_vector(16 downto 0);
	signal dram_rpage : out std_logic_vector(16 downto 0);
	signal dram_full : out std_logic;
	signal dram_empty : out std_logic;										
	signal data_size : out std_logic_vector(12 downto 0)
); end component;

begin

	u1 : daq_control port map(
		drs_fifo_rdata => drs_fifo_rdata,
		run_number => run_number,
		local_ctime => local_ctime,
		local_ftime => local_ftime,
		trig_type => trig_type,
		trig_number => trig_number,
		trig_ctime => trig_ctime,
		trig_ftime => trig_ftime,
		mod_mid => mod_mid,
		trig_pattern => trig_pattern,
		triged => triged,
		drs_stop_addr => drs_stop_addr,
		drs_read_end => drs_read_end,
		drs_calib => drs_calib,
		drs_on => drs_on,
		start => start,
		stop => stop,
		reset => reset,
		clk => clk,
		run => run,
		trig_armed => trig_armed,
		drs_fifo_raddr => drs_fifo_raddr,
		dram_fifo_wdata => dram_fifo_wdata,
		dram_fifo_waddr => dram_fifo_waddr,
		dram_fifo_write => dram_fifo_write,
		add_dram_fifo_cnt => add_dram_fifo_cnt
	); 

	u2 : fifo_counter port map(
		add_dram_fifo_cnt => add_dram_fifo_cnt,
		sub_dram_fifo_cnt => sub_dram_fifo_cnt,
		add_data_fifo_cnt => add_data_fifo_cnt,
		sub_data_fifo_cnt => sub_data_fifo_cnt,
		add_dram_wpage => add_dram_wpage,
		add_dram_rpage => add_dram_rpage,
		add_dram_cnt => add_dram_cnt,
		sub_dram_cnt => sub_dram_cnt,
		latch_data_size => latch_data_size,
		reset => reset,
		reset_dram => reset_dram,
		clk => clk,
		clk_dram => clk_dram,
		daq_busy => daq_busy,
		dram_fifo_empty => dram_fifo_empty,
		data_fifo_full => data_fifo_full,
		data_fifo_empty => data_fifo_empty,
		dram_wpage => dram_wpage,
		dram_rpage => dram_rpage,
		dram_full => dram_full,
		dram_empty => dram_empty,
		data_size => data_size
	); 

end Behavioral;


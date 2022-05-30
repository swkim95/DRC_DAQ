library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity ys_sipm_daq_fpga is port(
--	signal p_mgt_def : in std_logic;
--	signal p_mgt_los : in std_logic;
--	signal p_mgt_txdis : out std_logic;
--	signal p_mgt_txp : out std_logic;
--	signal p_mgt_txn : out std_logic;
--	signal p_mgt_rxp : in std_logic;
--	signal p_mgt_rxn : in std_logic;
	signal p_tcb_clkp : in std_logic;
	signal p_tcb_clkn : in std_logic;
	signal p_tcb_timerp : in std_logic;
	signal p_tcb_timern : in std_logic;
	signal p_tcb_trigp : in std_logic;
	signal p_tcb_trign : in std_logic;
	signal p_adc_trigp : out std_logic;
	signal p_adc_trign : out std_logic;
	signal p_adc_dp : in std_logic_vector(31 downto 0);
	signal p_adc_dn : in std_logic_vector(31 downto 0);
	signal p_adc_clkp : out std_logic_vector(3 downto 0);
	signal p_adc_clkn : out std_logic_vector(3 downto 0);
	signal p_adc_cs : out std_logic_vector(3 downto 0);
	signal p_adc_sck : out std_logic_vector(3 downto 0);
	signal p_adc_sdi : out std_logic_vector(3 downto 0);
	signal p_drs_pll_lock : in std_logic_vector(3 downto 0);
	signal p_drs_clkp : out std_logic_vector(3 downto 0);
	signal p_drs_clkn : out std_logic_vector(3 downto 0);
	signal p_drs_enable : out std_logic_vector(3 downto 0);
	signal p_drs_dwrite : out std_logic_vector(3 downto 0);
	signal p_drs_rsrload : out std_logic_vector(3 downto 0);
	signal p_drs_srclk : out std_logic_vector(3 downto 0);
	signal p_drs_srin : out std_logic_vector(3 downto 0);
--	signal p_drs_srout : in std_logic_vector(3 downto 0);
	signal p_drs_srout : in std_logic;
	signal p_drs_a : out drs_a_array;
	signal p_disc : in std_logic_vector(31 downto 0);
	signal p_temp_scl : out std_logic;
	signal p_temp_sda : inout std_logic;
	signal p_cpld_cs : out std_logic;
	signal p_cpld_sck : out std_logic;
	signal p_cpld_sdi : out std_logic;
	signal p_usb_d : inout std_logic_vector(31 downto 0);
	signal p_usb_cs : out std_logic;
	signal p_usb_wr : out std_logic;
	signal p_usb_oe : out std_logic;
	signal p_usb_rd : out std_logic;
	signal p_usb_rflag : in std_logic_vector(1 downto 0);
	signal p_usb_wflag : in std_logic;
	signal p_usb_pktend : out std_logic;
	signal p_usb_on : in std_logic;
	signal p_mid_sel : in std_logic;
	signal p_mid_sck : in std_logic;
	signal p_mid_sdi : in std_logic;
	signal p_usb_a : out std_logic_vector(1 downto 0);
	signal p_usb_pclk : out std_logic;
	signal p_dram_d : inout std_logic_vector(15 downto 0);
	signal p_dram_dsp : out std_logic_vector(1 downto 0);
	signal p_dram_dsn : out std_logic_vector(1 downto 0);
	signal p_dram_a : out std_logic_vector(13 downto 0);
	signal p_dram_ba : out std_logic_vector(2 downto 0);
	signal p_dram_cs : out std_logic;
	signal p_dram_ras : out std_logic;
	signal p_dram_cas : out std_logic;
	signal p_dram_we : out std_logic;
	signal p_dram_clke : out std_logic;
	signal p_dram_clkp : out std_logic;
	signal p_dram_clkn : out std_logic;
	signal p_dram_odt : out std_logic;
	signal p_dram_reset : out std_logic
); end ys_sipm_daq_fpga;

architecture Behavioral of ys_sipm_daq_fpga is

component clocks port(
	signal p_tcb_clkp : in std_logic;
	signal p_tcb_clkn : in std_logic;
	signal reset_refclk : in std_logic;
	signal x2clk : out std_logic;
	signal clk : out std_logic;
	signal x2clk_dram : out std_logic;
	signal x2clk90_dram : out std_logic;
	signal clk_dram : out std_logic;
	signal clk45_dram : out std_logic;
	signal reset_serdes_md : out std_logic;
	signal reset_serdes_mds : out std_logic;
	signal p_usb_pclk : out std_logic;
	signal p_dram_clkp : out std_logic;
	signal p_dram_clkn : out std_logic
); end component;

signal x2clk : std_logic;
signal clk : std_logic;
signal x2clk_dram : std_logic;
signal x2clk90_dram : std_logic;
signal clk_dram : std_logic;
signal clk45_dram : std_logic;
signal reset_serdes_md : std_logic;
signal reset_serdes_mds : std_logic;

component tcb_link port(
	signal p_tcb_timerp : in std_logic;
	signal p_tcb_timern : in std_logic;
	signal p_tcb_trigp : in std_logic;
	signal p_tcb_trign : in std_logic;
	signal run : in std_logic;
	signal link_enable : in std_logic;
	signal mod_mid : in std_logic_vector(7 downto 0);
	signal trig_nhit : in std_logic_vector(5 downto 0);
	signal local_trig : in std_logic;
	signal reg_rdata : in std_logic_vector(31 downto 0);
	signal daq_busy : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal adc_en : out std_logic;
	signal run_number : out std_logic_vector(15 downto 0);
	signal local_ctime : out std_logic_vector(47 downto 0);
	signal local_ftime : out std_logic_vector(6 downto 0);
	signal trig_type : out std_logic_vector(1 downto 0);
	signal trig_number : out std_logic_vector(31 downto 0);
	signal trig_ctime : out std_logic_vector(47 downto 0);
	signal trig_ftime : out std_logic_vector(6 downto 0);
	signal triged : out std_logic;
	signal command : out std_logic_vector(5 downto 1);
	signal sendcom : out std_logic;
	signal reg_wch : out std_logic_vector(4 downto 0);
	signal reg_waddr : out std_logic_vector(5 downto 0);
	signal reg_wdata : out std_logic_vector(27 downto 0);
	signal reg_wr : out std_logic;
	signal reg_rch : out std_logic_vector(4 downto 0);
	signal reg_raddr : out std_logic_vector(4 downto 0);
	signal reg_latch : out std_logic;
	signal p_adc_clkp : out std_logic_vector(3 downto 0);
	signal p_adc_clkn : out std_logic_vector(3 downto 0);
	signal p_drs_clkp : out std_logic_vector(3 downto 0);
	signal p_drs_clkn : out std_logic_vector(3 downto 0);
	signal p_adc_trigp : out std_logic;
	signal p_adc_trign : out std_logic
); end component;

signal adc_en : std_logic;
signal run_number : std_logic_vector(15 downto 0);
signal local_ctime : std_logic_vector(47 downto 0);
signal local_ftime : std_logic_vector(6 downto 0);
signal trig_type : std_logic_vector(1 downto 0);
signal trig_number : std_logic_vector(31 downto 0);
signal trig_ctime : std_logic_vector(47 downto 0);
signal trig_ftime : std_logic_vector(6 downto 0);
signal triged : std_logic;
signal command : std_logic_vector(5 downto 1);
signal sendcom : std_logic;
signal reg_wch : std_logic_vector(4 downto 0);
signal reg_waddr : std_logic_vector(5 downto 0);
signal reg_wdata : std_logic_vector(27 downto 0);
signal reg_wr : std_logic;
signal reg_rch : std_logic_vector(4 downto 0);
signal reg_raddr : std_logic_vector(4 downto 0);
signal reg_latch : std_logic;

component download_mid port(
	signal p_mid_sel : in std_logic;
	signal p_mid_sck : in std_logic;
	signal p_mid_sdi : in std_logic;
	signal clk : in std_logic;
	signal mod_mid : out std_logic_vector(7 downto 0);
	signal link_enable : out std_logic;
	signal cal_wen : out std_logic;
	signal cal_sck : out std_logic;
	signal cal_sdi : out std_logic
); end component;

signal mod_mid : std_logic_vector(7 downto 0);
signal link_enable : std_logic;
signal cal_wen : std_logic;
signal cal_sck : std_logic;
signal cal_sdi : std_logic;

component cpld_spi_ctrl port(
	signal hv_data : in hv_data_array;
	signal hv_write : in std_logic_vector(3 downto 0);
	signal thr_data : in thr_data_array;
	signal thr_write : in std_logic_vector(31 downto 0);
	signal drs_rofs : in std_logic_vector(11 downto 0);
	signal drs_oofs : in std_logic_vector(11 downto 0);
	signal dac_ofs_write : in std_logic;
	signal clk : in std_logic;
	signal p_cpld_cs : out std_logic;
	signal p_cpld_sck : out std_logic;
	signal p_cpld_sdi : out std_logic
); end component;

component temperature_monitor port(
	signal p_temp_sda : inout std_logic;
	signal latch_temp : in std_logic;
	signal clk : in std_logic;
	signal temp_data : out std_logic_vector(11 downto 0);
	signal p_temp_scl : out std_logic
); end component;

signal temp_data : std_logic_vector(11 downto 0);

component adc_setup port(
	signal adc_saddr : in std_logic_vector(7 downto 0);
	signal adc_sdata : in std_logic_vector(7 downto 0);
	signal adc_write : in std_logic;
	signal clk : in std_logic;
	signal p_adc_cs : out std_logic_vector(3 downto 0);
	signal p_adc_sck : out std_logic_vector(3 downto 0);
	signal p_adc_sdi : out std_logic_vector(3 downto 0)
); end component;

component adc_capture port(
	signal p_adc_dp : in std_logic_vector(31 downto 0);
	signal p_adc_dn : in std_logic_vector(31 downto 0);
	signal adc_en : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal adc_data : out adc_data_array
); end component;

signal adc_data : adc_data_array;

component trigger port(
	signal p_disc : in std_logic_vector(31 downto 0);
--	signal cw : in std_logic_vector(3 downto 0);
	signal trig_armed : in std_logic;
	signal run : in std_logic;
--	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal trig_pattern : out std_logic_vector(31 downto 0);
	signal trig_nhit : out std_logic_vector(5 downto 0);
	signal local_trig : out std_logic
); end component;

signal trig_pattern : std_logic_vector(31 downto 0);
signal trig_nhit : std_logic_vector(5 downto 0);
signal local_trig : std_logic;

component drs_control port(
	signal p_drs_pll_lock : in std_logic_vector(3 downto 0);
	signal p_drs_srout : in std_logic;
	signal drs_on : in std_logic;
	signal trig_armed : in std_logic;
	signal triged : in std_logic;
	signal latch_pll_lock : in std_logic;
	signal reset : in std_logic;
	signal adc_en : in std_logic;
	signal clk : in std_logic;
	signal drs_pll_locked : out std_logic_vector(3 downto 0);
	signal drs_cal_raddr : out std_logic_vector(9 downto 0);
	signal drs_fifo_waddr : out std_logic_vector(9 downto 0);
	signal drs_fifo_write : out std_logic;
	signal drs_stop_addr : out std_logic_vector(9 downto 0);
	signal drs_read_end : out std_logic;
	signal p_drs_enable : out std_logic_vector(3 downto 0);
	signal p_drs_dwrite : out std_logic_vector(3 downto 0);
	signal p_drs_rsrload : out std_logic_vector(3 downto 0);
	signal p_drs_srclk : out std_logic_vector(3 downto 0);
	signal p_drs_srin : out std_logic_vector(3 downto 0);
	signal p_drs_a : out drs_a_array
); end component;

signal drs_pll_locked : std_logic_vector(3 downto 0);
signal drs_cal_raddr : std_logic_vector(9 downto 0);
signal drs_fifo_waddr : std_logic_vector(9 downto 0);
signal drs_fifo_write : std_logic;
signal drs_stop_addr : std_logic_vector(9 downto 0);
signal drs_read_end : std_logic;

component drs_calibration port(
	signal adc_data : in adc_data_array;
	signal drs_cal_raddr : in std_logic_vector(9 downto 0);
	signal cal_wen : in std_logic;
	signal cal_sck : in std_logic;
	signal cal_sdi : in std_logic;
	signal drs_calib : in std_logic;
	signal clk : in std_logic;
	signal drs_fifo_wdata : out adc_data_array
); end component;

signal drs_fifo_wdata : adc_data_array;

component drs_fifo port(
	signal drs_fifo_wdata : in adc_data_array;
	signal drs_fifo_waddr : in std_logic_vector(9 downto 0);
	signal drs_fifo_raddr : in std_logic_vector(9 downto 0);
	signal drs_fifo_write : in std_logic;
	signal clk : in std_logic;
	signal drs_fifo_rdata : out adc_data_array
); end component;

signal drs_fifo_rdata : adc_data_array;

component data_acquisition port(
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
); end component;

signal run : std_logic;
signal trig_armed : std_logic;
signal drs_fifo_raddr : std_logic_vector(9 downto 0);
signal dram_fifo_wdata : std_logic_vector(511 downto 0);
signal dram_fifo_waddr : std_logic_vector(10 downto 0);
signal dram_fifo_write : std_logic;
signal dram_wpage : std_logic_vector(16 downto 0);
signal dram_rpage : std_logic_vector(16 downto 0);
signal daq_busy : std_logic;
signal dram_fifo_empty : std_logic;
signal dram_full : std_logic;
signal dram_empty : std_logic;										
signal data_fifo_full : std_logic;									
signal data_fifo_empty : std_logic;									
signal data_size : std_logic_vector(12 downto 0);

component dram_fifo port(
	signal dram_fifo_wdata : in std_logic_vector(511 downto 0);
	signal dram_fifo_waddr : in std_logic_vector(10 downto 0);
	signal dram_fifo_raddr : in std_logic_vector(13 downto 0);
	signal dram_fifo_write : in std_logic;
	signal clk : in std_logic;
	signal clk_dram : in std_logic;
	signal dram_fifo_rdata : out std_logic_vector(63 downto 0)
); end component;

signal dram_fifo_rdata : std_logic_vector(63 downto 0);

component dram_controller port(
	signal p_dram_d : inout std_logic_vector(15 downto 0);
	signal dram_fifo_rdata : in std_logic_vector(63 downto 0);
	signal dram_wpage : in std_logic_vector(16 downto 0);
	signal dram_rpage : in std_logic_vector(16 downto 0);
	signal dram_fifo_empty : in std_logic;
	signal data_fifo_full : in std_logic;
	signal dram_full : in std_logic;
	signal dram_empty : in std_logic;
	signal dram_idly : in dram_idly_array;
	signal wdram_idly : in std_logic_vector(1 downto 0);
	signal dram_bitslip : in std_logic_vector(1 downto 0);
	signal dram_test_wr : in std_logic;
	signal dram_test_rd : in std_logic;
	signal dram_test_on : in std_logic;
	signal dram_start : in std_logic;
	signal dram_stop : in std_logic;
	signal reset_serdes_md : in std_logic;
	signal reset_serdes_mds : in std_logic;
	signal reset_dram : in std_logic;
	signal x2clk_dram : in std_logic;
	signal x2clk90_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal clk45_dram : in std_logic;
	signal clk : in std_logic;
	signal dram_fifo_raddr : out std_logic_vector(13 downto 0);
	signal add_dram_wpage : out std_logic;
	signal sub_dram_fifo_cnt : out std_logic;
	signal add_dram_cnt : out std_logic;
	signal data_fifo_waddr : out std_logic_vector(11 downto 0);
	signal data_fifo_write : out std_logic;
	signal add_dram_rpage : out std_logic;
	signal add_data_fifo_cnt : out std_logic;
	signal sub_dram_cnt : out std_logic;
	signal data_fifo_wdata : out std_logic_vector(63 downto 0);
	signal dram_test_pattern : out std_logic_vector(63 downto 0);
	signal dram_ready : out std_logic;
	signal p_dram_dsp : out std_logic_vector(1 downto 0);
	signal p_dram_dsn : out std_logic_vector(1 downto 0);
	signal p_dram_a : out std_logic_vector(13 downto 0);
	signal p_dram_ba : out std_logic_vector(2 downto 0);
	signal p_dram_cs : out std_logic;
	signal p_dram_ras : out std_logic;
	signal p_dram_cas : out std_logic;
	signal p_dram_we : out std_logic;
	signal p_dram_clke : out std_logic;
	signal p_dram_odt : out std_logic;
	signal p_dram_reset : out std_logic
); end component;

signal dram_fifo_raddr : std_logic_vector(13 downto 0);
signal add_dram_wpage : std_logic;
signal sub_dram_fifo_cnt : std_logic;
signal add_dram_cnt : std_logic;
signal data_fifo_waddr : std_logic_vector(11 downto 0);
signal data_fifo_write : std_logic;
signal add_dram_rpage : std_logic;
signal add_data_fifo_cnt : std_logic;
signal sub_dram_cnt : std_logic;
signal data_fifo_wdata : std_logic_vector(63 downto 0);
signal dram_test_pattern : std_logic_vector(63 downto 0);
signal dram_ready : std_logic;

component data_fifo port(
	signal data_fifo_wdata : in std_logic_vector(63 downto 0);
	signal data_fifo_waddr : in std_logic_vector(11 downto 0);
	signal data_fifo_raddr : in std_logic_vector(12 downto 0);
	signal data_fifo_write : in std_logic;
	signal clk_dram : in std_logic;
	signal clk : in std_logic;
	signal data_fifo_rdata : out std_logic_vector(31 downto 0)
); end component;	

signal data_fifo_rdata : std_logic_vector(31 downto 0);

component usb_interface port(
	signal p_usb_d : inout std_logic_vector(31 downto 0);
	signal p_usb_rflag : in std_logic_vector(1 downto 0);
	signal p_usb_wflag : in std_logic;
	signal p_usb_on : in std_logic;
	signal data_fifo_empty : in std_logic;
	signal data_fifo_rdata : in std_logic_vector(31 downto 0);
	signal data_size : in std_logic_vector(12 downto 0);
	signal reset : in std_logic;
	signal clk : in std_logic;
	signal data_fifo_raddr : out std_logic_vector(12 downto 0);
	signal sub_data_fifo_cnt : out std_logic;
	signal latch_data_size : out std_logic;
	signal p_usb_a : out std_logic_vector(1 downto 0);
	signal p_usb_cs : out std_logic;
	signal p_usb_wr : out std_logic;
	signal p_usb_oe : out std_logic;
	signal p_usb_rd : out std_logic;
	signal p_usb_pktend : out std_logic
); end component;

signal data_fifo_raddr : std_logic_vector(12 downto 0);
signal sub_data_fifo_cnt : std_logic;
signal latch_data_size : std_logic;

component commands port(
	signal command : in std_logic_vector(5 downto 1);
	signal sendcom : in std_logic;
	signal reg_wch : in std_logic_vector(4 downto 0);
	signal reg_waddr : in std_logic_vector(5 downto 0);
	signal reg_wdata : in std_logic_vector(27 downto 0);
	signal reg_wr : in std_logic;
	signal clk : in std_logic;
	signal clk_dram : in std_logic;
	signal reset : out std_logic;
	signal reset_dram : out std_logic;
	signal start : out std_logic;
	signal stop : out std_logic;
	signal drs_on : out std_logic;
--	signal cw : out std_logic_vector(3 downto 0);
	signal hv_data : out hv_data_array;
	signal hv_write : out std_logic_vector(3 downto 0);
	signal thr_data : out thr_data_array;
	signal thr_write : out std_logic_vector(31 downto 0);
	signal dram_start : out std_logic;
	signal dram_stop : out std_logic;
	signal dram_test_wr : out std_logic;
	signal dram_test_rd : out std_logic;
	signal dram_test_on : out std_logic;
	signal drs_rofs : out std_logic_vector(11 downto 0);
	signal drs_oofs : out std_logic_vector(11 downto 0);
	signal dac_ofs_write : out std_logic;
	signal drs_calib : out std_logic;
	signal adc_saddr : out std_logic_vector(7 downto 0);
	signal adc_sdata : out std_logic_vector(7 downto 0);
	signal adc_write : out std_logic;
	signal reset_refclk : out std_logic;
	signal dram_idly : out dram_idly_array;
	signal wdram_idly : out std_logic_vector(1 downto 0);
	signal dram_bitslip : out std_logic_vector(1 downto 0)
); end component;

signal reset : std_logic;
signal reset_dram : std_logic;
signal start : std_logic;
signal stop : std_logic;
signal drs_on : std_logic;
--	signal cw : std_logic_vector(3 downto 0);
signal hv_data : hv_data_array;
signal hv_write : std_logic_vector(3 downto 0);
signal thr_data : thr_data_array;
signal thr_write : std_logic_vector(31 downto 0);
signal dram_start : std_logic;
signal dram_stop : std_logic;
signal dram_test_wr : std_logic;
signal dram_test_rd : std_logic;
signal dram_test_on : std_logic;
signal drs_rofs : std_logic_vector(11 downto 0);
signal drs_oofs : std_logic_vector(11 downto 0);
signal dac_ofs_write : std_logic;
signal drs_calib : std_logic;
signal adc_saddr : std_logic_vector(7 downto 0);
signal adc_sdata : std_logic_vector(7 downto 0);
signal adc_write : std_logic;
signal reset_refclk : std_logic;
signal dram_idly : dram_idly_array;
signal wdram_idly : std_logic_vector(1 downto 0);
signal dram_bitslip : std_logic_vector(1 downto 0);

component register_readout port(
	signal run : in std_logic;
--	signal cw : in std_logic_vector(3 downto 0);
	signal hv_data : in hv_data_array;
	signal thr_data : in thr_data_array;
	signal temp_data : in std_logic_vector(11 downto 0);
	signal drs_pll_locked : in std_logic_vector(3 downto 0);
	signal dram_ready : in std_logic;
	signal dram_test_pattern : in std_logic_vector(63 downto 0);
	signal reg_rch : in std_logic_vector(4 downto 0);
	signal reg_raddr : in std_logic_vector(4 downto 0);
	signal reg_latch : in std_logic;
	signal clk : in std_logic;
	signal latch_temp : out std_logic;
	signal latch_pll_lock : out std_logic;
	signal reg_rdata : out std_logic_vector(31 downto 0)
); end component;

signal latch_temp : std_logic;
signal latch_pll_lock : std_logic;
signal reg_rdata : std_logic_vector(31 downto 0);

begin

	u1 : clocks port map(
		p_tcb_clkp => p_tcb_clkp,
		p_tcb_clkn => p_tcb_clkn,
		reset_refclk => reset_refclk,
		x2clk => x2clk,
		clk => clk,
		x2clk_dram => x2clk_dram,
		x2clk90_dram => x2clk90_dram,
		clk_dram => clk_dram,
		clk45_dram => clk45_dram,
		reset_serdes_md => reset_serdes_md,
		reset_serdes_mds => reset_serdes_mds,
		p_usb_pclk => p_usb_pclk,
		p_dram_clkp => p_dram_clkp,
		p_dram_clkn => p_dram_clkn
	);

	u2 : tcb_link port map(
		p_tcb_timerp => p_tcb_timerp,
		p_tcb_timern => p_tcb_timern,
		p_tcb_trigp => p_tcb_trigp,
		p_tcb_trign => p_tcb_trign,
		run => run,
		link_enable => link_enable,
		mod_mid => mod_mid,
		trig_nhit => trig_nhit,
		local_trig => local_trig,
		reg_rdata => reg_rdata,
		daq_busy => daq_busy,
		x2clk => x2clk,
		clk => clk,
		adc_en => adc_en,
		run_number => run_number,
		local_ctime => local_ctime,
		local_ftime => local_ftime,
		trig_type => trig_type,
		trig_number => trig_number,
		trig_ctime => trig_ctime,
		trig_ftime => trig_ftime,
		triged => triged,
		command => command,
		sendcom => sendcom,
		reg_waddr => reg_waddr,
		reg_wch => reg_wch,
		reg_wdata => reg_wdata,
		reg_wr => reg_wr,
		reg_rch => reg_rch,
		reg_raddr => reg_raddr,
		reg_latch => reg_latch,
		p_adc_clkp => p_adc_clkp,
		p_adc_clkn => p_adc_clkn,
		p_drs_clkp => p_drs_clkp,
		p_drs_clkn => p_drs_clkn,
		p_adc_trigp => p_adc_trigp,
		p_adc_trign => p_adc_trign
	);

	u3 : download_mid port map(
		p_mid_sel => p_mid_sel,
		p_mid_sck => p_mid_sck,
		p_mid_sdi => p_mid_sdi,
		clk => clk,
		mod_mid => mod_mid,
		link_enable => link_enable,
		cal_wen => cal_wen,
		cal_sck => cal_sck,
		cal_sdi => cal_sdi
	);

	u4 : cpld_spi_ctrl port map(
		hv_data => hv_data,
		hv_write => hv_write,
		thr_data => thr_data,
		thr_write => thr_write,
		drs_rofs => drs_rofs,
		drs_oofs => drs_oofs,
		dac_ofs_write => dac_ofs_write,
		clk => clk,
		p_cpld_cs => p_cpld_cs,
		p_cpld_sck => p_cpld_sck,
		p_cpld_sdi => p_cpld_sdi
	);

	u5 : temperature_monitor port map(
		p_temp_sda => p_temp_sda,
		latch_temp => latch_temp,
		clk => clk,
		temp_data => temp_data,
		p_temp_scl => p_temp_scl
	);

	u6 : adc_setup port map(
		adc_saddr => adc_saddr,
		adc_sdata => adc_sdata,
		adc_write => adc_write,
		clk => clk,
		p_adc_cs => p_adc_cs,
		p_adc_sck => p_adc_sck,
		p_adc_sdi => p_adc_sdi
	);

	u7 : adc_capture port map(
		p_adc_dp => p_adc_dp,
		p_adc_dn => p_adc_dn,
		adc_en => adc_en,
		x2clk => x2clk,
		clk => clk,
		adc_data => adc_data
	);

	u8 : trigger port map(
		p_disc => p_disc,
--		cw => cw,
		trig_armed => trig_armed,
		run => run,
--		x2clk => x2clk,
		clk => clk,
		trig_pattern => trig_pattern,
		trig_nhit => trig_nhit,
		local_trig => local_trig
	);

	u9 : drs_control port map(
		p_drs_pll_lock => p_drs_pll_lock,
		p_drs_srout => p_drs_srout,
		drs_on => drs_on,
		trig_armed => trig_armed,
		triged => triged,
		latch_pll_lock => latch_pll_lock,
		reset => reset,
		adc_en => adc_en,
		clk => clk,
		drs_pll_locked => drs_pll_locked,
		drs_cal_raddr => drs_cal_raddr,
		drs_fifo_waddr => drs_fifo_waddr,
		drs_fifo_write => drs_fifo_write,
		drs_stop_addr => drs_stop_addr,
		drs_read_end => drs_read_end,
		p_drs_enable => p_drs_enable,
		p_drs_dwrite => p_drs_dwrite,
		p_drs_rsrload => p_drs_rsrload,
		p_drs_srclk => p_drs_srclk,
		p_drs_srin => p_drs_srin,
		p_drs_a => p_drs_a
	);

	u10 : drs_calibration port map(
		adc_data => adc_data,
		drs_cal_raddr => drs_cal_raddr,
		cal_wen => cal_wen,
		cal_sck => cal_sck,
		cal_sdi => cal_sdi,
		drs_calib => drs_calib,
		clk => clk,
		drs_fifo_wdata => drs_fifo_wdata
	);

	u11 : drs_fifo port map(
		drs_fifo_wdata => drs_fifo_wdata,
		drs_fifo_waddr => drs_fifo_waddr,
		drs_fifo_raddr => drs_fifo_raddr,
		drs_fifo_write => drs_fifo_write,
		clk => clk,
		drs_fifo_rdata => drs_fifo_rdata
	);

	u12 : data_acquisition port map(
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
		add_dram_wpage => add_dram_wpage,
		add_dram_rpage => add_dram_rpage,
		add_dram_cnt => add_dram_cnt,
		sub_dram_cnt => sub_dram_cnt,
		sub_dram_fifo_cnt => sub_dram_fifo_cnt,
		add_data_fifo_cnt => add_data_fifo_cnt,
		sub_data_fifo_cnt => sub_data_fifo_cnt,
		latch_data_size => latch_data_size,
		drs_calib => drs_calib,
		drs_on => drs_on,
		start => start,
		stop => stop,
		reset => reset,
		reset_dram => reset_dram,
		clk => clk,
		clk_dram => clk_dram,
		run => run,
		trig_armed => trig_armed,
		drs_fifo_raddr => drs_fifo_raddr,
		dram_fifo_wdata => dram_fifo_wdata,
		dram_fifo_waddr => dram_fifo_waddr,
		dram_fifo_write => dram_fifo_write,
		dram_wpage => dram_wpage,
		dram_rpage => dram_rpage,
		daq_busy => daq_busy,
		dram_fifo_empty => dram_fifo_empty,
		dram_full => dram_full,
		dram_empty => dram_empty,
		data_fifo_full => data_fifo_full,
		data_fifo_empty => data_fifo_empty,
		data_size => data_size
	);

	u13 : dram_fifo port map(
		dram_fifo_wdata => dram_fifo_wdata,
		dram_fifo_waddr => dram_fifo_waddr,
		dram_fifo_raddr => dram_fifo_raddr,
		dram_fifo_write => dram_fifo_write,
		clk => clk,
		clk_dram => clk_dram,
		dram_fifo_rdata => dram_fifo_rdata
	);

	u14 : dram_controller port map(
		p_dram_d => p_dram_d,
		dram_fifo_rdata => dram_fifo_rdata,
		dram_wpage => dram_wpage,
		dram_rpage => dram_rpage,
		dram_fifo_empty => dram_fifo_empty,
		data_fifo_full => data_fifo_full,
		dram_full => dram_full,
		dram_empty => dram_empty,
		dram_idly => dram_idly,
		wdram_idly => wdram_idly,
		dram_bitslip => dram_bitslip,
		dram_test_wr => dram_test_wr,
		dram_test_rd => dram_test_rd,
		dram_test_on => dram_test_on,
		dram_start => dram_start,
		dram_stop => dram_stop,
		reset_serdes_md => reset_serdes_md,
		reset_serdes_mds => reset_serdes_mds,
		reset_dram => reset_dram,
		x2clk_dram => x2clk_dram,
		x2clk90_dram => x2clk90_dram,
		clk_dram => clk_dram,
		clk45_dram => clk45_dram,
		clk => clk,
		dram_fifo_raddr => dram_fifo_raddr,
		add_dram_wpage => add_dram_wpage,
		sub_dram_fifo_cnt => sub_dram_fifo_cnt,
		add_dram_cnt => add_dram_cnt,
		data_fifo_waddr => data_fifo_waddr,
		data_fifo_write => data_fifo_write,
		add_dram_rpage => add_dram_rpage,
		add_data_fifo_cnt => add_data_fifo_cnt,
		sub_dram_cnt => sub_dram_cnt,
		data_fifo_wdata => data_fifo_wdata,
		dram_test_pattern => dram_test_pattern,
		dram_ready => dram_ready,
		p_dram_dsp => p_dram_dsp,
		p_dram_dsn => p_dram_dsn,
		p_dram_a => p_dram_a,
		p_dram_ba => p_dram_ba,
		p_dram_cs => p_dram_cs,
		p_dram_ras => p_dram_ras,
		p_dram_cas => p_dram_cas,
		p_dram_we => p_dram_we,
		p_dram_clke => p_dram_clke,
		p_dram_odt => p_dram_odt,
		p_dram_reset => p_dram_reset
	);

	u15 : data_fifo port map(
		data_fifo_wdata => data_fifo_wdata,
		data_fifo_waddr => data_fifo_waddr,
		data_fifo_raddr => data_fifo_raddr,
		data_fifo_write => data_fifo_write,
		clk_dram => clk_dram,
		clk => clk,
		data_fifo_rdata => data_fifo_rdata
	);

	u16 : usb_interface port map(
		p_usb_d => p_usb_d,
		p_usb_rflag => p_usb_rflag,
		p_usb_wflag => p_usb_wflag,
		p_usb_on => p_usb_on,
		data_fifo_empty => data_fifo_empty,
		data_fifo_rdata => data_fifo_rdata,
		data_size => data_size,
		reset => reset,
		clk => clk,
		data_fifo_raddr => data_fifo_raddr,
		sub_data_fifo_cnt => sub_data_fifo_cnt,
		latch_data_size => latch_data_size,
		p_usb_a => p_usb_a,
		p_usb_cs => p_usb_cs,
		p_usb_wr => p_usb_wr,
		p_usb_oe => p_usb_oe,
		p_usb_rd => p_usb_rd,
		p_usb_pktend => p_usb_pktend
	);

	u17 : commands port map(
		command => command,
		sendcom => sendcom,
		reg_wch => reg_wch,
		reg_waddr => reg_waddr,
		reg_wdata => reg_wdata,
		reg_wr => reg_wr,
		clk => clk,
		clk_dram => clk_dram,
		reset => reset,
		reset_dram => reset_dram,
		start => start,
		stop => stop,
		drs_on => drs_on,
--		cw => cw,
		hv_data => hv_data,
		hv_write => hv_write,
		thr_data => thr_data,
		thr_write => thr_write,
		dram_start => dram_start,
		dram_stop => dram_stop,
		dram_test_wr => dram_test_wr,
		dram_test_rd => dram_test_rd,
		dram_test_on => dram_test_on,
		drs_rofs => drs_rofs,
		drs_oofs => drs_oofs,
		dac_ofs_write => dac_ofs_write,
		drs_calib => drs_calib,
		adc_saddr => adc_saddr,
		adc_sdata => adc_sdata,
		adc_write => adc_write,
		reset_refclk => reset_refclk,
		dram_idly => dram_idly,
		wdram_idly => wdram_idly,
		dram_bitslip => dram_bitslip
	);

	u18 : register_readout port map(
		run => run,
--		cw => cw,
		hv_data => hv_data,
		thr_data => thr_data,
		temp_data => temp_data,
		drs_pll_locked => drs_pll_locked,
		dram_ready => dram_ready,
		dram_test_pattern => dram_test_pattern,
		reg_rch => reg_rch,
		reg_raddr => reg_raddr,
		reg_latch => reg_latch,
		clk => clk,
		latch_temp => latch_temp,
		latch_pll_lock => latch_pll_lock,
		reg_rdata => reg_rdata
	);

end Behavioral;

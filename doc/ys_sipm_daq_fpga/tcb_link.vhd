library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity tcb_link is port(
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
); end tcb_link;

architecture Behavioral of tcb_link is

component tcb_sync port(
	signal p_tcb_timerp : in std_logic;
	signal p_tcb_timern : in std_logic;
	signal p_tcb_trigp : in std_logic;
	signal p_tcb_trign : in std_logic;
	signal link_enable : in std_logic;
	signal linkerr : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal sidat : out std_logic_vector(1 downto 0);
	signal fcnt : out std_logic_vector(6 downto 0);
	signal linkok : out std_logic
); end component;

signal sidat : std_logic_vector(1 downto 0);
signal fcnt : std_logic_vector(6 downto 0);
signal linkok : std_logic;

component tcb_deserializer port(
	signal sidat : in std_logic_vector(1 downto 0);
	signal fcnt : in std_logic_vector(6 downto 0);
	signal linkok : in std_logic;
	signal clk : in std_logic;
	signal tcbin_timer : out std_logic_vector(7 downto 0);
	signal tcbin_trig : out std_logic_vector(7 downto 0);
	signal linkerr : out std_logic
); end component;

signal tcbin_timer : std_logic_vector(7 downto 0);
signal tcbin_trig : std_logic_vector(7 downto 0);
signal linkerr : std_logic;

component tcb_receiver port(
	signal tcbin_timer : in std_logic_vector(7 downto 0);
	signal tcbin_trig : in std_logic_vector(7 downto 0);
	signal fcnt : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal tcb_mid : out std_logic_vector(7 downto 0);
	signal tcb_com : out std_logic_vector(5 downto 1);
	signal tcb_din_timer : out std_logic_vector(47 downto 0);
	signal tcb_din_trig_type : out std_logic_vector(1 downto 0);
	signal tcb_din_trig_ch : out std_logic_vector(4 downto 0);
	signal tcb_din_trig_addr : out std_logic_vector(5 downto 0);
	signal tcb_din_trig_data : out std_logic_vector(27 downto 0);
	signal tcb_recv : out std_logic
); end component;

signal tcb_mid : std_logic_vector(7 downto 0);
signal tcb_com : std_logic_vector(5 downto 1);
signal tcb_din_timer : std_logic_vector(47 downto 0);
signal tcb_din_trig_type : std_logic_vector(1 downto 0);
signal tcb_din_trig_ch : std_logic_vector(4 downto 0);
signal tcb_din_trig_addr : std_logic_vector(5 downto 0);
signal tcb_din_trig_data : std_logic_vector(27 downto 0);
signal tcb_recv : std_logic;

component tcb_read port(
	signal sidat : in std_logic;
	signal linkok : in std_logic;
	signal run : in std_logic;
	signal link_enable : in std_logic;
	signal mod_mid : in std_logic_vector(7 downto 0);
	signal tcb_mid : in std_logic_vector(7 downto 0);
	signal tcb_com : in std_logic_vector(5 downto 1);
	signal tcb_din_timer : in std_logic_vector(47 downto 0);
	signal tcb_din_trig_type : in std_logic_vector(1 downto 0);
	signal tcb_din_trig_ch : in std_logic_vector(4 downto 0);
	signal tcb_din_trig_addr : in std_logic_vector(5 downto 0);
	signal tcb_din_trig_data : in std_logic_vector(27 downto 0);
	signal tcb_recv : in std_logic;
	signal daq_busy : in std_logic;
	signal clk : in std_logic;
	signal run_number : out std_logic_vector(15 downto 0);
	signal local_ctime : out std_logic_vector(47 downto 0);
	signal local_ftime : out std_logic_vector(6 downto 0);
	signal adc_en : out std_logic;
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
	signal reg_rd : out std_logic;
	signal reg_latch : out std_logic;
	signal p_adc_clkp : out std_logic_vector(3 downto 0);
	signal p_adc_clkn : out std_logic_vector(3 downto 0);
	signal p_drs_clkp : out std_logic_vector(3 downto 0);
	signal p_drs_clkn : out std_logic_vector(3 downto 0)
); end component;

signal reg_rd : std_logic;

component tcb_serializer port(
	signal parout : in std_logic_vector(9 downto 0);
	signal fcnt : in std_logic_vector(6 downto 0);
	signal trgdat : in std_logic;
	signal run : in std_logic;
	signal linkok : in std_logic;
	signal clk : in std_logic;
	signal p_adc_trigp : out std_logic;
	signal p_adc_trign : out std_logic
); end component;

component tcb_transmitter port(
	signal mod_mid : in std_logic_vector(7 downto 0);
	signal mod_type : in std_logic;
	signal mod_din : in std_logic_vector(31 downto 0);
	signal fcnt : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal parout : out std_logic_vector(9 downto 0)
); end component;
		
signal parout : std_logic_vector(9 downto 0);

component tcb_write port(
	signal trig_nhit : in std_logic_vector(5 downto 0);
	signal local_trig : in std_logic;
	signal reg_rdata : in std_logic_vector(31 downto 0);
	signal reg_rd : in std_logic;
	signal fcnt : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal mod_type : out std_logic;
	signal mod_din : out std_logic_vector(31 downto 0);
	signal trgdat : out std_logic
); end component;

signal mod_type : std_logic;
signal mod_din : std_logic_vector(31 downto 0);
signal trgdat : std_logic;

begin

	u1 : tcb_sync port map(
		p_tcb_timerp => p_tcb_timerp,
		p_tcb_timern => p_tcb_timern,
		p_tcb_trigp => p_tcb_trigp,
		p_tcb_trign => p_tcb_trign,
		link_enable => link_enable,
		linkerr => linkerr,
		x2clk => x2clk,
		clk => clk,
		sidat => sidat,
		fcnt => fcnt,
		linkok => linkok
	);

	u2 : tcb_deserializer port map(
		sidat => sidat,
		fcnt => fcnt,
		linkok => linkok,
		clk => clk,
		tcbin_timer => tcbin_timer,
		tcbin_trig => tcbin_trig,
		linkerr => linkerr
	);

	u3 : tcb_receiver port map(
		tcbin_timer => tcbin_timer,
		tcbin_trig => tcbin_trig,
		fcnt => fcnt,
		clk => clk,
		tcb_mid => tcb_mid,
		tcb_com => tcb_com,
		tcb_din_timer => tcb_din_timer,
		tcb_din_trig_type => tcb_din_trig_type,
		tcb_din_trig_ch => tcb_din_trig_ch,
		tcb_din_trig_addr => tcb_din_trig_addr,
		tcb_din_trig_data => tcb_din_trig_data,
		tcb_recv => tcb_recv
	);

	u4 : tcb_read port map(
		sidat => sidat(1),
		linkok => linkok,
		run => run,
		link_enable => link_enable,
		mod_mid => mod_mid,
		tcb_mid => tcb_mid,
		tcb_com => tcb_com,
		tcb_din_timer => tcb_din_timer,
		tcb_din_trig_type => tcb_din_trig_type,
		tcb_din_trig_ch => tcb_din_trig_ch,
		tcb_din_trig_addr => tcb_din_trig_addr,
		tcb_din_trig_data => tcb_din_trig_data,
		tcb_recv => tcb_recv,
		daq_busy => daq_busy,
		clk => clk,
		run_number => run_number,
		local_ctime => local_ctime,
		local_ftime => local_ftime,
		adc_en => adc_en,
		trig_type => trig_type,
		trig_number => trig_number,
		trig_ctime => trig_ctime,
		trig_ftime => trig_ftime,
		triged => triged,
		command => command,
		sendcom => sendcom,
		reg_wch => reg_wch,
		reg_waddr => reg_waddr,
		reg_wdata => reg_wdata,
		reg_wr => reg_wr,
		reg_rch => reg_rch,
		reg_raddr => reg_raddr,
		reg_rd => reg_rd,
		reg_latch => reg_latch,
		p_adc_clkp => p_adc_clkp,
		p_adc_clkn => p_adc_clkn,
		p_drs_clkp => p_drs_clkp,
		p_drs_clkn => p_drs_clkn
	);

	u5 : tcb_serializer port map(
		parout => parout,
		fcnt => fcnt,
		trgdat => trgdat,
		run => run,
		linkok => linkok,
		clk => clk,
		p_adc_trigp => p_adc_trigp,
		p_adc_trign => p_adc_trign
	);

	u6 : tcb_transmitter port map(
		mod_mid => mod_mid,
		mod_type => mod_type,
		mod_din => mod_din,
		fcnt => fcnt,
		clk => clk,
		parout => parout
	);

	u7 : tcb_write port map(
		trig_nhit => trig_nhit,
		local_trig => local_trig,
		reg_rdata => reg_rdata,
		reg_rd => reg_rd,
		fcnt => fcnt,
		clk => clk,
		mod_type => mod_type,
		mod_din => mod_din,
		trgdat => trgdat
	);

end Behavioral;


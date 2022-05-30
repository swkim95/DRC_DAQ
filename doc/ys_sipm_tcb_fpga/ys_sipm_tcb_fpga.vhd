library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity ys_sipm_tcb_fpga is port (
--	signal p_gtx_clkp : in std_logic;
--	signal p_gtx_clkn : in std_logic;
--	signal p_gtx_txp : out std_logic;
--	signal p_gtx_txn : out std_logic;
--	signal p_gtx_rxp : in std_logic;
--	signal p_gtx_rxn : in std_logic;
--	signal p_gtx_def : in std_logic;
	signal p_gtx_txdis : out std_logic;
--	signal p_gtx_loss : in std_logic;
	signal p_tcb_timerp : out std_logic_vector(39 downto 0);
	signal p_tcb_timern : out std_logic_vector(39 downto 0);
	signal p_tcb_triggerp : out std_logic_vector(39 downto 0);
	signal p_tcb_triggern : out std_logic_vector(39 downto 0);
	signal p_adc_triggerp : in std_logic_vector(39 downto 0);
	signal p_adc_triggern : in std_logic_vector(39 downto 0);
	signal p_fpga_clkp : in std_logic;
	signal p_fpga_clkn : in std_logic;
--	signal p_master_timerp : in std_logic;
--	signal p_master_timern : in std_logic;
--	signal p_master_trigger_inp : in std_logic;
--	signal p_master_trigger_inn : in std_logic;
--	signal p_master_trigger_outp : out std_logic;
--	signal p_master_trigger_outn : out std_logic;
	signal p_ext_trigger_in_nim : in std_logic;
	signal p_ext_trigger_in_ttl : in std_logic;
	signal p_ext_trigger_out : out std_logic;
	signal p_usb_d : inout std_logic_vector(31 downto 0);
	signal p_usb_cs : out std_logic;
	signal p_usb_wr : out std_logic;
	signal p_usb_oe : out std_logic;
	signal p_usb_rd : out std_logic;
	signal p_usb_rflag : in std_logic_vector(1 downto 0);
	signal p_usb_wflag : in std_logic;
	signal p_usb_pktend : out std_logic;
	signal p_usb_on : in std_logic;
--	signal p_mid_sck : in std_logic;
--	signal p_mid_sdi : in std_logic;
	signal p_usb_a : out std_logic_vector(1 downto 0);
	signal p_usb_pclk : out std_logic;
	signal p_led_cs : out std_logic;
	signal p_led_sck : out std_logic;
	signal p_led_sdi : out std_logic
); end ys_sipm_tcb_fpga;

architecture Behavioral of ys_sipm_tcb_fpga is

component clocks port(
	signal p_fpga_clkp : in std_logic;
	signal p_fpga_clkn : in std_logic;
	signal x2clk : out std_logic;
	signal clk : out std_logic;
	signal p_usb_pclk : out std_logic
); end component;

signal x2clk : std_logic;
signal clk : std_logic;

component timer port(
	signal reset_timer : in std_logic;
	signal clk : in std_logic;
	signal tcb_ftime : out std_logic_vector(6 downto 0);
	signal tcb_ctime : out std_logic_vector(47 downto 0)
); end component;

signal tcb_ftime : std_logic_vector(6 downto 0);
signal tcb_ctime : std_logic_vector(47 downto 0);

component link_output port(
	signal tcb_cdat : in std_logic_vector(7 downto 0);
	signal tcb_com : in std_logic;
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(47 downto 0);
	signal tcb_mid : in std_logic_vector(7 downto 0);
	signal tcb_addr : in std_logic_vector(13 downto 0);
	signal tcb_wdat : in std_logic_vector(31 downto 0);
	signal tcb_write : in std_logic;
	signal tcb_read : in std_logic;
	signal run_number : in std_logic_vector(15 downto 0);
	signal trig_type : in std_logic_vector(1 downto 0);
	signal tcb_trig : in std_logic;
	signal run : in std_logic;
	signal reset : in std_logic;
	signal clk : in std_logic;
	signal p_tcb_timerp : out std_logic_vector(39 downto 0);
	signal p_tcb_timern : out std_logic_vector(39 downto 0);
	signal p_tcb_triggerp : out std_logic_vector(39 downto 0);
	signal p_tcb_triggern : out std_logic_vector(39 downto 0)
); end component;

component link_input port(
	signal p_adc_triggerp : in std_logic_vector(39 downto 0);
	signal p_adc_triggern : in std_logic_vector(39 downto 0);
	signal run : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal mod_mid : out mod_mid_array;
	signal triged : out std_logic_vector(39 downto 0);
	signal mod_nhit : out mod_nhit_array;
	signal mod_rdat : out mod_rdat_array;
	signal response : out std_logic_vector(39 downto 0);
	signal linked : out std_logic_vector(39 downto 0)
); end component;

signal mod_mid : mod_mid_array;
signal triged : std_logic_vector(39 downto 0);
signal mod_nhit : mod_nhit_array;
signal mod_rdat : mod_rdat_array;
signal response : std_logic_vector(39 downto 0);
signal linked : std_logic_vector(39 downto 0);

component external_trigger port(
	signal p_ext_trigger_in_nim : in std_logic;
	signal p_ext_trigger_in_ttl : in std_logic;
	signal cw : in std_logic_vector(3 downto 0);
	signal tcb_trig : in std_logic;
	signal clk : in std_logic;
	signal etrig : out std_logic;
	signal p_ext_trigger_out : out std_logic
); end component;

signal etrig : std_logic;

component trigger_pulse port(
	signal cw : in std_logic_vector(3 downto 0);
	signal mod_nhit : in mod_nhit_array;
	signal triged : in std_logic_vector(39 downto 0);
	signal clk : in std_logic;
	signal tpulse : out tpulse_array
); end component;

signal tpulse : tpulse_array;

component trigger_logic port(
	signal tpulse : in tpulse_array;
	signal thr : in std_logic_vector(10 downto 0);
	signal clk : in std_logic;
	signal strig : out std_logic
); end component;
	
signal strig : std_logic;

component pedestal_trigger port(
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal ptrig_interval : in std_logic_vector(15 downto 0);
	signal run : in std_logic;
	signal clr_ptrig : in std_logic;
	signal clk : in std_logic;
	signal ptrig : out std_logic
); end component;

signal ptrig : std_logic;

component trigger_send port(
	signal trig_enable : in std_logic_vector(3 downto 0);
	signal trig_dly : in std_logic_vector(3 downto 0);
	signal strig : in std_logic;
	signal etrig : in std_logic;
	signal ptrig : in std_logic;
	signal rtrig : in std_logic;
	signal run : in std_logic;
	signal clk : in std_logic;
	signal trig_type : out std_logic_vector(1 downto 0);
	signal tcb_trig : out std_logic
); end component;
		
signal trig_type : std_logic_vector(1 downto 0);
signal tcb_trig : std_logic;

component led_driver port(
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(13 downto 0);
	signal triged : in std_logic_vector(39 downto 0);
	signal response : in std_logic_vector(39 downto 0);
	signal linked : in std_logic_vector(39 downto 0);
	signal clk : in std_logic;
	signal p_led_cs : out std_logic;
	signal p_led_sck : out std_logic;
	signal p_led_sdi : out std_logic
); end component;

component get_mid port(
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal mod_mid : in mod_mid_array;
	signal usb_mid : in std_logic_vector(7 downto 0);
	signal clk : in std_logic;
	signal mid_addr : out std_logic_vector(5 downto 0)
); end component;

signal mid_addr : std_logic_vector(5 downto 0);

component get_response port(
	signal mod_rdat : in mod_rdat_array;
	signal response : in std_logic_vector(39 downto 0);
	signal mid_addr : in std_logic_vector(5 downto 0);
	signal clk : in std_logic;
	signal mod_rdata : out std_logic_vector(31 downto 0)
); end component;

signal mod_rdata : std_logic_vector(31 downto 0);

component commands port(
	signal usb_mid : in std_logic_vector(7 downto 0);
	signal usb_addr : in std_logic_vector(13 downto 0);
	signal usb_wdata : in std_logic_vector(31 downto 0);
	signal usb_write : in std_logic;
	signal usb_read : in std_logic;
	signal clk : in std_logic;
	signal tcb_cdat : out std_logic_vector(7 downto 0);
	signal tcb_com : out std_logic;
	signal tcb_mid : out std_logic_vector(7 downto 0);
	signal tcb_addr : out std_logic_vector(13 downto 0);
	signal tcb_wdat : out std_logic_vector(31 downto 0);
	signal tcb_write : out std_logic;
	signal tcb_read : out std_logic;
	signal reset_timer : out std_logic;
	signal reset : out std_logic;
	signal run : out std_logic;
	signal cw : out std_logic_vector(3 downto 0);
	signal run_number : out std_logic_vector(15 downto 0);
	signal rtrig : out std_logic;
	signal ptrig_interval : out std_logic_vector(15 downto 0);
	signal clr_ptrig : out std_logic;
	signal trig_enable : out std_logic_vector(3 downto 0);
	signal thr : out std_logic_vector(10 downto 0);
	signal trig_dly : out std_logic_vector(3 downto 0)
); end component;

signal tcb_cdat : std_logic_vector(7 downto 0);
signal tcb_com : std_logic;
signal tcb_mid : std_logic_vector(7 downto 0);
signal tcb_addr : std_logic_vector(13 downto 0);
signal tcb_wdat : std_logic_vector(31 downto 0);
signal tcb_write : std_logic;
signal tcb_read : std_logic;
signal reset_timer : std_logic;
signal reset : std_logic;
signal run : std_logic;
signal cw : std_logic_vector(3 downto 0);
signal run_number : std_logic_vector(15 downto 0);
signal rtrig : std_logic;
signal ptrig_interval : std_logic_vector(15 downto 0);
signal clr_ptrig : std_logic;
signal trig_enable : std_logic_vector(3 downto 0);
signal thr : std_logic_vector(10 downto 0);
signal trig_dly : std_logic_vector(3 downto 0);

component readout port(
	signal usb_mid : in std_logic_vector(7 downto 0);
	signal usb_ra : in std_logic_vector(5 downto 0);
	signal mod_rdata : in std_logic_vector(31 downto 0);
	signal run : in std_logic;
	signal linked : in std_logic_vector(39 downto 0);
	signal mod_mid : in mod_mid_array;
	signal cw : in std_logic_vector(3 downto 0);
	signal run_number : in std_logic_vector(15 downto 0);
	signal ptrig_interval : in std_logic_vector(15 downto 0);
	signal trig_enable : in std_logic_vector(3 downto 0);
	signal thr : in std_logic_vector(10 downto 0);
	signal trig_dly : in std_logic_vector(3 downto 0);
	signal clk : in std_logic;
	signal usb_rdata : out std_logic_vector(31 downto 0)
); end component;

signal usb_rdata : std_logic_vector(31 downto 0);

component usb_interface port(
	signal p_usb_d : inout std_logic_vector(31 downto 0);
	signal p_usb_rflag : in std_logic_vector(1 downto 0);
	signal p_usb_wflag : in std_logic;
	signal p_usb_on : in std_logic;
	signal usb_rdata : in std_logic_vector(31 downto 0);
	signal clk : in std_logic;
	signal usb_mid : out std_logic_vector(7 downto 0);
	signal usb_addr : out std_logic_vector(13 downto 0);
	signal usb_wdata : out std_logic_vector(31 downto 0);
	signal usb_write : out std_logic;
	signal usb_read : out std_logic;
	signal usb_ra : out std_logic_vector(5 downto 0);
	signal p_usb_a : out std_logic_vector(1 downto 0);
	signal p_usb_cs : out std_logic;
	signal p_usb_wr : out std_logic;
	signal p_usb_oe : out std_logic;
	signal p_usb_rd : out std_logic;
	signal p_usb_pktend : out std_logic
); end component;

signal usb_mid : std_logic_vector(7 downto 0);
signal usb_addr : std_logic_vector(13 downto 0);
signal usb_wdata : std_logic_vector(31 downto 0);
signal usb_write : std_logic;
signal usb_read : std_logic;
signal usb_ra : std_logic_vector(5 downto 0);

begin

	obuf_mgt_txdis : obuf port map(i => '1', o => p_gtx_txdis);

	u1 : clocks port map(
		p_fpga_clkp => p_fpga_clkp,
		p_fpga_clkn => p_fpga_clkn,
		x2clk => x2clk,
		clk => clk,
		p_usb_pclk => p_usb_pclk
	);

	u2 : timer port map(
		reset_timer => reset_timer,
		clk => clk,
		tcb_ftime => tcb_ftime,
		tcb_ctime => tcb_ctime
	); 

	u3 : link_output port map(
		tcb_cdat => tcb_cdat,
		tcb_com => tcb_com,
		tcb_ftime => tcb_ftime,
		tcb_ctime => tcb_ctime,
		tcb_mid => tcb_mid,
		tcb_addr => tcb_addr,
		tcb_wdat => tcb_wdat,
		tcb_write => tcb_write,
		tcb_read => tcb_read,
		run_number => run_number,
		trig_type => trig_type,
		tcb_trig => tcb_trig,
		run => run,
		reset => reset,
		clk => clk,
		p_tcb_timerp => p_tcb_timerp,
		p_tcb_timern => p_tcb_timern,
		p_tcb_triggerp => p_tcb_triggerp,
		p_tcb_triggern => p_tcb_triggern
	);

   u4 : link_input port map(
      p_adc_triggerp => p_adc_triggerp,
      p_adc_triggern => p_adc_triggern,
		run => run,
      x2clk => x2clk,
      clk => clk,
      mod_mid => mod_mid,
      triged => triged,
      mod_nhit => mod_nhit,
      mod_rdat => mod_rdat,
      response => response,
      linked => linked
   );

	u5 : external_trigger port map(
      p_ext_trigger_in_nim => p_ext_trigger_in_nim,
      p_ext_trigger_in_ttl => p_ext_trigger_in_ttl,
		cw => cw,
      tcb_trig => tcb_trig,
      clk => clk,
      etrig => etrig,
      p_ext_trigger_out => p_ext_trigger_out
	);

	u6 : trigger_pulse port map(
		cw => cw,
		mod_nhit => mod_nhit,
		triged => triged,
		clk => clk,
		tpulse => tpulse
	);

	u7 : trigger_logic port map(
		tpulse => tpulse,
		thr => thr,
		clk => clk,
		strig => strig
	);

	u8 : pedestal_trigger port map(
		tcb_ftime => tcb_ftime,
		ptrig_interval => ptrig_interval,
		run => run,
		clr_ptrig => clr_ptrig,
		clk => clk,
		ptrig => ptrig
	);

	u9 : trigger_send port map(
		trig_enable => trig_enable,
		trig_dly => trig_dly,
		strig => strig,
		etrig => etrig,
		ptrig => ptrig,
		rtrig => rtrig,
		run => run,
		clk => clk,
		trig_type => trig_type,
		tcb_trig => tcb_trig
	);
	
	u10 : led_driver port map(
		tcb_ftime => tcb_ftime,
		tcb_ctime => tcb_ctime(13 downto 0),
		triged => triged,
		response => response,
		linked => linked,
		clk => clk,
		p_led_cs => p_led_cs,
		p_led_sck => p_led_sck,
		p_led_sdi => p_led_sdi
	);
	
	u11 : get_mid port map(
		tcb_ftime => tcb_ftime,
		mod_mid => mod_mid,
		usb_mid => usb_mid,
		clk => clk,
		mid_addr => mid_addr
	); 

	u12 : get_response port map(
		mod_rdat => mod_rdat,
		response => response,
		mid_addr => mid_addr,
		clk => clk,
		mod_rdata => mod_rdata
	); 

	u13 : commands port map(
		usb_mid => usb_mid,
		usb_addr => usb_addr,
		usb_wdata => usb_wdata,
		usb_write => usb_write,
		usb_read => usb_read,
		clk => clk,
		tcb_cdat => tcb_cdat,
		tcb_com => tcb_com,
		tcb_mid => tcb_mid,
		tcb_addr => tcb_addr,
		tcb_wdat => tcb_wdat,
		tcb_write => tcb_write,
		tcb_read => tcb_read,
		reset_timer => reset_timer,
		reset => reset,
		run => run,
		cw => cw,
		run_number => run_number,
		rtrig => rtrig,
		ptrig_interval => ptrig_interval,
		clr_ptrig => clr_ptrig,
		trig_enable => trig_enable,
		thr => thr,
		trig_dly => trig_dly
	);

	u14 : readout port map(
		usb_mid => usb_mid,
		usb_ra => usb_ra,
		mod_rdata => mod_rdata,
		run => run,
		linked => linked,
		mod_mid => mod_mid,
		cw => cw,
		run_number => run_number,
		ptrig_interval => ptrig_interval,
		trig_enable => trig_enable,
		thr => thr,
		trig_dly => trig_dly,
		clk => clk,
		usb_rdata => usb_rdata
	); 

	u15 : usb_interface port map(
		p_usb_d => p_usb_d,
		p_usb_rflag => p_usb_rflag,
		p_usb_wflag => p_usb_wflag,
		p_usb_on => p_usb_on,
		usb_rdata => usb_rdata,
		clk => clk,
		usb_mid => usb_mid,
		usb_addr => usb_addr,
		usb_wdata => usb_wdata,
		usb_write => usb_write,
		usb_read => usb_read,
		usb_ra => usb_ra,
		p_usb_a => p_usb_a,
		p_usb_cs => p_usb_cs,
		p_usb_wr => p_usb_wr,
		p_usb_oe => p_usb_oe,
		p_usb_rd => p_usb_rd,
		p_usb_pktend => p_usb_pktend
	);

end Behavioral;

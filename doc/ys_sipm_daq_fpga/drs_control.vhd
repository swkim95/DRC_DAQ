library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity drs_control is port(
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
); end drs_control;

architecture Behavioral of drs_control is

signal drs_denable : std_logic_vector(3 downto 0);
signal idrs_srclk : std_logic;
signal drs_srclk : std_logic_vector(3 downto 0);
signal idrs_srin : std_logic;
signal drs_srin : std_logic_vector(3 downto 0);
signal idrs_a : std_logic_vector(1 downto 0);
signal drs_a : drs_a_array;

component drs_ctrl_status port(
	signal p_drs_pll_lock : in std_logic_vector(3 downto 0);
	signal latch_pll_lock : in std_logic;
	signal clk : in std_logic;
	signal drs_pll_locked : out std_logic_vector(3 downto 0)
); end component;

component drs_ctrl_setup port(
	signal drs_on : in std_logic;
	signal clk : in std_logic;
	signal drs_su_a : out std_logic_vector(2 downto 0);
	signal drs_su_srclk : out std_logic;
	signal drs_init : out std_logic
); end component;

signal drs_su_a : std_logic_vector(2 downto 0);
signal drs_su_srclk : std_logic;
signal drs_init : std_logic;

component drs_ctrl_init port(
	signal drs_init : in std_logic;
	signal drs_read_done : in std_logic;
	signal clk : in std_logic;
	signal drs_init_a : out std_logic;
	signal drs_init_srclk : out std_logic
); end component;

signal drs_init_a : std_logic;
signal drs_init_srclk : std_logic;

component drs_ctrl_daq port(
	signal p_drs_srout : in std_logic;
	signal triged : in std_logic;
	signal reset : in std_logic;
	signal adc_en : in std_logic;
	signal clk : in std_logic;
	signal drs_daq_a : out std_logic_vector(1 downto 0);
	signal drs_daq_srclk : out std_logic;
	signal drs_cal_raddr : out std_logic_vector(9 downto 0);
	signal drs_fifo_waddr : out std_logic_vector(9 downto 0);
	signal drs_fifo_write : out std_logic;
	signal drs_stop_addr : out std_logic_vector(9 downto 0);
	signal drs_read_done : out std_logic;
	signal drs_read_end : out std_logic;
	signal p_drs_rsrload : out std_logic_vector(3 downto 0)
); end component;

signal drs_daq_a : std_logic_vector(1 downto 0);
signal drs_daq_srclk : std_logic;
signal drs_read_done : std_logic;
signal ddrs_on : std_logic;

attribute iob : string;
attribute iob of drs_denable : signal is "true";
attribute iob of drs_srclk : signal is "true";
attribute iob of drs_srin : signal is "true";
attribute iob of drs_a : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then
		
		ddrs_on <= drs_on;
		drs_denable <= (others => ddrs_on);
		
		drs_srclk <= (others => idrs_srclk);
		drs_srin <= (others => idrs_srin);
		for ch in 0 to 3 loop
			drs_a(ch)(0) <= idrs_a(0);
			drs_a(ch)(1) <= idrs_a(1);
			drs_a(ch)(2) <= drs_su_a(2);
		end loop;

	end if;
	end process;

	idrs_srclk <= drs_su_srclk or drs_init_srclk or drs_daq_srclk;
	idrs_srin <= drs_su_a(2) or drs_daq_a(1);
	idrs_a(0) <= drs_su_a(0) or drs_init_a or drs_daq_a(0);
	idrs_a(1) <= drs_su_a(1) or drs_init_a or drs_daq_a(1);

	u1 : drs_ctrl_status port map(
		p_drs_pll_lock => p_drs_pll_lock,
		latch_pll_lock => latch_pll_lock,
		clk => clk,
		drs_pll_locked => drs_pll_locked
	); 

	u2 : drs_ctrl_setup port map(
		drs_on => drs_on,
		clk => clk,
		drs_su_a => drs_su_a,
		drs_su_srclk => drs_su_srclk,
		drs_init => drs_init
	); 

	u3 : drs_ctrl_init port map(
		drs_init => drs_init,
		drs_read_done => drs_read_done,
		clk => clk,
		drs_init_a => drs_init_a,
		drs_init_srclk => drs_init_srclk
	); 

	u4 : drs_ctrl_daq port map(
		p_drs_srout => p_drs_srout,
		triged => triged,
		reset => reset,
		adc_en => adc_en,
		clk => clk,
		drs_daq_a => drs_daq_a,
		drs_daq_srclk => drs_daq_srclk,
		drs_cal_raddr => drs_cal_raddr,
		drs_fifo_waddr => drs_fifo_waddr,
		drs_fifo_write => drs_fifo_write,
		drs_stop_addr => drs_stop_addr,
		drs_read_done => drs_read_done,
		drs_read_end => drs_read_end,
		p_drs_rsrload => p_drs_rsrload
	);
	
	myloop1 : for ch in 0 to 3 generate
		obuf_drs_denable : obuf port map(i => drs_denable(ch), o => p_drs_enable(ch));
		obuf_drs_dwrite : obuf port map(i => trig_armed, o => p_drs_dwrite(ch));
		obuf_drs_srclk : obuf port map(i => drs_srclk(ch), o => p_drs_srclk(ch));
		obuf_drs_srin : obuf port map(i => drs_srin(ch), o => p_drs_srin(ch));
		obuf_drs_a0 : obuf port map(i => drs_a(ch)(0), o => p_drs_a(ch)(0));
		obuf_drs_a1 : obuf port map(i => drs_a(ch)(1), o => p_drs_a(ch)(1));
		obuf_drs_a2 : obuf port map(i => drs_a(ch)(2), o => p_drs_a(ch)(2));
	end generate;

end Behavioral;

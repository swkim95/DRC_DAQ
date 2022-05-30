library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity cpld_spi_ctrl is port(
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
); end cpld_spi_ctrl;

architecture Behavioral of cpld_spi_ctrl is

component cpld_spi_set_mux port(
	signal hv_data : in hv_data_array;
	signal hv_write : in std_logic_vector(3 downto 0);
	signal thr_data : in thr_data_array;
	signal thr_write : in std_logic_vector(31 downto 0);
	signal dac_ofs_write : in std_logic;
	signal clk : in std_logic;
	signal hv_dac_data : out std_logic_vector(7 downto 0);
	signal hv_dac_write : out std_logic;
	signal thr_dac_data : out std_logic_vector(11 downto 0);
	signal thr_dac_ch : out std_logic_vector(2 downto 0);
	signal thr_dac_write : out std_logic;
	signal drs_dac_write : out std_logic;
	signal mux_sck : out std_logic;
	signal mux_sdi : out std_logic
); end component;

signal hv_dac_data : std_logic_vector(7 downto 0);
signal hv_dac_write : std_logic;
signal thr_dac_data : std_logic_vector(11 downto 0);
signal thr_dac_ch : std_logic_vector(2 downto 0);
signal thr_dac_write : std_logic;
signal drs_dac_write : std_logic;
signal mux_sck : std_logic;
signal mux_sdi : std_logic;

component dac_hv_ctrl port(
	signal hv_dac_data : in std_logic_vector(7 downto 0);
	signal hv_dac_write : in std_logic;
	signal clk : in std_logic;
	signal dac_hv_cs : out std_logic;
	signal dac_hv_sck : out std_logic;
	signal dac_hv_sdi : out std_logic
); end component;

signal dac_hv_cs : std_logic;
signal dac_hv_sck : std_logic;
signal dac_hv_sdi : std_logic;

component dac_thr_ctrl port(
	signal thr_dac_ch : in std_logic_vector(2 downto 0);
	signal thr_dac_data : in std_logic_vector(11 downto 0);
	signal thr_dac_write : in std_logic;
	signal clk : in std_logic;
	signal dac_thr_cs : out std_logic;
	signal dac_thr_sck : out std_logic;
	signal dac_thr_sdi : out std_logic
); end component;

signal dac_thr_cs : std_logic;
signal dac_thr_sck : std_logic;
signal dac_thr_sdi : std_logic;

component dac_drs_ctrl port(
	signal drs_dac_write : in std_logic;
	signal drs_rofs : in std_logic_vector(11 downto 0);
	signal drs_oofs : in std_logic_vector(11 downto 0);
	signal clk : in std_logic;
	signal dac_drs_cs : out std_logic;
	signal dac_drs_sck : out std_logic;
	signal dac_drs_sdi : out std_logic
); end component;

signal dac_drs_cs : std_logic;
signal dac_drs_sck : std_logic;
signal dac_drs_sdi : std_logic;

component cpld_spi_output port(
	signal mux_sck : in std_logic;
	signal mux_sdi : in std_logic;
	signal dac_hv_cs : in std_logic;
	signal dac_hv_sck : in std_logic;
	signal dac_hv_sdi : in std_logic;
	signal dac_thr_cs : in std_logic;
	signal dac_thr_sck : in std_logic;
	signal dac_thr_sdi : in std_logic;
	signal dac_drs_cs : in std_logic;
	signal dac_drs_sck : in std_logic;
	signal dac_drs_sdi : in std_logic;
	signal clk : in std_logic;
	signal p_cpld_cs : out std_logic;
	signal p_cpld_sck : out std_logic;
	signal p_cpld_sdi : out std_logic
); end component;

begin

	u1 : cpld_spi_set_mux port map(
		hv_data => hv_data,
		hv_write => hv_write,
		thr_data => thr_data,
		thr_write => thr_write,
		dac_ofs_write => dac_ofs_write,
		clk => clk,
		hv_dac_data => hv_dac_data,
		hv_dac_write => hv_dac_write,
		thr_dac_data => thr_dac_data,
		thr_dac_ch => thr_dac_ch,
		thr_dac_write => thr_dac_write,
		drs_dac_write => drs_dac_write,
		mux_sck => mux_sck,
		mux_sdi => mux_sdi
	);

	u2 : dac_hv_ctrl port map(
		hv_dac_data => hv_dac_data,
		hv_dac_write => hv_dac_write,
		clk => clk,
		dac_hv_cs => dac_hv_cs,
		dac_hv_sck => dac_hv_sck,
		dac_hv_sdi => dac_hv_sdi
	);

	u3 : dac_thr_ctrl port map(
		thr_dac_ch => thr_dac_ch,
		thr_dac_data => thr_dac_data,
		thr_dac_write => thr_dac_write,
		clk => clk,
		dac_thr_cs => dac_thr_cs,
		dac_thr_sck => dac_thr_sck,
		dac_thr_sdi => dac_thr_sdi
	);

	u4 : dac_drs_ctrl port map(
		drs_dac_write => drs_dac_write,
		drs_rofs => drs_rofs,
		drs_oofs => drs_oofs,
		clk => clk,
		dac_drs_cs => dac_drs_cs,
		dac_drs_sck => dac_drs_sck,
		dac_drs_sdi => dac_drs_sdi
	);

	u5 : cpld_spi_output port map(
		mux_sck => mux_sck,
		mux_sdi => mux_sdi,
		dac_hv_cs => dac_hv_cs,
		dac_hv_sck => dac_hv_sck,
		dac_hv_sdi => dac_hv_sdi,
		dac_thr_cs => dac_thr_cs,
		dac_thr_sck => dac_thr_sck,
		dac_thr_sdi => dac_thr_sdi,
		dac_drs_cs => dac_drs_cs,
		dac_drs_sck => dac_drs_sck,
		dac_drs_sdi => dac_drs_sdi,
		clk => clk,
		p_cpld_cs => p_cpld_cs,
		p_cpld_sck => p_cpld_sck,
		p_cpld_sdi => p_cpld_sdi
	);

end Behavioral;


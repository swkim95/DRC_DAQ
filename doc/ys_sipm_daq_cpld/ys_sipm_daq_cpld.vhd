library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity ys_sipm_daq_cpld is port(	
	signal p_clk : in std_logic;
	signal p_spi_cs : in std_logic;
	signal p_spi_sck : in std_logic;
	signal p_spi_sdi : in std_logic;
	signal p_spi_sdo : out std_logic;
	signal p_prom_cs : out std_logic;
	signal p_prom_sck : out std_logic;
	signal p_prom_sdi : out std_logic;
	signal p_prom_sdo : in std_logic;
	signal p_prom_wp : out std_logic;
	signal p_fpga_init : in std_logic;
	signal p_fpga_done : in std_logic;
	signal p_fpga_prog : out std_logic;
	signal p_fpga_cclk : out std_logic;
	signal p_fpga_din : out std_logic;
	signal p_mgt_def : in std_logic;
	signal p_mgt_loss : in std_logic;
	signal p_mgt_txdis : out std_logic;
	signal p_mgt_def_l : out std_logic;
	signal p_mgt_loss_l : out std_logic;
	signal p_mgt_txdis_l : in std_logic;
	signal p_cpld_cs : in std_logic;
	signal p_cpld_sck : in std_logic;
	signal p_cpld_sdi : in std_logic;
	signal p_dac_cs : out std_logic_vector(4 downto 0);
	signal p_dac_sck : out std_logic_vector(4 downto 0);
	signal p_dac_sdi : out std_logic_vector(4 downto 0);
	signal p_bias_cs : out std_logic_vector(3 downto 0);
	signal p_bias_sck : out std_logic_vector(3 downto 0);
	signal p_bias_sdi : out std_logic_vector(3 downto 0)
); end ys_sipm_daq_cpld;

architecture Behavioral of ys_sipm_daq_cpld is

component clock port(
	signal p_mgt_def : in std_logic;
	signal p_mgt_loss : in std_logic;
	signal p_mgt_txdis_l : in std_logic;
	signal p_clk : in std_logic;
	signal clk : out std_logic;
	signal p_mgt_def_l : out std_logic;
	signal p_mgt_loss_l : out std_logic;
	signal p_mgt_txdis : out std_logic
); end component;

signal clk : std_logic;

component get_command port(
	signal p_spi_cs : in std_logic;
	signal p_spi_sck : in std_logic;
	signal p_spi_sdi : in std_logic;
	signal p_fpga_init : in std_logic;
	signal p_fpga_done : in std_logic;
	signal prom_rdat : in std_logic;
	signal down_done : in std_logic;
	signal clk : in std_logic;
	signal download : out std_logic;
	signal calib : out std_logic;
	signal wprom_cs : out std_logic;
	signal wprom_sck : out std_logic;
	signal wprom_sdi : out std_logic;
	signal p_prom_wp : out std_logic;
	signal p_fpga_prog : out std_logic;
	signal p_spi_sdo : out std_logic
); end component;

signal download : std_logic;
signal calib : std_logic;
signal wprom_cs : std_logic;
signal wprom_sck : std_logic;
signal wprom_sdi : std_logic;

component download_fpga port(
	signal download : in std_logic;
	signal calib : in std_logic;
	signal prom_rdat : in std_logic;
	signal clk : in std_logic;
	signal rprom_cs : out std_logic;
	signal rprom_sck : out std_logic;
	signal rprom_sdi : out std_logic;
	signal down_done : out std_logic;
	signal p_fpga_cclk : out std_logic;
	signal p_fpga_din : out std_logic
); end component;

signal rprom_cs : std_logic;
signal rprom_sck : std_logic;
signal rprom_sdi : std_logic;
signal down_done : std_logic;

component flash_memory port(
	signal p_prom_sdo : in std_logic;
	signal wprom_cs : in std_logic;
	signal wprom_sck : in std_logic;
	signal wprom_sdi : in std_logic;
	signal rprom_cs : in std_logic;
	signal rprom_sck : in std_logic;
	signal rprom_sdi : in std_logic;
	signal clk : in std_logic;
	signal prom_rdat : out std_logic;
	signal p_prom_cs : out std_logic;
	signal p_prom_sck : out std_logic;
	signal p_prom_sdi : out std_logic
); end component;

signal prom_rdat : std_logic;

component fpga_serial port(
	signal p_cpld_cs : in std_logic;
	signal p_cpld_sck : in std_logic;
	signal p_cpld_sdi : in std_logic;
	signal clk : in std_logic;
	signal p_dac_cs : out std_logic_vector(4 downto 0);
	signal p_dac_sck : out std_logic_vector(4 downto 0);
	signal p_dac_sdi : out std_logic_vector(4 downto 0);
	signal p_bias_cs : out std_logic_vector(3 downto 0);
	signal p_bias_sck : out std_logic_vector(3 downto 0);
	signal p_bias_sdi : out std_logic_vector(3 downto 0)
); end component;

begin

	u1 : clock port map(
		p_mgt_def => p_mgt_def,
		p_mgt_loss => p_mgt_loss,
		p_mgt_txdis_l => p_mgt_txdis_l,
		p_clk => p_clk,
		clk => clk,
		p_mgt_def_l => p_mgt_def_l,
		p_mgt_loss_l => p_mgt_loss_l,
		p_mgt_txdis => p_mgt_txdis
	);

	u2 : get_command port map(
		p_spi_cs => p_spi_cs,
		p_spi_sck => p_spi_sck,
		p_spi_sdi => p_spi_sdi,
		p_fpga_init => p_fpga_init,
		p_fpga_done => p_fpga_done,
		prom_rdat => prom_rdat,
		down_done => down_done,
		clk => clk,
		download => download,
		calib => calib,
		wprom_cs => wprom_cs,
		wprom_sck => wprom_sck,
		wprom_sdi => wprom_sdi,
		p_prom_wp => p_prom_wp,
		p_fpga_prog => p_fpga_prog,
		p_spi_sdo => p_spi_sdo
	);

	u3 : download_fpga port map(
		download => download,
		calib => calib,
		prom_rdat => prom_rdat,
		clk => clk,
		rprom_cs => rprom_cs,
		rprom_sck => rprom_sck,
		rprom_sdi => rprom_sdi,
		down_done => down_done,
		p_fpga_cclk => p_fpga_cclk,
		p_fpga_din => p_fpga_din
	);

	u4 : flash_memory port map(
		p_prom_sdo => p_prom_sdo,
		wprom_cs => wprom_cs,
		wprom_sck => wprom_sck,
		wprom_sdi => wprom_sdi,
		rprom_cs => rprom_cs,
		rprom_sck => rprom_sck,
		rprom_sdi => rprom_sdi,
		clk => clk,
		prom_rdat => prom_rdat,
		p_prom_cs => p_prom_cs,
		p_prom_sck => p_prom_sck,
		p_prom_sdi => p_prom_sdi
	);

	u5 : fpga_serial port map(
		p_cpld_cs => p_cpld_cs,
		p_cpld_sck => p_cpld_sck,
		p_cpld_sdi => p_cpld_sdi,
		clk => clk,
		p_dac_cs => p_dac_cs,
		p_dac_sck => p_dac_sck,
		p_dac_sdi => p_dac_sdi,
		p_bias_cs => p_bias_cs,
		p_bias_sck => p_bias_sck,
		p_bias_sdi => p_bias_sdi
	);

end Behavioral;

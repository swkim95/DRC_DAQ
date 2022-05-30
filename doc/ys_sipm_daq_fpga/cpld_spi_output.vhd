library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity cpld_spi_output is port(
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
); end cpld_spi_output;

architecture Behavioral of cpld_spi_output is

signal cpld_cs : std_logic;
signal cpld_sck : std_logic;
signal cpld_sdi : std_logic;

signal pcpld_cs : std_logic;
signal pcpld_sck : std_logic;
signal pcpld_sdi : std_logic;

attribute iob : string;
attribute iob of cpld_cs : signal is "true";
attribute iob of cpld_sck : signal is "true";
attribute iob of cpld_sdi : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		pcpld_cs <= not(dac_hv_cs or dac_thr_cs or dac_drs_cs);
		pcpld_sck <= mux_sck or dac_hv_sck or dac_thr_sck or dac_drs_sck;
		pcpld_sdi <= mux_sdi or dac_hv_sdi or dac_thr_sdi or dac_drs_sdi;

		cpld_cs <= pcpld_cs;
		cpld_sck <= pcpld_sck;
		cpld_sdi <= pcpld_sdi;

	end if;
	end process;

	obuf_cpld_cs : obuf port map(i => cpld_cs, o => p_cpld_cs);
	obuf_cpld_sck : obuf port map(i => cpld_sck, o => p_cpld_sck);
	obuf_cpld_sdi : obuf port map(i => cpld_sdi, o => p_cpld_sdi);

end Behavioral;


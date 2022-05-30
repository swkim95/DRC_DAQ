library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity adc_capture is port(
	signal p_adc_dp : in std_logic_vector(31 downto 0);
	signal p_adc_dn : in std_logic_vector(31 downto 0);
	signal adc_en : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal adc_data : out adc_data_array
); end adc_capture;

architecture Behavioral of adc_capture is

component adc_input port(
	signal p_adc_dp : in std_logic_vector(31 downto 0);
	signal p_adc_dn : in std_logic_vector(31 downto 0);
	signal adc_in : out std_logic_vector(31 downto 0)
); end component;

signal adc_in : std_logic_vector(31 downto 0);

component adc_capture_ch port(
	signal adc_in : in std_logic;
	signal adc_en : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal adc_data : out std_logic_vector(11 downto 0)
); end component;

begin

	u1 : adc_input port map(
		p_adc_dp => p_adc_dp,
		p_adc_dn => p_adc_dn,
		adc_in => adc_in
	);
		
	myloop1 : for i in 0 to 31 generate
		u2 : adc_capture_ch port map(
			adc_in => adc_in(i),
			adc_en => adc_en,
			x2clk => x2clk,
			clk => clk,
			adc_data => adc_data(i)
		);
	end generate;

end Behavioral;


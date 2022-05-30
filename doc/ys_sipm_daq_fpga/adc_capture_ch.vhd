library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity adc_capture_ch is port(
	signal adc_in : in std_logic;
	signal adc_en : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal adc_data : out std_logic_vector(11 downto 0)
); end adc_capture_ch;

architecture Behavioral of adc_capture_ch is

signal adc_data_reg : std_logic_vector(11 downto 0);

signal xd : std_logic;
signal dxd : std_logic;
signal cd : std_logic_vector(1 downto 0);
signal sd : std_logic_vector(11 downto 0);

attribute IOB : string;
attribute IOB of xd : signal is "TRUE";

begin

	process(x2clk) begin
	if (x2clk'event and x2clk = '1') then
	
		xd <= adc_in;
		dxd <= xd;
	
	end if;
	end process;
	
	process(clk) begin
	if (clk'event and clk = '1') then
	
		cd(0) <= xd;
		cd(1) <= dxd;
		
		sd <= sd(9 downto 0) & cd;
		
		if (adc_en = '1') then
			adc_data_reg <= sd;
		end if;
	
	end if;
	end process;
	


	adc_data <= adc_data_reg;

end Behavioral;


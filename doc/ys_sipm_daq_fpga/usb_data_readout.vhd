library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity usb_data_readout is port(
	signal data_fifo_rdata : in std_logic_vector(31 downto 0);
	signal data_size : in std_logic_vector(12 downto 0);
	signal usb_rmux : in std_logic;
	signal clk : in std_logic;
	signal usb_ocd : out std_logic_vector(31 downto 0)
); end usb_data_readout;

architecture Behavioral of usb_data_readout is

signal usb_ocd_reg : std_logic_vector(31 downto 0);
signal pusb_ocd : std_logic_vector(31 downto 0);

attribute iob : string;
attribute iob of usb_ocd_reg : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then
		
		if (usb_rmux = '1') then
			pusb_ocd <= data_fifo_rdata;
		else
			pusb_ocd <= "0000000000000" & data_size & "000000";
		end if;
		
		usb_ocd_reg <= pusb_ocd;
	
	end if;
	end process;

	usb_ocd <= usb_ocd_reg;

end Behavioral;


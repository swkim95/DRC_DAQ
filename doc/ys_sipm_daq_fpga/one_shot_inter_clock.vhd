library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity one_shot_inter_clock is port(
	signal wsig : in std_logic;
	signal wclk : in std_logic;
	signal rclk : in std_logic;
	signal rsig : out std_logic
); end one_shot_inter_clock;

architecture Behavioral of one_shot_inter_clock is

signal rsig_reg : std_logic;
signal dwsig : std_logic;
signal d2wsig : std_logic;
signal sig_enable : std_logic;
signal p3rsig : std_logic;
signal p2rsig : std_logic;
signal prsig : std_logic;

begin

	process(wclk) begin
	if (wclk'event and wclk = '1') then
	
		dwsig <= wsig;
		d2wsig <= dwsig;
		sig_enable <= wsig or dwsig or d2wsig;

	end if;
	end process;

	process(rclk) begin
	if (rclk'event and rclk = '1') then
	
		p3rsig <= sig_enable;
		p2rsig <= p3rsig;
		prsig <= p2rsig;
		rsig_reg <= p2rsig and (not prsig);
	
	end if;
	end process;
	
	rsig <= rsig_reg;

end Behavioral;


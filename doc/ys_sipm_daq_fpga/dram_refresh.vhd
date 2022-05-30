library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_refresh is port(
	signal refresh_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal dram_fcs : out std_logic;
	signal dram_fras : out std_logic;
	signal dram_fcas : out std_logic
); end dram_refresh;

architecture Behavioral of dram_refresh is

signal dram_fcs_reg : std_logic;
signal dram_fras_reg : std_logic;
signal dram_fcas_reg : std_logic;

attribute keep:string;
attribute keep of dram_fcs_reg :signal is "true";
attribute keep of dram_fras_reg :signal is "true";
attribute keep of dram_fcas_reg :signal is "true";

begin

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then
	
		dram_fcs_reg <= refresh_dram;
		dram_fras_reg <= refresh_dram;
		dram_fcas_reg <= refresh_dram;

	end if;
	end process;
	
	dram_fcs <= dram_fcs_reg;
	dram_fras <= dram_fras_reg;
	dram_fcas <= dram_fcas_reg;

end Behavioral;

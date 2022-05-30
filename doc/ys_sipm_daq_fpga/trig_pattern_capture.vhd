library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity trig_pattern_capture is port(
	signal trig_ch : in std_logic;
	signal clk : in std_logic;
	signal trig_pattern : out std_logic
); end trig_pattern_capture;

architecture Behavioral of trig_pattern_capture is

signal trig_pattern_reg : std_logic;
signal cnt : std_logic_vector(4 downto 0);
signal clr : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		if (clr = '1') then
			trig_pattern_reg <= '0';
		elsif (trig_ch = '1') then
			trig_pattern_reg <= '1';
		end if;

		if (clr = '1') then
			cnt <= (others => '0');
		elsif (trig_pattern_reg = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(4) and (not cnt (3)) and (not cnt (2)) and (not cnt (1)) and (not cnt (0));

	end if;
	end process;

	trig_pattern <= trig_pattern_reg;

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity led_data is port(
	signal triged : in std_logic;
	signal response : in std_logic;
	signal sled : in std_logic;
	signal clk : in std_logic;
	signal enled : out std_logic
); end led_data;

architecture Behavioral of led_data is

signal enled_reg : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then
		
		if (triged = '1') then
			enled_reg <= '1';
		elsif (response = '1') then
			enled_reg <= '1';
		elsif (sled = '1') then
			enled_reg <= '0';
		end if;
		
	end if;
	end process;
	
	enled <= enled_reg;

end Behavioral;


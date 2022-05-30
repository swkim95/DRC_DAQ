library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity trigger_pulse_ch is port(
	signal cw : in std_logic_vector(3 downto 0);
	signal mod_nhit : in std_logic_vector(5 downto 0);
	signal triged : in std_logic;
	signal clk : in std_logic;
	signal tpulse : out std_logic_vector(5 downto 0)
); end trigger_pulse_ch;

architecture Behavioral of trigger_pulse_ch is

signal tpulse_reg : std_logic_vector(5 downto 0);

signal cen : std_logic;
signal cnt : std_logic_vector(3 downto 0) := (others => '0');
signal clr : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		if (clr = '1') then
			cen <= '0';
		elsif (triged = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		if (cnt = cw) then
			clr <= '1';
		else
			clr <= '0';
		end if;

		for i in 0 to 5 loop
			if (clr = '1') then
				tpulse_reg(i) <= '0';
			elsif (triged = '1') then
				tpulse_reg(i) <= mod_nhit(i);
			end if;
		end loop;
	
	end if;
	end process;
	
	tpulse <= tpulse_reg;

end Behavioral;


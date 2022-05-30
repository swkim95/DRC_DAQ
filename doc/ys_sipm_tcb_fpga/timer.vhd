library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity timer is port(
	signal reset_timer : in std_logic;
	signal clk : in std_logic;
	signal tcb_ftime : out std_logic_vector(6 downto 0);
	signal tcb_ctime : out std_logic_vector(47 downto 0)
); end timer;

architecture Behavioral of timer is

signal tcb_ctime_reg : std_logic_vector(47 downto 0);
signal tcb_ftime_reg : std_logic_vector(6 downto 0);

signal ftc : std_logic;
signal rsten : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		ftc <= tcb_ftime_reg(6) and (not tcb_ftime_reg(5)) and tcb_ftime_reg(4) and tcb_ftime_reg(3) 
		   and (not tcb_ftime_reg(2)) and (not tcb_ftime_reg(1)) and (not tcb_ftime_reg(0));

		if (reset_timer = '1') then
			rsten <= '1';
		elsif (ftc = '1') then
			rsten <= '0';
		end if;
			 
		if (ftc = '1') then
			tcb_ftime_reg <= (others => '0');
		else
			tcb_ftime_reg <= tcb_ftime_reg + 1;
		end if;
		
		if (ftc = '1') then
			if (rsten = '1') then
				tcb_ctime_reg <= (others => '0');
			else
				tcb_ctime_reg <= tcb_ctime_reg + 1;
			end if;
		end if;
		
	end if;
	end process;

	tcb_ctime <= tcb_ctime_reg;
	tcb_ftime <= tcb_ftime_reg;

end Behavioral;


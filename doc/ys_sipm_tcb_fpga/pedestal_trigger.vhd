library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity pedestal_trigger is port(
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal ptrig_interval : in std_logic_vector(15 downto 0);
	signal run : in std_logic;
	signal clr_ptrig : in std_logic;
	signal clk : in std_logic;
	signal ptrig : out std_logic
); end pedestal_trigger;

architecture Behavioral of pedestal_trigger is

signal ptrig_reg : std_logic;
signal usec_tick : std_logic;
signal usec_cnt : std_logic_vector(9 downto 0);
signal msec_tick : std_logic;
signal msec_cnt : std_logic_vector(15 downto 0);
signal sptrig : std_logic;
signal dsptrig : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		usec_tick <= (not tcb_ftime(6)) and (not tcb_ftime(5)) and (not tcb_ftime(4))
		         and (not tcb_ftime(3)) and (not tcb_ftime(2)) and (not tcb_ftime(1)) and tcb_ftime(0);
					
		if (msec_tick = '1') then
			usec_cnt <= (others => '0');
		elsif (usec_tick = '1') then
			usec_cnt <= usec_cnt + 1;
		end if;
		
		msec_tick <= usec_tick and usec_cnt(9) and usec_cnt(8)
		         and usec_cnt(7) and usec_cnt(6) and usec_cnt(5) and (not usec_cnt(4))
		         and (not usec_cnt(3)) and usec_cnt(2) and usec_cnt(1) and usec_cnt(0);

		if (clr_ptrig = '1') then
			msec_cnt <= (others => '0');
		elsif (sptrig = '1') then
			msec_cnt <= (others => '0');
		elsif (msec_tick = '1') then
			msec_cnt <= msec_cnt + 1;
		end if;
		
		if (msec_cnt = ptrig_interval) then
			sptrig <= '1';
		else
			sptrig <= '0';
		end if;
		
		dsptrig <= sptrig;
		ptrig_reg <= run and sptrig and (not dsptrig);

	end if;
	end process;
	
	ptrig <= ptrig_reg;

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity tcb_send_timer is port(
	signal tcb_cdat : in std_logic_vector(7 downto 0);
	signal tcb_com : in std_logic;
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(47 downto 0);
	signal clk : in std_logic;
	signal send_com : out std_logic_vector(7 downto 0);
	signal send_data : out std_logic_vector(47 downto 0)
); end tcb_send_timer;

architecture Behavioral of tcb_send_timer is

signal send_com_reg : std_logic_vector(7 downto 0);
signal send_data_reg : std_logic_vector(47 downto 0);

signal ptcb_ctime : std_logic_vector(47 downto 0);
signal sendpkt : std_logic;
signal com_data : std_logic_vector(7 downto 0);
signal encom : std_logic;
signal isend_com : std_logic_vector(7 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		ptcb_ctime <= tcb_ctime + 2;

		sendpkt <= tcb_ftime(6) and (not tcb_ftime(5)) and tcb_ftime(4) and tcb_ftime(3)
		       and (not tcb_ftime(2)) and (not tcb_ftime(1)) and tcb_ftime(0);
				 
		if (tcb_com = '1') then
			com_data <= tcb_cdat;
		end if;
		
		if (tcb_com = '1') then
			encom <= '1';
		elsif (sendpkt = '1') then
			encom <= '0';
		end if;
		
		if (sendpkt = '1') then
			send_com_reg <= isend_com;
			send_data_reg <= ptcb_ctime;
		end if;
	
	end if;
	end process;
	
	myloop1 : for i in 0 to 7 generate
		isend_com(i) <= encom and com_data(i);
	end generate;
	
	send_com <= send_com_reg;
	send_data <= send_data_reg;

end Behavioral;


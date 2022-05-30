library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity tcb_receiver is port(
	signal tcbin_timer : in std_logic_vector(7 downto 0);
	signal tcbin_trig : in std_logic_vector(7 downto 0);
	signal fcnt : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal tcb_mid : out std_logic_vector(7 downto 0);
	signal tcb_com : out std_logic_vector(5 downto 1);
	signal tcb_din_timer : out std_logic_vector(47 downto 0);
	signal tcb_din_trig_type : out std_logic_vector(1 downto 0);
	signal tcb_din_trig_ch : out std_logic_vector(4 downto 0);
	signal tcb_din_trig_addr : out std_logic_vector(5 downto 0);
	signal tcb_din_trig_data : out std_logic_vector(27 downto 0);
	signal tcb_recv : out std_logic
); end tcb_receiver;

architecture Behavioral of tcb_receiver is

signal tcb_mid_reg : std_logic_vector(7 downto 0);
signal tcb_com_reg : std_logic_vector(5 downto 1);
signal tcb_din_timer_reg : std_logic_vector(47 downto 0);
signal tcb_din_trig_type_reg : std_logic_vector(1 downto 0);
signal tcb_din_trig_ch_reg : std_logic_vector(4 downto 0);
signal tcb_din_trig_addr_reg : std_logic_vector(5 downto 0);
signal tcb_din_trig_data_reg : std_logic_vector(27 downto 0);
signal tcb_recv_reg : std_logic;

signal enmid : std_logic;
signal endata : std_logic_vector(5 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		enmid <= (not fcnt(6)) and (not fcnt(5)) and fcnt(4)
		     and (not fcnt(3)) and fcnt(2) and (not fcnt(1)) and fcnt(0);
		
		endata(0) <= (not fcnt(6)) and (not fcnt(5)) and fcnt(4)
		         and fcnt(3) and fcnt(2) and fcnt(1) and fcnt(0);
		
		endata(1) <= (not fcnt(6)) and fcnt(5) and (not fcnt(4))
	            and fcnt(3) and (not fcnt(2)) and (not fcnt(1)) and fcnt(0);
		
		endata(2) <= (not fcnt(6)) and fcnt(5) and fcnt(4)
	            and (not fcnt(3)) and (not fcnt(2)) and fcnt(1) and fcnt(0);
		
		endata(3) <= (not fcnt(6)) and fcnt(5) and fcnt(4)
	            and fcnt(3) and fcnt(2) and (not fcnt(1)) and fcnt(0);
		
		endata(4) <= fcnt(6) and (not fcnt(5)) and (not fcnt(4))
	            and (not fcnt(3)) and fcnt(2) and fcnt(1) and fcnt(0);
		
		endata(5) <= fcnt(6) and (not fcnt(5)) and fcnt(4)
	            and (not fcnt(3)) and (not fcnt(2)) and (not fcnt(1)) and fcnt(0);
		
		if (enmid = '1') then
			tcb_mid_reg <= tcbin_trig;
			tcb_com_reg <= tcbin_timer(5 downto 1);
		end if;
		
		for i in 0 to 5 loop
			if (endata(i) = '1') then
				tcb_din_timer_reg(8 * i + 7 downto 8 * i) <= tcbin_timer;
			end if;
		end loop;

		if (endata(0) = '1') then
			tcb_din_trig_addr_reg <= tcbin_trig(5 downto 0);
		end if;

		if (endata(1) = '1') then
			tcb_din_trig_type_reg <= tcbin_trig(7 downto 6);
			tcb_din_trig_ch_reg <= tcbin_trig(4 downto 0);
		end if;

		if (endata(2) = '1') then
			tcb_din_trig_data_reg(7 downto 0) <= tcbin_trig;
		end if;

		if (endata(3) = '1') then
			tcb_din_trig_data_reg(15 downto 8) <= tcbin_trig;
		end if;

		if (endata(4) = '1') then
			tcb_din_trig_data_reg(23 downto 16) <= tcbin_trig;
		end if;

		if (endata(5) = '1') then
			tcb_din_trig_data_reg(27 downto 24) <= tcbin_trig(3 downto 0);
		end if;

		tcb_recv_reg <= fcnt(6) and (not fcnt(5)) and fcnt(4)
		            and fcnt(3) and (not fcnt(2)) and (not fcnt(1)) and fcnt(0);
	
	end if;
	end process;

	tcb_mid <= tcb_mid_reg;
	tcb_com <= tcb_com_reg;
	tcb_din_timer <= tcb_din_timer_reg;
	tcb_din_trig_type <= tcb_din_trig_type_reg;
	tcb_din_trig_ch <= tcb_din_trig_ch_reg;
	tcb_din_trig_addr <= tcb_din_trig_addr_reg;
	tcb_din_trig_data <= tcb_din_trig_data_reg;
	tcb_recv <= tcb_recv_reg;

end Behavioral;

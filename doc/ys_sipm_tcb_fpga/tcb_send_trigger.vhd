library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity tcb_send_trigger is port(
	signal tcb_mid : in std_logic_vector(7 downto 0);
	signal tcb_addr : in std_logic_vector(13 downto 0);
	signal tcb_wdat : in std_logic_vector(31 downto 0);
	signal tcb_write : in std_logic;
	signal tcb_read : in std_logic;
	signal trig_type : in std_logic_vector(1 downto 0);
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(47 downto 0);
	signal run_number : in std_logic_vector(15 downto 0);
	signal tcb_trig : in std_logic;
	signal run : in std_logic;
	signal reset : in std_logic;
	signal clk : in std_logic;
	signal send_mid : out std_logic_vector(7 downto 0);
	signal send_addr : out std_logic_vector(15 downto 0);
	signal send_data : out std_logic_vector(31 downto 0);
	signal trgdat : out std_logic
); end tcb_send_trigger;

architecture Behavioral of tcb_send_trigger is

signal send_mid_reg : std_logic_vector(7 downto 0);
signal send_addr_reg : std_logic_vector(15 downto 0);
signal send_data_reg : std_logic_vector(31 downto 0);
signal trig_sr : std_logic_vector(105 downto 0) := (others => '0');

signal sendpkt : std_logic;
signal tcb_cycle : std_logic;
signal mux : std_logic;
signal wrd_addr : std_logic_vector(23 downto 0);
signal write_data : std_logic_vector(31 downto 0);
signal enwrite : std_logic;
signal enread : std_logic;
signal isend_mid : std_logic_vector(7 downto 0);
signal isend_addr : std_logic_vector(15 downto 0);
signal isend_data : std_logic_vector(31 downto 0);
signal trig_number : std_logic_vector(31 downto 0);
signal cen : std_logic;
signal cnt : std_logic_vector(6 downto 0) := (others => '0');
signal clr : std_logic;
signal load : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		sendpkt <= tcb_ftime(6) and (not tcb_ftime(5)) and tcb_ftime(4) and tcb_ftime(3)
		       and (not tcb_ftime(2)) and (not tcb_ftime(1)) and tcb_ftime(0);
				 
		if ((tcb_write = '1') or (tcb_read = '1')) then
			wrd_addr <= tcb_mid & tcb_read & tcb_cycle & tcb_addr;
		end if;
		
		if (tcb_write = '1') then
			write_data <= tcb_wdat;
		end if;

		if (tcb_write = '1') then
			enwrite <= not run;
		elsif (sendpkt = '1') then
			enwrite <= '0';
		end if;
				 
		if (tcb_read = '1') then
			enread <= not run;
		elsif (sendpkt = '1') then
			enread <= '0';
		end if;

		if (sendpkt = '1') then
			send_mid_reg <= isend_mid;
			send_addr_reg <= isend_addr;
			send_data_reg <= isend_data;
		end if;
	
		if (reset = '1') then
			trig_number <= (others => '0');
		elsif (clr = '1') then
			trig_number <= trig_number + 1;
		end if;

		if (clr = '1') then
			cen <= '0';
		elsif (tcb_trig = '1') then
			cen <= '1';
		end if;

		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(6) and cnt(5) and (not cnt(4)) and cnt(3) 
		   and (not cnt(2)) and (not cnt(1)) and (not cnt(0));
		
		if (load = '1') then
			trig_sr <= run_number & trig_number & tcb_ctime & tcb_ftime & trig_type & '1';
		elsif (cen = '1') then
			trig_sr <= '0' & trig_sr(105 downto 1);
		end if;

	end if;
	end process;
	
	tcb_cycle <= tcb_write or tcb_read;
	
	mux <= enwrite or enread;
	
	isend_mid <= wrd_addr(23 downto 16) when mux = '1'
	        else "10110101";

	isend_addr <= wrd_addr(15 downto 0) when mux = '1'
				else "1011010110110101";
			  
	isend_data <= write_data when mux = '1'
				else "10110101101101011011010110110101";

	load <= tcb_trig and (not cen);
	
	send_mid <= send_mid_reg;
	send_addr <= send_addr_reg;
	send_data <= send_data_reg;
	trgdat <= trig_sr(0);

end Behavioral;


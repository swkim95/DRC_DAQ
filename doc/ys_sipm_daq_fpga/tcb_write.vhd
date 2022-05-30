library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity tcb_write is port(
	signal trig_nhit : in std_logic_vector(5 downto 0);
	signal local_trig : in std_logic;
	signal reg_rdata : in std_logic_vector(31 downto 0);
	signal reg_rd : in std_logic;
	signal fcnt : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal mod_type : out std_logic;
	signal mod_din : out std_logic_vector(31 downto 0);
	signal trgdat : out std_logic
); end tcb_write;

architecture Behavioral of tcb_write is

signal mod_type_reg : std_logic;
signal mod_din_reg : std_logic_vector(31 downto 0);

signal sendpkt : std_logic;
signal enread : std_logic;
signal imod_din : std_logic_vector(31 downto 0);
signal cen : std_logic;
signal cnt : std_logic_vector(2 downto 0);
signal clr : std_logic;
signal trig_sr : std_logic_vector(6 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		sendpkt <= fcnt(6) and (not fcnt(5)) and fcnt(4) and fcnt(3)
		       and (not fcnt(2)) and (not fcnt(1)) and fcnt(0);
			  
		if (reg_rd = '1') then
			enread <= '1';
		elsif (sendpkt = '1') then
			enread <= '0';
		end if;
		
		if (sendpkt = '1') then
			mod_type_reg <= enread;
			mod_din_reg <= imod_din;
		end if;

		if (clr = '1') then
			cen <= '0';
		elsif (local_trig = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(2) and (not cnt(1)) and cnt(0);
		
		if (cen = '1') then
			trig_sr <= '0' & trig_sr(6 downto 1);
		elsif (local_trig = '1') then
			trig_sr <= trig_nhit & '1';
		end if;


	end if;
	end process;
	
	imod_din <= reg_rdata when enread = '1'
			 else "10110101101101011011010110110101";

	mod_type <= mod_type_reg;
	mod_din <= mod_din_reg;
	trgdat <= trig_sr(0);

end Behavioral;


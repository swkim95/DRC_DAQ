library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity tcb_receiver is port(
	signal sidat : in std_logic;
	signal tcbin : in std_logic_vector(7 downto 0);
	signal fcnt : in std_logic_vector(6 downto 0);
	signal linked : in std_logic;
	signal run : in std_logic;
	signal clk : in std_logic;
	signal mod_mid : out std_logic_vector(7 downto 0);
	signal triged : out std_logic;
	signal mod_nhit : out std_logic_vector(5 downto 0);
	signal mod_rdat : out std_logic_vector(31 downto 0);
	signal response : out std_logic
); end tcb_receiver;

architecture Behavioral of tcb_receiver is

signal mod_mid_reg : std_logic_vector(7 downto 0);
signal triged_reg : std_logic;
signal mod_nhit_reg : std_logic_vector(5 downto 0);
signal mod_rdat_reg : std_logic_vector(31 downto 0);
signal response_reg : std_logic;

signal enmid : std_logic;
signal entype : std_logic;
signal mod_type : std_logic_vector(1 downto 0);
signal enresp : std_logic_vector(3 downto 0);
signal encsum : std_logic;
signal cen : std_logic;
signal cnt : std_logic_vector(2 downto 0);
signal clr : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		enmid <= (not run) and (not fcnt(6)) and (not fcnt(5)) and fcnt(4)
		     and (not fcnt(3)) and fcnt(2) and (not fcnt(1)) and fcnt(0);
		
		if (linked = '0') then
			mod_mid_reg <= (others => '0');
		elsif (enmid = '1') then
			mod_mid_reg <= tcbin;
		end if;

		entype <= (not fcnt(6)) and (not fcnt(5)) and fcnt(4)
		      and fcnt(3) and fcnt(2) and fcnt(1) and fcnt(0);
		
		if (linked = '0') then
			mod_type <= (others => '0');
		elsif (entype = '1') then
			mod_type <= tcbin(1 downto 0);
		end if;
		
		enresp(0) <= mod_type(1) and mod_type(0)
					and (not fcnt(6)) and fcnt(5) and (not fcnt(4))
	            and fcnt(3) and (not fcnt(2)) and (not fcnt(1)) and fcnt(0);
		
		enresp(1) <= mod_type(1) and mod_type(0)
					and (not fcnt(6)) and fcnt(5) and fcnt(4)
	            and (not fcnt(3)) and (not fcnt(2)) and fcnt(1) and fcnt(0);
		
		enresp(2) <= mod_type(1) and mod_type(0)
					and (not fcnt(6)) and fcnt(5) and fcnt(4)
	            and fcnt(3) and fcnt(2) and (not fcnt(1)) and fcnt(0);
		
		enresp(3) <= mod_type(1) and mod_type(0)
					and fcnt(6) and (not fcnt(5)) and (not fcnt(4))
	            and (not fcnt(3)) and fcnt(2) and fcnt(1) and fcnt(0);
		
		if (enresp(0) = '1') then
			mod_rdat_reg(7 downto 0) <= tcbin;
		end if;

		if (enresp(1) = '1') then
			mod_rdat_reg(15 downto 8) <= tcbin;
		end if;

		if (enresp(2) = '1') then
			mod_rdat_reg(23 downto 16) <= tcbin;
		end if;

		if (enresp(3) = '1') then
			mod_rdat_reg(31 downto 24) <= tcbin;
		end if;

		encsum <= fcnt(6) and (not fcnt(5)) and fcnt(4)
		      and (not fcnt(3)) and fcnt(2) and fcnt(1) and fcnt(0);
		
		response_reg <= (not run) and linked and encsum and mod_type(1) and mod_type(0);
		
		if (clr = '1') then
			cen <= '0';
		elsif (sidat = '1') then
			cen <= linked and run;
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(2) and (not cnt(1)) and (not cnt(0));
		
		triged_reg <= clr;
		
		if (cen = '1') then
			mod_nhit_reg <= sidat & mod_nhit_reg(5 downto 1);
		end if;
		
	end if;
	end process;
	
	mod_mid <= mod_mid_reg;
	triged <= triged_reg;
	mod_nhit <= mod_nhit_reg;
	mod_rdat <= mod_rdat_reg;
	response <= response_reg;

end Behavioral;


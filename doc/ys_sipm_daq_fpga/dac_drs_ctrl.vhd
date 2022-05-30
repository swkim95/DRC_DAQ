library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dac_drs_ctrl is port(
	signal drs_dac_write : in std_logic;
	signal drs_rofs : in std_logic_vector(11 downto 0);
	signal drs_oofs : in std_logic_vector(11 downto 0);
	signal clk : in std_logic;
	signal dac_drs_cs : out std_logic;
	signal dac_drs_sck : out std_logic;
	signal dac_drs_sdi : out std_logic
); end dac_drs_ctrl;

architecture Behavioral of dac_drs_ctrl is

signal dac_drs_cs_reg : std_logic := '0';
signal dac_drs_sck_reg : std_logic;

signal cen : std_logic;
signal cnt : std_logic_vector(9 downto 0);
signal clr : std_logic;
signal sdcs : std_logic;
signal edcs : std_logic;
signal load : std_logic;
signal shift : std_logic;
signal sdat : std_logic_vector(47 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		if (clr = '1') then
			cen <= '0';
		elsif (drs_dac_write = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(9) and (not cnt(8)) and cnt(7) and cnt(6) and cnt(5) 
		   and cnt(4) and cnt(3) and cnt(2) and cnt(1) and (not cnt(0));
		
		sdcs <= (not cnt(4)) and (not cnt(3)) and (not cnt(2)) and (not cnt(1)) and cnt(0);
		
		edcs <= cnt(7) and cnt(6) and cnt(5) and cnt(4) 
			 and cnt(3) and cnt(2) and (not cnt(1)) and cnt(0);
		
		load <= drs_dac_write;
		shift <= cnt(3) and cnt(2) and cnt(1) and cnt(0);
		
		if (edcs = '1') then
			dac_drs_cs_reg <= '0';
		elsif (sdcs = '1') then
			dac_drs_cs_reg <= '1';
		end if;
		
		dac_drs_sck_reg <= cnt(3);
		
		if (load = '1') then
			sdat <= "10010000000000010001" & drs_oofs & "1000" & drs_rofs;
		elsif (shift = '1') then
			sdat <= sdat(46 downto 0) & '0';
		end if;
		
	end if;
	end process;
	
	dac_drs_cs <= dac_drs_cs_reg;
	dac_drs_sck <= dac_drs_sck_reg;
	dac_drs_sdi <= sdat(47);

end Behavioral;

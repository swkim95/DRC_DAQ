library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dac_hv_ctrl is port(
	signal hv_dac_data : in std_logic_vector(7 downto 0);
	signal hv_dac_write : in std_logic;
	signal clk : in std_logic;
	signal dac_hv_cs : out std_logic;
	signal dac_hv_sck : out std_logic;
	signal dac_hv_sdi : out std_logic
); end dac_hv_ctrl;

architecture Behavioral of dac_hv_ctrl is

signal dac_hv_cs_reg : std_logic;
signal dac_hv_sck_reg : std_logic;
signal dac_hv_sdi_reg : std_logic;

signal cen : std_logic;
signal cnt : std_logic_vector(9 downto 0);
signal clr : std_logic;
signal shift : std_logic;
signal sd : std_logic_vector(7 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		if (clr = '1') then
			cen <= '0';
		elsif (hv_dac_write = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(9) and cnt(8) and cnt(7) and cnt(6) and cnt(5)
		   and cnt(4) and cnt(3) and cnt(2) and cnt(1) and (not cnt(0));
			
		shift <= cnt(6) and cnt(5) and cnt(4) and cnt(3) 
  		     and cnt(2) and cnt(1) and (not cnt(0));
		
		if (hv_dac_write = '1') then
			sd <= not hv_dac_data;
		elsif (shift = '1') then
			sd <= sd(6 downto 0) & '0';
		end if;
		
		dac_hv_cs_reg <= cen;
		dac_hv_sck_reg <= cnt(6);
		dac_hv_sdi_reg <= sd(7);
	
	end if;
	end process;

	dac_hv_cs <= dac_hv_cs_reg;
	dac_hv_sck <= dac_hv_sck_reg;
	dac_hv_sdi <= dac_hv_sdi_reg;

end Behavioral;


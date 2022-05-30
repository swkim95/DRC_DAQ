library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity download_fpga is port(
	signal download : in std_logic;
	signal calib : in std_logic;
	signal prom_rdat : in std_logic;
	signal clk : in std_logic;
	signal rprom_cs : out std_logic;
	signal rprom_sck : out std_logic;
	signal rprom_sdi : out std_logic;
	signal down_done : out std_logic;
	signal p_fpga_cclk : out std_logic;
	signal p_fpga_din : out std_logic
); end download_fpga;

architecture Behavioral of download_fpga is

signal rprom_cs_reg : std_logic;
signal rprom_sck_reg : std_logic;
signal rprom_sdi_reg : std_logic;
signal down_done_reg : std_logic := '1';
signal fpga_cclk : std_logic;
signal fpga_din : std_logic;

signal cen : std_logic := '0';
signal cnt : std_logic_vector(25 downto 0) := (others => '0');
signal clr : std_logic := '0';
signal sdown : std_logic;
signal endown : std_logic;
signal dclr : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		if (clr = '1') then
			cen <= '0';
		elsif (download = '1') then
			cen <= '1';
		end if;

		down_done_reg <= not(cen);
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(25) and (not cnt(24))
		   and cnt(23) and cnt(22) and (not cnt(21)) and cnt(20)
		   and cnt(19) and cnt(18) and cnt(17) and cnt(16)
		   and (not cnt(15)) and (not cnt(14)) and cnt(13) and cnt(12)
			and cnt(11) and cnt(10) and (not cnt(9)) and cnt(8)
			and (not cnt(7)) and (not cnt(6)) and (not cnt(5)) and cnt(4)
			and (not cnt(3)) and (not cnt(2)) and (not cnt(1)) and (not cnt(0));
		dclr <= clr;

		rprom_cs_reg <= cen;
		rprom_sck_reg <= cnt(0);
		rprom_sdi_reg <= (not cnt(25)) and (not cnt(24)) 
		             and (not cnt(23)) and (not cnt(22)) and (not cnt(21)) and (not cnt(20)) 
			 			 and (not cnt(19)) and (not cnt(18)) and (not cnt(17)) and (not cnt(16)) 
		 				 and (not cnt(15)) and (not cnt(14)) and (not cnt(13)) and (not cnt(12)) 
						 and (not cnt(11)) and (not cnt(10)) and (not cnt(9)) and (not cnt(8)) 
						 and (not cnt(7)) and (not cnt(6)) and (not cnt(5)) 
						 and (((not cnt(4)) and cnt(3) and cnt(2))
						  or (cnt(4) and cnt(3) and cnt(2) and (not cnt(1)))); 

		sdown <= (not cnt(25)) and (not cnt(24)) 
			  and (not cnt(23)) and (not cnt(22)) and (not cnt(21)) and (not cnt(20)) 
			  and (not cnt(19)) and (not cnt(18)) and (not cnt(17)) and (not cnt(16)) 
			  and (not cnt(15)) and (not cnt(14)) and (not cnt(13)) and (not cnt(12)) 
			  and (not cnt(11)) and (not cnt(10)) and (not cnt(9)) and (not cnt(8)) 
			  and (not cnt(7)) and cnt(6) and (not cnt(5)) and (not cnt(4)) 
			  and (not cnt(3)) and (not cnt(2)) and cnt(1) and (not cnt(0));

		if (dclr = '1') then
			endown <= '0';
		elsif (sdown = '1') then
			endown <= '1';
		end if;
		
		fpga_cclk <= rprom_sck_reg and endown;
		fpga_din <= (prom_rdat and endown) or calib;

	end if;
	end process;

	rprom_cs <= rprom_cs_reg;
	rprom_sck <= rprom_sck_reg;
	rprom_sdi <= rprom_sdi_reg;
	down_done <= down_done_reg;

	obuf_fpga_cclk : obuf port map(i => fpga_cclk, o => p_fpga_cclk);
	obuf_fpga_din : obuf port map(i => fpga_din, o => p_fpga_din);

end Behavioral;


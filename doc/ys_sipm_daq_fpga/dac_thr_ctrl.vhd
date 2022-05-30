library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dac_thr_ctrl is port(
	signal thr_dac_ch : in std_logic_vector(2 downto 0);
	signal thr_dac_data : in std_logic_vector(11 downto 0);
	signal thr_dac_write : in std_logic;
	signal clk : in std_logic;
	signal dac_thr_cs : out std_logic;
	signal dac_thr_sck : out std_logic;
	signal dac_thr_sdi : out std_logic
); end dac_thr_ctrl;

architecture Behavioral of dac_thr_ctrl is

signal dac_thr_cs_reg : std_logic;
signal dac_thr_sck_reg : std_logic;
signal dac_thr_sdi_reg : std_logic;

signal dwdac : std_logic;
signal load : std_logic;
signal sdac : std_logic;
signal cen : std_logic;
signal cnt : std_logic_vector(7 downto 0) := (others => '0');
signal clr : std_logic;
signal shift : std_logic;
signal sdat : std_logic_vector(47 downto 0);
signal rcnt : std_logic_vector(1 downto 0) := "00";
signal dclr : std_logic;
signal d2clr : std_logic;
signal rcen : std_logic;
signal rclr : std_logic;
signal isdat : std_logic_vector(47 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		load <= thr_dac_write;
		sdac <= thr_dac_write or rcen;
		
		if (clr = '1') then
			cen <= '0';
		elsif (sdac = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(7) and cnt(6) and cnt(5) and cnt(4) 
		   and cnt(3) and cnt(2) and cnt(1) and (not (cnt(0)));

		shift <= cnt(3) and cnt(2) and cnt(1) and (not (cnt(0)));
		
		if (load = '1') then
			sdat <= isdat;
		elsif (shift = '1') then
			sdat <= sdat(46 downto 0) & '0';
		end if;
		
		dac_thr_cs_reg <= cen;
		dac_thr_sck_reg <= cnt(3);
		dac_thr_sdi_reg <= sdat(47);
	
		if (rclr = '1') then
			rcnt <= (others => '0');
		elsif (clr = '1') then
			rcnt <= rcnt + 1;
		end if;
		
		dclr <= clr;
		d2clr <= dclr;
		rcen <= (not(rcnt(1) and rcnt(0))) and d2clr;
		rclr <= rcnt(1) and rcnt(0) and d2clr;
	
	end if;
	end process;

	isdat <= "100100000000000010000000000001000" & thr_dac_ch & thr_dac_data;

	dac_thr_cs <= dac_thr_cs_reg;
	dac_thr_sck <= dac_thr_sck_reg;
	dac_thr_sdi <= dac_thr_sdi_reg;

end Behavioral;

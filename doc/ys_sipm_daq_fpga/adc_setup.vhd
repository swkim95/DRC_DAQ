library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity adc_setup is port(
	signal adc_saddr : in std_logic_vector(7 downto 0);
	signal adc_sdata : in std_logic_vector(7 downto 0);
	signal adc_write : in std_logic;
	signal clk : in std_logic;
	signal p_adc_cs : out std_logic_vector(3 downto 0);
	signal p_adc_sck : out std_logic_vector(3 downto 0);
	signal p_adc_sdi : out std_logic_vector(3 downto 0)
); end adc_setup;

architecture Behavioral of adc_setup is

signal adc_cs : std_logic_vector(3 downto 0);
signal adc_sck : std_logic_vector(3 downto 0);
signal adc_sdi : std_logic_vector(3 downto 0);
signal adc_sde : std_logic_vector(3 downto 0);
signal cen : std_logic;
signal cnt : std_logic_vector(6 downto 0);
signal clr : std_logic;
signal padc_cs : std_logic;
signal padc_sck : std_logic;
signal padc_sde : std_logic;
signal load : std_logic;
signal shift : std_logic;
signal sd :std_logic_vector(23 downto 0);

attribute iob : string;
attribute iob of adc_cs : signal is "true";
attribute iob of adc_sck : signal is "true";
attribute iob of adc_sdi : signal is "true";
attribute iob of adc_sde : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		if (clr = '1') then
			cen <= '0';
		elsif (adc_write = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(6) and (not cnt(5)) and cnt(4)
		   and cnt(3) and cnt(2) and cnt(1) and cnt(0);
			
		padc_cs <= not cen;
		adc_cs <= (others => padc_cs);
		
		padc_sde <= not cen;
		adc_sde <= (others => padc_sde);
		
		padc_sck <= cnt(1);
		adc_sck <= (others => padc_sck);
		
		load <= adc_write;
		shift <= cnt(0) and cnt(1);
		
		if (load = '1') then
			sd <= "00000000" & adc_saddr & adc_sdata;
		elsif (shift = '1') then
			sd <= sd(22 downto 0) & '0';
		end if;

		adc_sdi <= (others => sd(23));
	
	end if;
	end process;

	myloop1 : for ch in 0 to 3 generate
		obuf_adc_cs : obuf port map(i => adc_cs(ch), o => p_adc_cs(ch));
		obuf_adc_sck : obuf port map(i => adc_sck(ch), o => p_adc_sck(ch));
		obuft_adc_sdi : obuft port map(i => adc_sdi(ch), t => adc_sde(ch), o => p_adc_sdi(ch));
	end generate;

end Behavioral;


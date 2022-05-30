library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity download_mid is port(
	signal p_mid_sel : in std_logic;
	signal p_mid_sck : in std_logic;
	signal p_mid_sdi : in std_logic;
	signal clk : in std_logic;
	signal mod_mid : out std_logic_vector(7 downto 0);
	signal link_enable : out std_logic;
	signal cal_wen : out std_logic;
	signal cal_sck : out std_logic;
	signal cal_sdi : out std_logic
); end download_mid;

architecture Behavioral of download_mid is

signal imid_sel : std_logic;
signal imid_sck : std_logic;
signal imid_sdi : std_logic;
signal mod_mid_reg : std_logic_vector(7 downto 0);
signal link_enable_reg : std_logic;
signal cal_wen_reg : std_logic;
signal cal_sck_reg : std_logic;
signal cal_sdi_reg : std_logic;

signal mid_sel : std_logic;
signal mid_sck : std_logic;
signal dmid_sck : std_logic;
signal mid_sdi : std_logic;
signal sclk : std_logic;
signal pdat : std_logic_vector(23 downto 0);

attribute iob : string;
attribute iob of mid_sel : signal is "true";
attribute iob of mid_sck : signal is "true";
attribute iob of mid_sdi : signal is "true";

begin

	ibuf_mid_sel : ibuf port map(i => p_mid_sel, o => imid_sel);
	ibuf_mid_sck : ibuf port map(i => p_mid_sck, o => imid_sck);
	ibuf_mid_sdi : ibuf port map(i => p_mid_sdi, o => imid_sdi);

	process(clk) begin
	if (clk'event and clk = '1') then
	
		mid_sel <= imid_sel;
		cal_wen_reg <= mid_sel;
		mid_sdi <= imid_sdi;
		cal_sdi_reg <= mid_sdi;
	
		mid_sck <= imid_sck;
		dmid_sck <= mid_sck;
		sclk <= (not cal_wen_reg) and mid_sck and (not dmid_sck);
		cal_sck_reg <= cal_wen_reg and mid_sck and (not dmid_sck);
		
		if (sclk = '1') then
			pdat <= pdat(22 downto 0) & cal_sdi_reg;
		end if;
		
		mod_mid_reg <= pdat(15 downto 8);
		link_enable_reg <= pdat(23) and (not pdat(22)) and pdat(21) and (not pdat(20))
		               and pdat(19) and (not pdat(18)) and pdat(17) and (not pdat(16))
		               and pdat(7) and pdat(6) and (not pdat(5)) and pdat(4)
		               and pdat(3) and pdat(2) and (not pdat(1)) and (not pdat(0));
	
	end if;
	end process;
	
	mod_mid <= mod_mid_reg;
	link_enable <= link_enable_reg;
	cal_wen <= cal_wen_reg;
	cal_sck <= cal_sck_reg;
	cal_sdi <= cal_sdi_reg;
						 
end Behavioral;



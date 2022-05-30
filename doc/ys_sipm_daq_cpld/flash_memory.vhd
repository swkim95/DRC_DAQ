library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity flash_memory is port(
	signal p_prom_sdo : in std_logic;
	signal wprom_cs : in std_logic;
	signal wprom_sck : in std_logic;
	signal wprom_sdi : in std_logic;
	signal rprom_cs : in std_logic;
	signal rprom_sck : in std_logic;
	signal rprom_sdi : in std_logic;
	signal clk : in std_logic;
	signal prom_rdat : out std_logic;
	signal p_prom_cs : out std_logic;
	signal p_prom_sck : out std_logic;
	signal p_prom_sdi : out std_logic
); end flash_memory;

architecture Behavioral of flash_memory is

signal prom_sdo : std_logic;
signal prom_rdat_reg : std_logic;
signal prom_cs : std_logic;
signal prom_sck : std_logic;
signal prom_sdi : std_logic;

begin

	ibuf_prom_sdo : ibuf port map(i => p_prom_sdo, o => prom_sdo);

	process(clk) begin
	if (clk'event and clk = '1') then
	
		prom_rdat_reg <= prom_sdo;
		prom_cs <= (not wprom_cs) and (not rprom_cs);
		prom_sck <= wprom_sck or rprom_sck;
		prom_sdi <= wprom_sdi or rprom_sdi;
	
	end if;
	end process;

	prom_rdat <= prom_rdat_reg;

	obuf_prom_cs : obuf port map(i => prom_cs, o => p_prom_cs);
	obuf_prom_sck : obuf port map(i => prom_sck, o => p_prom_sck);
	obuf_prom_sdi : obuf port map(i => prom_sdi, o => p_prom_sdi);

end Behavioral;

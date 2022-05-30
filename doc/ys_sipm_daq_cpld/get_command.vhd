library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity get_command is port(
	signal p_spi_cs : in std_logic;
	signal p_spi_sck : in std_logic;
	signal p_spi_sdi : in std_logic;
	signal p_fpga_init : in std_logic;
	signal p_fpga_done : in std_logic;
	signal prom_rdat : in std_logic;
	signal down_done : in std_logic;
	signal clk : in std_logic;
	signal download : out std_logic;
	signal calib : out std_logic;
	signal wprom_cs : out std_logic;
	signal wprom_sck : out std_logic;
	signal wprom_sdi : out std_logic;
	signal p_prom_wp : out std_logic;
	signal p_fpga_prog : out std_logic;
	signal p_spi_sdo : out std_logic
); end get_command;

architecture Behavioral of get_command is

signal spi_cs : std_logic;
signal spi_sck : std_logic;
signal spi_sdi : std_logic;
signal fpga_init : std_logic;
signal fpga_done : std_logic;
signal download_reg : std_logic;
signal calib_reg : std_logic;
signal wprom_cs_reg : std_logic;
signal wprom_sck_reg : std_logic;
signal wprom_sdi_reg : std_logic;
signal prom_wp : std_logic := '0';
signal fpga_prog : std_logic := '1';
signal spi_sdo : std_logic;

signal dspi_cs : std_logic;
signal d2spi_cs : std_logic;
signal d3spi_cs : std_logic;
signal dspi_sck : std_logic;
signal d2spi_sck : std_logic;
signal d3spi_sck : std_logic;
signal bcs : std_logic;
signal ecs : std_logic;
signal sclk : std_logic;
signal eclk : std_logic;
signal enflag : std_logic;
signal ccen : std_logic;
signal ccnt : std_logic_vector(2 downto 0);
signal scom : std_logic;
signal sdat : std_logic;
signal encom : std_logic_vector(5 downto 0);
signal mux : std_logic_vector(1 downto 0);
signal icpld_sdo : std_logic;
signal cpld_sdo : std_logic;
signal dcen : std_logic;
signal dat_sck : std_logic;

begin

	ibuf_spi_cs : ibuf port map(i => p_spi_cs, o => spi_cs);
	ibuf_spi_sck : ibuf port map(i => p_spi_sck, o => spi_sck);
	ibuf_spi_sdi : ibuf port map(i => p_spi_sdi, o => spi_sdi);
	ibuf_fpga_init : ibuf port map(i => p_fpga_init, o => fpga_init);
	ibuf_fpga_done : ibuf port map(i => p_fpga_done, o => fpga_done);

	process(clk) begin
	if (clk'event and clk = '1') then
	
		dspi_cs <= spi_cs;
		d2spi_cs <= dspi_cs;
		d3spi_cs <= d2spi_cs;
		bcs <= (not d2spi_cs) and d3spi_cs;
		ecs <= d2spi_cs and (not d3spi_cs);
		
		dspi_sck <= spi_sck;
		d2spi_sck <= dspi_sck;
		d3spi_sck <= d2spi_sck;
		sclk <= d2spi_sck and (not d3spi_sck);
		eclk <= (not d2spi_sck) and d3spi_sck;

		if (sclk = '1') then
			enflag <= '0';
		elsif (bcs = '1') then
			enflag <= '1';
		end if;
		
		scom <= enflag and (not spi_sdi) and sclk;
		sdat <= enflag and spi_sdi and sclk;
		
		if (ecs = '1') then
			ccen <= '0';
		elsif (scom = '1') then
			ccen <= '1';
		end if;
		
		if (scom = '1') then
			ccnt <= (others => '0');
		elsif ((ccen = '1') and (sclk = '1')) then
			ccnt <= ccnt + 1;
		end if;
		
		if (encom(0) = '1') then
			mux(1) <= spi_sdi;
		end if;
			
		if (encom(1) = '1') then
			mux(0) <= spi_sdi;
		end if;
		
		if (encom(2) = '1') then
			prom_wp <= spi_sdi;
		end if;
		
		download_reg <= encom(3) and spi_sdi;
		
		if (encom(4) = '1') then
			fpga_prog <= not(spi_sdi);
		end if;

		if (encom(5) = '1') then
			calib_reg <= spi_sdi;
		end if;

		cpld_sdo <= icpld_sdo;
		
		if (ecs = '1') then
			dcen <= '0';
		elsif (sdat = '1') then
			dcen <= '1';
		end if;
		
		if (eclk = '1') then
			dat_sck <= '0';
		elsif ((dcen = '1') and (sclk = '1')) then
			dat_sck <= '1';
		end if;
	
		wprom_cs_reg <= dcen and (not mux(1)) and mux(0);
		wprom_sck_reg <= dat_sck and (not mux(1)) and mux(0);
		wprom_sdi_reg <= dcen and spi_sdi and (not mux(1)) and mux(0);
		
		spi_sdo <= (cpld_sdo and ccen) or (prom_rdat and dcen);
	
	end if;
	end process;
	
	encom(0) <= sclk and ccen and (not ccnt(2)) and (not ccnt(1)) and (not ccnt(0));
	encom(1) <= sclk and ccen and (not ccnt(2)) and (not ccnt(1)) and ccnt(0);
	encom(2) <= sclk and ccen and (not ccnt(2)) and ccnt(1) and (not ccnt(0));
	encom(3) <= sclk and ccen and ccnt(2) and (not ccnt(1)) and (not ccnt(0));
	encom(4) <= sclk and ccen and ccnt(2) and (not ccnt(1)) and ccnt(0);
	encom(5) <= sclk and ccen and ccnt(2) and ccnt(1) and (not ccnt(0));
	
	icpld_sdo <= down_done when ccnt = "111"
	        else fpga_init when ccnt = "110"
		     else fpga_done when ccnt = "101"
		     else '0';

	download <= download_reg;
	calib <= calib_reg;
	wprom_cs <= wprom_cs_reg;
	wprom_sck <= wprom_sck_reg;
	wprom_sdi <= wprom_sdi_reg;

	obuf_prom_wp : obuf port map(i => prom_wp, o => p_prom_wp);
	obuf_fpga_prog : obuf port map(i => fpga_prog, o => p_fpga_prog);

	obuf_spi_sdo : obuf port map(i => spi_sdo, o => p_spi_sdo);

end Behavioral;


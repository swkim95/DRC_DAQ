library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_mds is port(
	signal p5omds : in std_logic;
	signal p5emds : in std_logic;
	signal reset_serdes_mds : in std_logic;
	signal x2clk90_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal clk45_dram : in std_logic;
	signal p_dram_dsp : out std_logic_vector(1 downto 0);
	signal p_dram_dsn : out std_logic_vector(1 downto 0)
); end dram_mds;

architecture Behavioral of dram_mds is

signal dram_omds : std_logic_vector(1 downto 0);
signal dram_emds : std_logic_vector(1 downto 0);

signal p4omds : std_logic;
signal p3omds : std_logic;
signal p2omds : std_logic_vector(1 downto 0);
signal pomds : std_logic_vector(1 downto 0);
signal romds : std_logic_vector(1 downto 0);
signal p4emds : std_logic;
signal p3emds : std_logic;
signal p2emds : std_logic_vector(1 downto 0);
signal pemds : std_logic_vector(1 downto 0);

attribute keep:string;
attribute keep of p4omds :signal is "true";
attribute keep of p3omds :signal is "true";
attribute keep of p2omds :signal is "true";
attribute keep of pomds :signal is "true";
attribute keep of p4emds :signal is "true";
attribute keep of p3emds :signal is "true";
attribute keep of p2emds :signal is "true";
attribute keep of pemds :signal is "true";

begin

	romds(0) <= '0';
	romds(1) <= '1';

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '0') then
	
		p4omds <= p5omds;

		p4emds <= p5emds;
	
	end if;
	end process;

	process(clk45_dram) begin
	if (clk45_dram'event and clk45_dram = '1') then
	
		p3omds <= p4omds;
		p2omds(0) <= not p3omds;
		p2omds(1) <= not p3omds;
		pomds <= p2omds;
		
		p3emds <= p4emds;
		p2emds <= (others => p3emds);
		pemds <= not p2emds;

	end if;
	end process;

	myloop1 : for i in 0 to 1 generate
	
		OSERDESE2_mds : OSERDESE2
		generic map (
			DATA_RATE_OQ => "DDR",
			DATA_RATE_TQ => "DDR",
			DATA_WIDTH => 4, 
			INIT_OQ => '0',
			INIT_TQ => '1',
			SERDES_MODE => "MASTER",
			SRVAL_OQ => '0',
			SRVAL_TQ => '1',
			TBYTE_CTL => "FALSE",
			TBYTE_SRC => "FALSE",
			TRISTATE_WIDTH => 4
		)
		port map (
			D1 => pomds(i),
			D2 => romds(i),
			D3 => pomds(i),
			D4 => romds(i),
			D5 => romds(i),
			D6 => romds(i),
			D7 => romds(i),
			D8 => romds(i),
			T1 => pemds(i),
			T2 => pemds(i),
			T3 => pemds(i),
			T4 => pemds(i),
			OCE => '1', 
			TCE => '1',
			TBYTEIN => '1',
			SHIFTIN1 => '0',
			SHIFTIN2 => '0',
			RST => reset_serdes_mds, 
			CLK => x2clk90_dram,
			CLKDIV => clk45_dram,
			SHIFTOUT1 => open,
			SHIFTOUT2 => open,
			OFB => open, 
			TFB => open, 
			OQ => dram_omds(i), 
			TQ => dram_emds(i), 
			TBYTEOUT => open
		);
	end generate;

	obufds_dram_mds0 : obuftds port map(i => dram_omds(0), t => dram_emds(0), o => p_dram_dsn(0), ob => p_dram_dsp(0));
	obufds_dram_mds1 : obuftds port map(i => dram_omds(1), t => dram_emds(1), o => p_dram_dsn(1), ob => p_dram_dsp(1));

end Behavioral;


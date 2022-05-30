library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_signal is port(
	signal dram_wa : in std_logic_vector(13 downto 0);
	signal dram_ra : in std_logic_vector(13 downto 0);
	signal dram_sa : in std_logic_vector(13 downto 0);
	signal dram_wba : in std_logic_vector(2 downto 0);
	signal dram_rba : in std_logic_vector(2 downto 0);
	signal dram_sba : in std_logic_vector(2 downto 0);
	signal dram_wcs : in std_logic;
	signal dram_rcs : in std_logic;
	signal dram_fcs : in std_logic;
	signal dram_scs : in std_logic;
	signal dram_wras : in std_logic;
	signal dram_rras : in std_logic;
	signal dram_fras : in std_logic;
	signal dram_sras : in std_logic;
	signal dram_wcas : in std_logic;
	signal dram_rcas : in std_logic;
	signal dram_fcas : in std_logic;
	signal dram_scas : in std_logic;
	signal dram_wmwe : in std_logic;
	signal dram_rmwe : in std_logic;
	signal dram_smwe : in std_logic;
	signal reset_serdes_md : in std_logic;
	signal x2clk_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal p_dram_a : out std_logic_vector(13 downto 0);
	signal p_dram_ba : out std_logic_vector(2 downto 0);
	signal p_dram_cs : out std_logic;
	signal p_dram_ras : out std_logic;
	signal p_dram_cas : out std_logic;
	signal p_dram_we : out std_logic;
	signal p_dram_odt : out std_logic
); end dram_signal;

architecture Behavioral of dram_signal is

signal dram_a : std_logic_vector(13 downto 0);
signal dram_ba: std_logic_vector(2 downto 0);
signal dram_cs : std_logic;
signal dram_ras : std_logic;
signal dram_cas : std_logic;
signal dram_we : std_logic;
signal pdram_a : std_logic_vector(13 downto 0);
signal pdram_ba : std_logic_vector(2 downto 0);
signal pdram_cs : std_logic;
signal pdram_ras : std_logic;
signal pdram_cas : std_logic;
signal pdram_we : std_logic;

begin

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then

		for i in 0 to 13 loop
			pdram_a(i) <= dram_wa(i) or dram_ra(i) or dram_sa(i);
		end loop;

		for i in 0 to 2 loop
			pdram_ba(i) <= dram_wba(i) or dram_rba(i) or dram_sba(i);
		end loop;
	
		pdram_cs <= not(dram_wcs or dram_rcs or dram_fcs or dram_scs);
		pdram_ras <= not(dram_wras or dram_rras or dram_fras or dram_sras);
		pdram_cas <= not(dram_wcas or dram_rcas or dram_fcas or dram_scas);
		pdram_we <= not(dram_wmwe or dram_rmwe or dram_smwe);

	end if;
	end process;
	
	myloop1 : for i in 0 to 13 generate
		OSERDESE2_dram_a : OSERDESE2
		generic map (
			DATA_RATE_OQ => "DDR",
			DATA_RATE_TQ => "BUF",
			DATA_WIDTH => 4, 
			INIT_OQ => '0',
			INIT_TQ => '1',
			SERDES_MODE => "MASTER",
			SRVAL_OQ => '0',
			SRVAL_TQ => '1',
			TBYTE_CTL => "FALSE",
			TBYTE_SRC => "FALSE",
			TRISTATE_WIDTH => 1
		)
		port map (
			D1 => pdram_a(i),
			D2 => pdram_a(i),
			D3 => '0',
			D4 => '0',
			D5 => '0',
			D6 => '0',
			D7 => '0',
			D8 => '0',
			T1 => '0',
			T2 => '0',
			T3 => '0',
			T4 => '0',
			OCE => '1', 
			TCE => '1',
			TBYTEIN => '1',
			SHIFTIN1 => '0',
			SHIFTIN2 => '0',
			RST => reset_serdes_md, 
			CLK => x2clk_dram,
			CLKDIV => clk_dram,
			SHIFTOUT1 => open,
			SHIFTOUT2 => open,
			OFB => open, 
			TFB => open, 
			OQ => dram_a(i), 
			TQ => open, 
			TBYTEOUT => open
		);

		obuf_dram_a : obuf port map(i => dram_a(i), o => p_dram_a(i));
	end generate;

	myloop2 : for i in 0 to 2 generate
		OSERDESE2_dram_ba : OSERDESE2
		generic map (
			DATA_RATE_OQ => "DDR",
			DATA_RATE_TQ => "BUF",
			DATA_WIDTH => 4, 
			INIT_OQ => '0',
			INIT_TQ => '1',
			SERDES_MODE => "MASTER",
			SRVAL_OQ => '0',
			SRVAL_TQ => '1',
			TBYTE_CTL => "FALSE",
			TBYTE_SRC => "FALSE",
			TRISTATE_WIDTH => 1
		)
		port map (
			D1 => pdram_ba(i),
			D2 => pdram_ba(i),
			D3 => '0',
			D4 => '0',
			D5 => '0',
			D6 => '0',
			D7 => '0',
			D8 => '0',
			T1 => '0',
			T2 => '0',
			T3 => '0',
			T4 => '0',
			OCE => '1', 
			TCE => '1',
			TBYTEIN => '1',
			SHIFTIN1 => '0',
			SHIFTIN2 => '0',
			RST => reset_serdes_md, 
			CLK => x2clk_dram,
			CLKDIV => clk_dram,
			SHIFTOUT1 => open,
			SHIFTOUT2 => open,
			OFB => open, 
			TFB => open, 
			OQ => dram_ba(i), 
			TQ => open, 
			TBYTEOUT => open
		);

		obuf_dram_ba : obuf port map(i => dram_ba(i), o => p_dram_ba(i));
	end generate;

	OSERDESE2_dram_cs : OSERDESE2
	generic map (
		DATA_RATE_OQ => "DDR",
		DATA_RATE_TQ => "BUF",
		DATA_WIDTH => 4, 
		INIT_OQ => '0',
		INIT_TQ => '1',
		SERDES_MODE => "MASTER",
		SRVAL_OQ => '0',
		SRVAL_TQ => '1',
		TBYTE_CTL => "FALSE",
		TBYTE_SRC => "FALSE",
		TRISTATE_WIDTH => 1
	)
	port map (
		D1 => pdram_cs,
		D2 => pdram_cs,
		D3 => '1',
		D4 => '1',
		D5 => '1',
		D6 => '1',
		D7 => '1',
		D8 => '1',
		T1 => '0',
		T2 => '0',
		T3 => '0',
		T4 => '0',
		OCE => '1', 
		TCE => '1',
		TBYTEIN => '1',
		SHIFTIN1 => '0',
		SHIFTIN2 => '0',
		RST => reset_serdes_md, 
		CLK => x2clk_dram,
		CLKDIV => clk_dram,
		SHIFTOUT1 => open,
		SHIFTOUT2 => open,
		OFB => open, 
		TFB => open, 
		OQ => dram_cs, 
		TQ => open, 
		TBYTEOUT => open
	);

	obuf_dram_cs : obuf port map(i => dram_cs, o => p_dram_cs);

	OSERDESE2_dram_ras : OSERDESE2
	generic map (
		DATA_RATE_OQ => "DDR",
		DATA_RATE_TQ => "BUF",
		DATA_WIDTH => 4, 
		INIT_OQ => '0',
		INIT_TQ => '1',
		SERDES_MODE => "MASTER",
		SRVAL_OQ => '0',
		SRVAL_TQ => '1',
		TBYTE_CTL => "FALSE",
		TBYTE_SRC => "FALSE",
		TRISTATE_WIDTH => 1
	)
	port map (
		D1 => pdram_ras,
		D2 => pdram_ras,
		D3 => '1',
		D4 => '1',
		D5 => '1',
		D6 => '1',
		D7 => '1',
		D8 => '1',
		T1 => '0',
		T2 => '0',
		T3 => '0',
		T4 => '0',
		OCE => '1', 
		TCE => '1',
		TBYTEIN => '1',
		SHIFTIN1 => '0',
		SHIFTIN2 => '0',
		RST => reset_serdes_md, 
		CLK => x2clk_dram,
		CLKDIV => clk_dram,
		SHIFTOUT1 => open,
		SHIFTOUT2 => open,
		OFB => open, 
		TFB => open, 
		OQ => dram_ras, 
		TQ => open, 
		TBYTEOUT => open
	);

	obuf_dram_ras : obuf port map(i => dram_ras, o => p_dram_ras);

	OSERDESE2_dram_cas : OSERDESE2
	generic map (
		DATA_RATE_OQ => "DDR",
		DATA_RATE_TQ => "BUF",
		DATA_WIDTH => 4, 
		INIT_OQ => '0',
		INIT_TQ => '1',
		SERDES_MODE => "MASTER",
		SRVAL_OQ => '0',
		SRVAL_TQ => '1',
		TBYTE_CTL => "FALSE",
		TBYTE_SRC => "FALSE",
		TRISTATE_WIDTH => 1
	)
	port map (
		D1 => pdram_cas,
		D2 => pdram_cas,
		D3 => '1',
		D4 => '1',
		D5 => '1',
		D6 => '1',
		D7 => '1',
		D8 => '1',
		T1 => '0',
		T2 => '0',
		T3 => '0',
		T4 => '0',
		OCE => '1', 
		TCE => '1',
		TBYTEIN => '1',
		SHIFTIN1 => '0',
		SHIFTIN2 => '0',
		RST => reset_serdes_md, 
		CLK => x2clk_dram,
		CLKDIV => clk_dram,
		SHIFTOUT1 => open,
		SHIFTOUT2 => open,
		OFB => open, 
		TFB => open, 
		OQ => dram_cas, 
		TQ => open, 
		TBYTEOUT => open
	);

	obuf_dram_cas : obuf port map(i => dram_cas, o => p_dram_cas);

	OSERDESE2_dram_we : OSERDESE2
	generic map (
		DATA_RATE_OQ => "DDR",
		DATA_RATE_TQ => "BUF",
		DATA_WIDTH => 4, 
		INIT_OQ => '0',
		INIT_TQ => '1',
		SERDES_MODE => "MASTER",
		SRVAL_OQ => '0',
		SRVAL_TQ => '1',
		TBYTE_CTL => "FALSE",
		TBYTE_SRC => "FALSE",
		TRISTATE_WIDTH => 1
	)
	port map (
		D1 => pdram_we,
		D2 => pdram_we,
		D3 => '1',
		D4 => '1',
		D5 => '1',
		D6 => '1',
		D7 => '1',
		D8 => '1',
		T1 => '0',
		T2 => '0',
		T3 => '0',
		T4 => '0',
		OCE => '1', 
		TCE => '1',
		TBYTEIN => '1',
		SHIFTIN1 => '0',
		SHIFTIN2 => '0',
		RST => reset_serdes_md, 
		CLK => x2clk_dram,
		CLKDIV => clk_dram,
		SHIFTOUT1 => open,
		SHIFTOUT2 => open,
		OFB => open, 
		TFB => open, 
		OQ => dram_we, 
		TQ => open, 
		TBYTEOUT => open
	);

	obuf_dram_we : obuf port map(i => dram_we, o => p_dram_we);

	obuf_dram_odt : obuf port map(i => '0', o => p_dram_odt);

end Behavioral;


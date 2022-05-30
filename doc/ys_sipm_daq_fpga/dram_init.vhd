library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_init is port(
	signal dram_ready : in std_logic;
	signal dram_start : in std_logic;
	signal dram_stop : in std_logic;
	signal reset_serdes_md : in std_logic;
	signal x2clk_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal dram_scs : out std_logic;
	signal dram_sa : out std_logic_vector(13 downto 0);
	signal dram_sba : out std_logic_vector(2 downto 0);
	signal dram_sras : out std_logic;
	signal dram_scas : out std_logic;
	signal dram_smwe : out std_logic;
	signal dram_enable : out std_logic;
	signal p_dram_clke : out std_logic;
	signal p_dram_reset : out std_logic
); end dram_init;

architecture Behavioral of dram_init is

signal dram_scs_reg : std_logic;
signal dram_sa_reg : std_logic_vector(4 downto 0);
signal dram_sba_reg : std_logic_vector(1 downto 0);
signal dram_sras_reg : std_logic;
signal dram_scas_reg : std_logic;
signal dram_smwe_reg : std_logic;
signal dram_enable_reg : std_logic;
signal dram_reset : std_logic;
signal dram_clke : std_logic;

signal rst_cen : std_logic := '0';
signal rst_cnt : std_logic_vector(15 downto 0) := (others => '0');
signal rst_clr : std_logic;
signal clk_cen : std_logic;
signal clk_cnt : std_logic_vector(16 downto 0) := (others => '0');
signal clk_clr : std_logic;
signal init_cen : std_logic;
signal init_cnt : std_logic_vector(5 downto 0) := (others => '0');
signal init_clr : std_logic;
signal mrs_cen : std_logic;
signal mrs_cnt : std_logic_vector(4 downto 0) := (others => '0');
signal mrs_clr : std_logic;
signal dll_cen : std_logic;
signal dll_cnt : std_logic_vector(8 downto 0) := (others => '0');
signal idram_sras : std_logic;
signal idram_scas : std_logic;
signal idram_smwe : std_logic;
signal idram_scs : std_logic;
signal idram_sba : std_logic_vector(1 downto 0);
signal idram_sa : std_logic_vector(4 downto 0);
signal ipdram_clke : std_logic;
signal pdram_clke : std_logic;

attribute iob : string;
attribute iob of dram_reset : signal is "true";

attribute keep:string;
attribute keep of dram_enable_reg :signal is "true";

begin

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then
	
		if (rst_clr = '1') then
			rst_cen <= '0';
		elsif (dram_start = '1') then
			rst_cen <= (not dram_ready);
		end if;
		
		dram_reset <= not rst_cen;
		
		if (rst_clr = '1') then
			rst_cnt <= (others => '0');
		elsif (rst_cen = '1') then
			rst_cnt <= rst_cnt + 1;
		end if;
		
		rst_clr <= rst_cnt(15) and (not rst_cnt(14)) and (not rst_cnt(13)) and rst_cnt(12)
		       and rst_cnt(11) and rst_cnt(10) and rst_cnt(9) and rst_cnt(8)
		       and (not rst_cnt(7)) and rst_cnt(6) and (not rst_cnt(5)) and rst_cnt(4) 
				 and rst_cnt(3) and rst_cnt(2) and rst_cnt(1) and (not rst_cnt(0));
		
		if (clk_clr = '1') then
			clk_cen <= '0';
		elsif (rst_clr = '1') then
			clk_cen <= '1';
		end if;
		
		if (clk_clr = '1') then
			clk_cnt <= (others => '0');
		elsif (clk_cen = '1') then
			clk_cnt <= clk_cnt + 1;
		end if;
		
		clk_clr <= clk_cnt(16) and clk_cnt(15) and (not clk_cnt(14))
		       and (not clk_cnt(13)) and (not clk_cnt(12)) and clk_cnt(11)
				 and (not clk_cnt(10)) and (not clk_cnt(9)) and clk_cnt(8)
		       and clk_cnt(7) and (not clk_cnt(6)) and clk_cnt(5) 
				 and clk_cnt(4) and clk_cnt(3) and clk_cnt(2)
				 and clk_cnt(1) and (not clk_cnt(0));
		
		pdram_clke <= ipdram_clke;

		if (init_clr = '1') then
			init_cen <= '0';
		elsif (clk_clr = '1') then
			init_cen <= '1';
		end if;
		
		if (init_clr = '1') then
			init_cnt <= (others => '0');
		elsif (init_cen = '1') then
			init_cnt <= init_cnt + 1;
		end if;
		
		init_clr <= init_cnt(5) and init_cnt(4) and init_cnt(3) 
		        and init_cnt(2) and init_cnt(1) and (not init_cnt(0));

		if (mrs_clr = '1') then
			mrs_cen <= '0';
		elsif (init_clr = '1') then
			mrs_cen <= '1';
		end if;
		
		if (mrs_clr = '1') then
			mrs_cnt <= (others => '0');
		elsif (mrs_cen = '1') then
			mrs_cnt <= mrs_cnt + 1;
		end if;
		
		mrs_clr <= mrs_cnt(4) and mrs_cnt(3) and mrs_cnt(2) and mrs_cnt(1) and (not mrs_cnt(0));

		if (dram_enable_reg = '1') then
			dll_cen <= '0';
		elsif (mrs_clr = '1') then
			dll_cen <= '1';
		end if;
		
		if (dram_enable_reg = '1') then
			dll_cnt <= (others => '0');
		elsif (dll_cen = '1') then
			dll_cnt <= dll_cnt + 1;
		end if;
		
		dram_enable_reg <= dll_cnt(8) and dll_cnt(7) and dll_cnt(6) and dll_cnt(5) and dll_cnt(4) 
						   and dll_cnt(3) and dll_cnt(2) and dll_cnt(1) and (not dll_cnt(0));

		dram_sras_reg <= idram_sras;
		dram_scas_reg <= idram_scas;
		dram_smwe_reg <= idram_smwe;
		dram_scs_reg <= idram_scs;
		dram_sba_reg <= idram_sba;
		dram_sa_reg <= idram_sa;
		
	end if;
	end process;

	lut5_dram_sras : LUT5
	generic map(init => x"00AA0000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_sras
	);
		
	lut5_dram_scas : LUT5
	generic map(init => x"00AA0000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_scas
	);
		
	lut5_dram_smwe : LUT5
	generic map(init => x"80AA0000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_smwe
	);
		
	lut5_dram_scs : LUT5
	generic map(init => x"80AA0000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_scs
	);
		
	lut5_dram_sba0 : LUT5
	generic map(init => x"00280000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_sba(0)
	);
		
	lut5_dram_sba1 : LUT5
	generic map(init => x"000A0000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_sba(1)
	);
		
	lut5_dram_sa3 : LUT5
	generic map(init => x"00020000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_sa(0)
	);
		
	lut5_dram_sa5 : LUT5
	generic map(init => x"00800000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_sa(1)
	);
		
	lut5_dram_sa8 : LUT5
	generic map(init => x"00800000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_sa(2)
	);
		
	lut5_dram_sa10 : LUT5
	generic map(init => x"80800000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_sa(3)
	);
		
	lut5_dram_sa12 : LUT5
	generic map(init => x"00800000")
	port map(
		i0 => mrs_cnt(0),
		i1 => mrs_cnt(1),
		i2 => mrs_cnt(2),
		i3 => mrs_cnt(3),
		i4 => mrs_cnt(4),
		o => idram_sa(4)
	);

	lut5_pdram_clke : LUT3
	generic map(init => x"0E")
	port map(
		i0 => pdram_clke,
		i1 => clk_clr,
		i2 => dram_stop,
		o => ipdram_clke
	);

	OSERDESE2_dram_clke : OSERDESE2
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
		D1 => pdram_clke,
		D2 => pdram_clke,
		D3 => pdram_clke,
		D4 => pdram_clke,
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
		OQ => dram_clke, 
		TQ => open, 
		TBYTEOUT => open
	);

	dram_scs <= dram_scs_reg;
	dram_sa <= '0' & dram_sa_reg(4) & '0' & dram_sa_reg(3) & '0'
	         & dram_sa_reg(2) & "00" & dram_sa_reg(1) & '0'
				& dram_sa_reg(0) & "000";
	dram_sba <= '0' & dram_sba_reg;
	dram_sras <= dram_sras_reg;
	dram_scas <= dram_scas_reg;
	dram_smwe <= dram_smwe_reg;
	dram_enable <= dram_enable_reg;

	obuf_dram_reset : obuf port map(i => dram_reset, o => p_dram_reset);
	obuf_dram_clke : obuf port map(i => dram_clke, o => p_dram_clke);

end Behavioral;



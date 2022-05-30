library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_md is port(
	signal p_dram_d : inout std_logic_vector(15 downto 0);
	signal dram_test_on : in std_logic;
	signal dram_fifo_rdata : in std_logic_vector(63 downto 0);
	signal p3emd : in std_logic;
	signal dram_idly : in dram_idly_array;
	signal wdram_idly : in std_logic_vector(1 downto 0);
	signal dram_bitslip : in std_logic_vector(1 downto 0);
	signal reset_serdes_md : in std_logic;
	signal x2clk_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal dram_pattern : out std_logic_vector(63 downto 0);
	signal data_fifo_wdata : out std_logic_vector(63 downto 0)
); end dram_md;

architecture Behavioral of dram_md is

type dram_md_cnt_array is array(1 downto 0) of std_logic_vector(4 downto 0);

signal imd : std_logic_vector(15 downto 0);
signal omd : std_logic_vector(15 downto 0);
signal emd : std_logic_vector(15 downto 0);
signal dram_pattern_reg : std_logic_vector(63 downto 0);
signal data_fifo_wdata_reg : std_logic_vector(63 downto 0);

signal cen : std_logic_vector(7 downto 0);
signal cnt : dram_md_cnt_array;
signal clr : std_logic_vector(1 downto 0);
signal start : std_logic_vector(1 downto 0);
signal dlyrst : std_logic_vector(1 downto 0);
signal dlyce : std_logic_vector(1 downto 0);
signal nx2clk_dram : std_logic;
signal dsin : std_logic_vector(15 downto 0);
signal lmd : std_logic_vector(63 downto 0);
signal ip2omd : std_logic_vector(63 downto 0);
signal p2omd : std_logic_vector(63 downto 0);
signal pomd : std_logic_vector(63 downto 0);
signal p2emd : std_logic_vector(15 downto 0);
signal pemd : std_logic_vector(15 downto 0);

attribute keep:string;
attribute keep of p2emd :signal is "true";
attribute keep of pemd :signal is "true";
attribute keep of data_fifo_wdata_reg :signal is "true";

begin

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then

		for ch in 0 to 1 loop
			if (wdram_idly(ch) = '1') then
				cen(ch) <= '1';
			elsif (clr(ch) = '1') then
				cen(ch) <= '0';
			end if;
		
			if (clr(ch) = '1') then
				cnt(ch) <= (others=>'0');
			elsif (cen(ch) = '1') then
				cnt(ch) <= cnt(ch) + 1;
			end if;
		
			if (cnt(ch) = dram_idly(ch)) then
				clr(ch) <= '1';
			else
				clr(ch) <= '0';
			end if;
		
			dlyrst(ch) <= wdram_idly(ch);
			start(ch) <= dlyrst(ch);
		
			if (clr(ch) = '1') then
				dlyce(ch) <= '0';
			elsif (start(ch) = '1') then
				dlyce(ch) <= '1';
			end if;
		end loop;

		data_fifo_wdata_reg <= lmd;
		dram_pattern_reg <= data_fifo_wdata_reg;
		
		p2omd <= ip2omd;
		pomd <= p2omd;
	
		p2emd <= (others => p3emd);
		pemd <= not p2emd;

	end if;
	end process;

	ip2omd <= dram_fifo_rdata when dram_test_on = '0'
	     else "1111111111111111"
			  & "1010101010101010"
		     & "0101010101010101"
		     & "0000000000000000";

	nx2clk_dram <= not x2clk_dram;

	myloop1 : for i in 0 to 15 generate
		ibuf_md : ibuf port map(i => p_dram_d(i), o => imd(i));

		idelaye2_md : idelaye2
		generic map(
			cinvctrl_sel => "false",
			delay_src => "idatain",
			high_performance_mode => "false",
			idelay_type => "variable",
			idelay_value => 0,
			pipe_sel => "false",
			refclk_frequency => 200.0,
			signal_pattern => "data"
		)
		port map(
			c => clk_dram,
			regrst => '0',
			ld => dlyrst(i / 8),
			ce => dlyce(i / 8),
			inc => dlyce(i / 8),
			cinvctrl => '0',
			cntvaluein => "00000",
			idatain => imd(i),
			ldpipeen => '0',
			datain => '0',
			dataout => dsin(i),
			cntvalueout => open
		);

		ISERDESE2_md : ISERDESE2
		generic map (
			DATA_RATE => "DDR",
			DATA_WIDTH => 4,
			DYN_CLKDIV_INV_EN => "FALSE",
			DYN_CLK_INV_EN => "FALSE", 
			INIT_Q1 => '0',
			INIT_Q2 => '0',
			INIT_Q3 => '0',
			INIT_Q4 => '0',
			INTERFACE_TYPE => "NETWORKING",
			IOBDELAY => "IFD",
			NUM_CE => 1,
			OFB_USED => "FALSE",
			SERDES_MODE => "MASTER",
			SRVAL_Q1 => '0',
			SRVAL_Q2 => '0',
			SRVAL_Q3 => '0',
			SRVAL_Q4 => '0'
		)
		port map (
			DDLY => dsin(i),
			D => '0',
			OFB => '0',
			SHIFTIN1 => '0',
			SHIFTIN2 => '0',
			BITSLIP => dram_bitslip(i / 8),
			DYNCLKDIVSEL => '0',
			DYNCLKSEL => '0',
			CE1 => '1',
			CE2 => '1',
			RST => reset_serdes_md,
			CLK => x2clk_dram, 
			CLKB => nx2clk_dram,
			OCLK => '0',
			OCLKB => '0',
			CLKDIV => clk_dram,
			CLKDIVP => '0',
			Q1 => lmd(i + 48),
			Q2 => lmd(i + 32),
			Q3 => lmd(i + 16),
			Q4 => lmd(i),
			Q5 => open, 
			Q6 => open, 
			Q7 => open, 
			Q8 => open, 
			O => open, 
			SHIFTOUT1 => open,
			SHIFTOUT2 => open
		);
		
		OSERDESE2_md : OSERDESE2
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
			D1 => pomd(i),
			D2 => pomd(i + 16),
			D3 => pomd(i + 32),
			D4 => pomd(i + 48),
			D5 => '0',
			D6 => '0',
			D7 => '0',
			D8 => '0',
			T1 => pemd(i),
			T2 => pemd(i),
			T3 => pemd(i),
			T4 => pemd(i),
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
			OQ => omd(i), 
			TQ => emd(i), 
			TBYTEOUT => open
		);

		obuft_dram_d : obuft port map(i => omd(i), t => emd(i), o => p_dram_d(i));
	end generate;

	dram_pattern <= dram_pattern_reg;
	data_fifo_wdata <= data_fifo_wdata_reg;

end Behavioral;


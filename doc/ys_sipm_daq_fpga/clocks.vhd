library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity clocks is port(
	signal p_tcb_clkp : in std_logic;
	signal p_tcb_clkn : in std_logic;
	signal reset_refclk : in std_logic;
	signal x2clk : out std_logic;
	signal clk : out std_logic;
	signal x2clk_dram : out std_logic;
	signal x2clk90_dram : out std_logic;
	signal clk_dram : out std_logic;
	signal clk45_dram : out std_logic;
	signal reset_serdes_md : out std_logic;
	signal reset_serdes_mds : out std_logic;
	signal p_usb_pclk : out std_logic;
	signal p_dram_clkp : out std_logic;
	signal p_dram_clkn : out std_logic
); end clocks;

architecture Behavioral of clocks is

signal iclk_in : std_logic;
signal clk_in : std_logic;
signal clk_reg : std_logic;
signal x2clk90_dram_reg : std_logic;
signal clk_dram_reg : std_logic;
signal clk45_dram_reg : std_logic;
signal reset_serdes_md_reg : std_logic;
signal reset_serdes_mds_reg : std_logic;
signal usb_pclk : std_logic;
signal dram_clk : std_logic;

signal lx2clk : std_logic;
signal lclk : std_logic;
signal clkfb : std_logic;
signal locked_pri : std_logic;
signal dlocked_pri : std_logic;
signal reset_mmcm : std_logic;
signal dreset_refclk : std_logic;
signal lx2clk_dram : std_logic;
signal lx2clk90_dram : std_logic;
signal lclk_dram : std_logic;
signal lclk45_dram : std_logic;
signal lrefclk : std_logic;
signal lclk_usb : std_logic;
signal clkfb_dram : std_logic;
signal refclk : std_logic;
signal locked_sec : std_logic;
signal reset_idelayctrl : std_logic;
signal dlocked_md : std_logic;
signal dlocked_mds : std_logic;

begin

	ibufds_gte2_gtx_ref_clk : ibufds_gte2
	generic map(
		clkcm_cfg => true,
		clkswing_cfg => "11"
	)
	port map(
		i     => p_tcb_clkp,
		ib    => p_tcb_clkn,
		ceb   => '0',
		o     => iclk_in,
		odiv2 => open
	);
	
	bufg_clk_in : bufg port map(i => iclk_in, o => clk_in);
--	ibufgds_clk : ibufgds port map(i => p_tcb_clkp, ib => p_tcb_clkn, o => clk_in);


	mmcme2_clk : mmcme2_base
	generic map (
		bandwidth => "optimized",
		clkin1_period => 11.11,
		divclk_divide => 1,
		clkfbout_mult_f => 10.0,
		clkfbout_phase => 0.0,
		clkout0_divide_f => 4.5,
		clkout1_divide => 5,
		clkout2_divide => 10,
		clkout3_divide => 10,
		clkout4_divide => 10,
		clkout5_divide => 10,
		clkout6_divide => 10,
		clkout0_phase => 0.0,
		clkout1_phase => 0.0,
		clkout2_phase => 0.0,
		clkout3_phase => 0.0,
		clkout4_phase => 0.0,
		clkout5_phase => 0.0,
		clkout6_phase => 0.0,
		clkout0_duty_cycle => 0.5,
		clkout1_duty_cycle => 0.5,
		clkout2_duty_cycle => 0.5,
		clkout3_duty_cycle => 0.5,
		clkout4_duty_cycle => 0.5,
		clkout5_duty_cycle => 0.5,
		clkout6_duty_cycle => 0.5,
		clkout4_cascade => false,
		ref_jitter1 => 0.010,
		startup_wait => false
	)
	port map (
		clkin1 => clk_in,
		clkfbin => clkfb,
		rst => '0',
		pwrdwn => '0',
		clkout0 => lrefclk,
		clkout0b => open,
		clkout1 => lx2clk,
		clkout1b => open,
		clkout2 => lclk,
		clkout2b => open,
		clkout3 => open,
		clkout3b => open,
		clkout4 => open,
		clkout5 => open,
		clkout6 => open,
		clkfbout => clkfb,
		clkfboutb => open,
		locked => locked_pri
	);

	bufg_refclk : bufg port map(i => lrefclk, o => refclk);
	bufg_x2clk : bufg port map(i => lx2clk, o => x2clk);
	bufg_clk : bufg port map(i => lclk, o => clk_reg);

	srl16e_dlocked_pri : srl16e
	generic map(init => x"0000")
	port map(
		d => locked_pri,
		a0 => '1',
		a1 => '1',
		a2 => '1',
		a3 => '1',
		ce => '1',
		clk => clk_reg,
		q => dlocked_pri
	);

	srl16e_dreset_refclk : srl16e
	generic map (init => X"0000")
	port map (
		d => reset_refclk,
		a3 => '1',
		a2 => '1',
		a1 => '1',
		a0 => '1',
		ce => '1',
		clk => clk_reg,
		q => dreset_refclk
	);

	mmcme2_dram_clk : mmcme2_base
	generic map (
		bandwidth => "optimized",
		clkin1_period => 11.11,
		divclk_divide => 1,
		clkfbout_mult_f => 8.0,
		clkfbout_phase => 0.0,
		clkout0_divide_f => 2.0,
		clkout1_divide => 2,
		clkout2_divide => 4,
		clkout3_divide => 4,
		clkout4_divide => 4,
		clkout5_divide => 4,
		clkout6_divide => 4,
		clkout0_phase => 0.0,
		clkout1_phase => 90.0,
		clkout2_phase => 0.0,
		clkout3_phase => 45.0,
		clkout4_phase => 0.0,
		clkout5_phase => 0.0,
		clkout6_phase => 0.0,
		clkout0_duty_cycle => 0.5,
		clkout1_duty_cycle => 0.5,
		clkout2_duty_cycle => 0.5,
		clkout3_duty_cycle => 0.5,
		clkout4_duty_cycle => 0.5,
		clkout5_duty_cycle => 0.5,
		clkout6_duty_cycle => 0.5,
		clkout4_cascade => false,
		ref_jitter1 => 0.010,
		startup_wait => false
	)
	port map (
		clkin1 => clk_reg,
		clkfbin => clkfb_dram,
		rst => reset_mmcm,
		pwrdwn => '0',
		clkout0 => lx2clk_dram,
		clkout0b => open,
		clkout1 => lx2clk90_dram,
		clkout1b => open,
		clkout2 => lclk_dram,
		clkout2b => open,
		clkout3 => lclk45_dram,
		clkout3b => open,
		clkout4 => open,
		clkout5 => open,
		clkout6 => open,
		clkfbout => clkfb_dram,
		clkfboutb => open,
		locked => locked_sec
	);

	bufg_x2clk_dram : bufg port map(i => lx2clk_dram, o => x2clk_dram);
	bufg_x2clk90_dram : bufg port map(i => lx2clk90_dram, o => x2clk90_dram_reg);
	bufg_clk_dram : bufg port map(i => lclk_dram, o => clk_dram_reg);
	bufg_clk45_dram : bufg port map(i => lclk45_dram, o => clk45_dram_reg);

	srl16e_dlocked_md : srl16e
	generic map(init => x"0000")
	port map(
		d => locked_sec,
		a0 => '1',
		a1 => '1',
		a2 => '1',
		a3 => '1',
		ce => '1',
		clk => clk_dram_reg,
		q => dlocked_md
	);

	process(clk_reg) begin
	if (clk_reg'event and clk_reg = '1') then
	
		reset_mmcm <= not dlocked_pri;
	
		if (dreset_refclk = '1') then
			reset_idelayctrl <= '0';
		elsif (reset_refclk = '1') then
			reset_idelayctrl <= '1';
		end if;
	
	end if;
	end process;
	
	process(clk_dram_reg) begin
	if (clk_dram_reg'event and clk_dram_reg = '1') then
	
		reset_serdes_md_reg <= not dlocked_md;
	
	end if;
	end process;
	
	srl16e_dlocked_mds : srl16e
	generic map(init => x"0000")
	port map(
		d => locked_sec,
		a0 => '1',
		a1 => '1',
		a2 => '1',
		a3 => '1',
		ce => '1',
		clk => clk45_dram_reg,
		q => dlocked_mds
	);

	process(clk45_dram_reg) begin
	if (clk45_dram_reg'event and clk45_dram_reg = '1') then
	
		reset_serdes_mds_reg <= not dlocked_mds;
		
	end if;
	end process;

	idelayctrl_1 : idelayctrl port map(refclk => refclk, rst => reset_idelayctrl, rdy => open);
	
	oddr_pclk : oddr
	generic map(
		ddr_clk_edge => "same_edge",
		init => '0',
		srtype => "sync"
	)
	port map(
		d1 => '0',
		d2 => '1',
		r => '0',
		s => '0',
		ce => '1',
		c => clk_reg,
		q => usb_pclk
	);

	OSERDESE2_dram_clk : OSERDESE2
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
		D1 => '0',
		D2 => '1',
		D3 => '0',
		D4 => '1',
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
		RST => reset_serdes_mds_reg, 
		CLK => x2clk90_dram_reg,
		CLKDIV => clk45_dram_reg,
		SHIFTOUT1 => open,
		SHIFTOUT2 => open,
		OFB => open, 
		TFB => open, 
		OQ => dram_clk, 
		TQ => open, 
		TBYTEOUT => open
	);

	clk <= clk_reg;
	x2clk90_dram <= x2clk90_dram_reg;
	clk45_dram <= clk45_dram_reg;
	clk_dram <= clk_dram_reg;
	reset_serdes_md <= reset_serdes_md_reg;
	reset_serdes_mds <= reset_serdes_mds_reg;

	obufds_dram_clk : obufds port map(i => dram_clk, o => p_dram_clkn, ob => p_dram_clkp);
	obuf_pclk : obuf port map(i => usb_pclk, o => p_usb_pclk);
	
end Behavioral;


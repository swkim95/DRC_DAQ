library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity clocks is port(
	signal p_fpga_clkp : in std_logic;
	signal p_fpga_clkn : in std_logic;
	signal x2clk : out std_logic;
	signal clk : out std_logic;
	signal p_usb_pclk : out std_logic
); end clocks;

architecture Behavioral of clocks is

signal clk_reg : std_logic;
signal clk_usb_reg : std_logic;

signal clk_in : std_logic;
signal clk_fb : std_logic;
signal lx2clk : std_logic;
signal lclk : std_logic;
signal usb_pclk : std_logic;

begin

	ibufgds_clk : ibufgds port map(i => p_fpga_clkn, ib => p_fpga_clkp, o => clk_in);

	mmcme2_clk : mmcme2_base
	generic map (
		bandwidth => "optimized",
		clkin1_period => 8.00,
		divclk_divide => 5,
		clkfbout_mult_f => 36.0,
		clkfbout_phase => 0.0,
		clkout0_divide_f => 5.0,
		clkout1_divide => 10,
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
		clkfbin => clk_fb,
		rst => '0',
		pwrdwn => '0',
		clkout0 => lx2clk,
		clkout0b => open,
		clkout1 => lclk,
		clkout1b => open,
		clkout2 => open,
		clkout2b => open,
		clkout3 => open,
		clkout3b => open,
		clkout4 => open,
		clkout5 => open,
		clkout6 => open,
		clkfbout => clk_fb,
		clkfboutb => open,
		locked => open
	);
	
	oddr_usb_pclk : oddr
	generic map(
		ddr_clk_edge => "OPPOSITE_EDGE",
		init => '0',
		srtype => "sync"
	)
	port map(
		c => clk_reg,
		d1 => '0',
		d2 => '1',
		ce => '1',
		r => '0',
		s => '0',
		q => usb_pclk
	);

	bufg_x2clk : bufg port map(i => lx2clk, o => x2clk);
	bufg_clk : bufg port map(i => lclk, o => clk_reg);

	clk <= clk_reg;

	obuf_usb_pclk : obuf port map(i => usb_pclk, o => p_usb_pclk);
	
end Behavioral;
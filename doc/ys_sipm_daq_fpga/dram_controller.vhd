library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_controller is port(
	signal p_dram_d : inout std_logic_vector(15 downto 0);
	signal dram_fifo_rdata : in std_logic_vector(63 downto 0);
	signal dram_wpage : in std_logic_vector(16 downto 0);
	signal dram_rpage : in std_logic_vector(16 downto 0);
	signal dram_fifo_empty : in std_logic;
	signal data_fifo_full : in std_logic;
	signal dram_full : in std_logic;
	signal dram_empty : in std_logic;
	signal dram_idly : in dram_idly_array;
	signal wdram_idly : in std_logic_vector(1 downto 0);
	signal dram_bitslip : in std_logic_vector(1 downto 0);
	signal dram_test_wr : in std_logic;
	signal dram_test_rd : in std_logic;
	signal dram_test_on : in std_logic;
	signal dram_start : in std_logic;
	signal dram_stop : in std_logic;
	signal reset_serdes_md : in std_logic;
	signal reset_serdes_mds : in std_logic;
	signal reset_dram : in std_logic;
	signal x2clk_dram : in std_logic;
	signal x2clk90_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal clk45_dram : in std_logic;
	signal clk : in std_logic;
	signal dram_fifo_raddr : out std_logic_vector(13 downto 0);
	signal add_dram_wpage : out std_logic;
	signal sub_dram_fifo_cnt : out std_logic;
	signal add_dram_cnt : out std_logic;
	signal data_fifo_waddr : out std_logic_vector(11 downto 0);
	signal data_fifo_write : out std_logic;
	signal add_dram_rpage : out std_logic;
	signal add_data_fifo_cnt : out std_logic;
	signal sub_dram_cnt : out std_logic;
	signal data_fifo_wdata : out std_logic_vector(63 downto 0);
	signal dram_test_pattern : out std_logic_vector(63 downto 0);
	signal dram_ready : out std_logic;
	signal p_dram_dsp : out std_logic_vector(1 downto 0);
	signal p_dram_dsn : out std_logic_vector(1 downto 0);
	signal p_dram_a : out std_logic_vector(13 downto 0);
	signal p_dram_ba : out std_logic_vector(2 downto 0);
	signal p_dram_cs : out std_logic;
	signal p_dram_ras : out std_logic;
	signal p_dram_cas : out std_logic;
	signal p_dram_we : out std_logic;
	signal p_dram_clke : out std_logic;
	signal p_dram_odt : out std_logic;
	signal p_dram_reset : out std_logic
); end dram_controller;

architecture Behavioral of dram_controller is

component dram_timing port(
	signal dram_enable : in std_logic;
	signal dram_stop : in std_logic;
	signal dram_fifo_empty : in std_logic;
	signal data_fifo_full : in std_logic;
	signal dram_full : in std_logic;
	signal dram_empty : in std_logic;
	signal dram_test_wr : in std_logic;
	signal dram_test_rd : in std_logic;
	signal dram_test_on : in std_logic;
	signal clk_dram : in std_logic;
	signal write_dram : out std_logic;
	signal read_dram : out std_logic;
	signal refresh_dram : out std_logic;
	signal dram_ready : out std_logic
); end component;

signal write_dram : std_logic;
signal read_dram : std_logic;
signal refresh_dram : std_logic;
signal dram_ready_reg : std_logic;

component dram_write port(
	signal dram_test_on : in std_logic;
	signal dram_wpage : in std_logic_vector(16 downto 0);
	signal write_dram : in std_logic;
	signal reset_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal dram_fifo_raddr : out std_logic_vector(13 downto 0);
	signal dram_wa : out std_logic_vector(13 downto 0);
	signal dram_wba : out std_logic_vector(2 downto 0);
	signal dram_wcs : out std_logic;
	signal dram_wras : out std_logic;
	signal dram_wcas : out std_logic;
	signal dram_wmwe : out std_logic;
	signal p3emd : out std_logic;
	signal p5omds : out std_logic;
	signal p5emds : out std_logic;
	signal add_dram_wpage : out std_logic;
	signal sub_dram_fifo_cnt : out std_logic;
	signal add_dram_cnt : out std_logic
); end component;

signal dram_wa : std_logic_vector(13 downto 0);
signal dram_wba : std_logic_vector(2 downto 0);
signal dram_wcs : std_logic;
signal dram_wras : std_logic;
signal dram_wcas : std_logic;
signal dram_wmwe : std_logic;
signal p3emd : std_logic;
signal p5omds : std_logic;
signal p5emds : std_logic;

component dram_read port(
	signal dram_test_on : in std_logic;
	signal dram_rpage : in std_logic_vector(16 downto 0);
	signal read_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal dram_test_clr : out std_logic;
	signal dram_test_and : out std_logic;
	signal data_fifo_waddr : out std_logic_vector(11 downto 0);
	signal dram_ra : out std_logic_vector(13 downto 0);
	signal dram_rba : out std_logic_vector(2 downto 0);
	signal dram_rcs : out std_logic;
	signal dram_rras : out std_logic;
	signal dram_rcas : out std_logic;
	signal dram_rmwe : out std_logic;
	signal data_fifo_write : out std_logic;
	signal add_dram_rpage : out std_logic;
	signal add_data_fifo_cnt : out std_logic;
	signal sub_dram_cnt : out std_logic
); end component;

signal dram_test_clr : std_logic;
signal dram_test_and : std_logic;
signal dram_ra : std_logic_vector(13 downto 0);
signal dram_rba : std_logic_vector(2 downto 0);
signal dram_rcs : std_logic;
signal dram_rras : std_logic;
signal dram_rcas : std_logic;
signal dram_rmwe : std_logic;

component dram_refresh port(
	signal refresh_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal dram_fcs : out std_logic;
	signal dram_fras : out std_logic;
	signal dram_fcas : out std_logic
); end component;

signal dram_fcs : std_logic;
signal dram_fras : std_logic;
signal dram_fcas : std_logic;

component dram_init port(
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
); end component;
	
signal dram_scs : std_logic;
signal dram_sa : std_logic_vector(13 downto 0);
signal dram_sba : std_logic_vector(2 downto 0);
signal dram_sras : std_logic;
signal dram_scas : std_logic;
signal dram_smwe : std_logic;
signal dram_enable : std_logic;

component dram_signal port(
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
); end component;

component dram_md port(
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
); end component;

signal dram_pattern : std_logic_vector(63 downto 0);

component dram_mds port(
	signal p5omds : in std_logic;
	signal p5emds : in std_logic;
	signal reset_serdes_mds : in std_logic;
	signal x2clk90_dram : in std_logic;
	signal clk_dram : in std_logic;
	signal clk45_dram : in std_logic;
	signal p_dram_dsp : out std_logic_vector(1 downto 0);
	signal p_dram_dsn : out std_logic_vector(1 downto 0)
); end component;

component dram_alignment port(
	signal dram_pattern : in std_logic_vector(63 downto 0);
	signal dram_test_clr : in std_logic;
	signal dram_test_and : in std_logic;
	signal clk_dram : in std_logic;
	signal clk : in std_logic;
	signal dram_test_pattern : out std_logic_vector(63 downto 0)
); end component;

begin

	u1 : dram_timing port map(
		dram_enable => dram_enable,
		dram_stop => dram_stop,
		dram_fifo_empty => dram_fifo_empty,
		data_fifo_full => data_fifo_full,
		dram_full => dram_full,
		dram_empty => dram_empty,
		dram_test_wr => dram_test_wr,
		dram_test_rd => dram_test_rd,
		dram_test_on => dram_test_on,
		clk_dram => clk_dram,
		write_dram => write_dram,
		read_dram => read_dram,
		refresh_dram => refresh_dram,
		dram_ready => dram_ready_reg
	);

	dram_ready <= dram_ready_reg;
	
	u2 : dram_write port map(
		dram_test_on => dram_test_on,
		dram_wpage => dram_wpage,
		write_dram => write_dram,
		reset_dram => reset_dram,
		clk_dram => clk_dram,
		dram_fifo_raddr => dram_fifo_raddr,
		dram_wa => dram_wa,
		dram_wba => dram_wba,
		dram_wcs => dram_wcs,
		dram_wras => dram_wras,
		dram_wcas => dram_wcas,
		dram_wmwe => dram_wmwe,
		p3emd => p3emd,
		p5omds => p5omds,
		p5emds => p5emds,
		add_dram_wpage => add_dram_wpage,
		sub_dram_fifo_cnt => sub_dram_fifo_cnt,
		add_dram_cnt => add_dram_cnt
	);

	u3 : dram_read port map(
		dram_test_on => dram_test_on,
		dram_rpage => dram_rpage,
		read_dram => read_dram,
		clk_dram => clk_dram,
		dram_test_clr => dram_test_clr,
		dram_test_and => dram_test_and,
		data_fifo_waddr => data_fifo_waddr,
		dram_ra => dram_ra,
		dram_rba => dram_rba,
		dram_rcs => dram_rcs,
		dram_rras => dram_rras,
		dram_rcas => dram_rcas,
		dram_rmwe => dram_rmwe,
		data_fifo_write => data_fifo_write,
		add_dram_rpage => add_dram_rpage,
		add_data_fifo_cnt => add_data_fifo_cnt,
		sub_dram_cnt => sub_dram_cnt
	);

	u4 : dram_refresh port map(
		refresh_dram => refresh_dram,
		clk_dram => clk_dram,
		dram_fcs => dram_fcs,
		dram_fras => dram_fras,
		dram_fcas => dram_fcas
	);

	u5 : dram_init port map(
		dram_ready => dram_ready_reg,
		dram_start => dram_start,
		dram_stop => dram_stop,
		reset_serdes_md => reset_serdes_md,
		x2clk_dram => x2clk_dram,
		clk_dram => clk_dram,
		dram_scs => dram_scs,
		dram_sa => dram_sa,
		dram_sba => dram_sba,
		dram_sras => dram_sras,
		dram_scas => dram_scas,
		dram_smwe => dram_smwe,
		dram_enable => dram_enable,
		p_dram_clke => p_dram_clke,
		p_dram_reset => p_dram_reset
	);

	u6 : dram_signal port map(
		dram_wa => dram_wa,
		dram_ra => dram_ra,
		dram_sa => dram_sa,
		dram_wba => dram_wba,
		dram_rba => dram_rba,
		dram_sba => dram_sba,
		dram_wcs => dram_wcs,
		dram_rcs => dram_rcs,
		dram_fcs => dram_fcs,
		dram_scs => dram_scs,
		dram_wras => dram_wras,
		dram_rras => dram_rras,
		dram_fras => dram_fras,
		dram_sras => dram_sras,
		dram_wcas => dram_wcas,
		dram_rcas => dram_rcas,
		dram_fcas => dram_fcas,
		dram_scas => dram_scas,
		dram_wmwe => dram_wmwe,
		dram_rmwe => dram_rmwe,
		dram_smwe => dram_smwe,
		reset_serdes_md => reset_serdes_md,
		x2clk_dram => x2clk_dram,
		clk_dram => clk_dram,
		p_dram_a => p_dram_a,
		p_dram_ba => p_dram_ba,
		p_dram_cs => p_dram_cs,
		p_dram_ras => p_dram_ras,
		p_dram_cas => p_dram_cas,
		p_dram_we => p_dram_we,
		p_dram_odt => p_dram_odt
	);

	u7 : dram_md port map(
		p_dram_d => p_dram_d,
		dram_test_on => dram_test_on,
		dram_fifo_rdata => dram_fifo_rdata,
		p3emd => p3emd,
		dram_idly => dram_idly,
		wdram_idly => wdram_idly,
		dram_bitslip => dram_bitslip,
		reset_serdes_md => reset_serdes_md,
		x2clk_dram => x2clk_dram,
		clk_dram => clk_dram,
		dram_pattern => dram_pattern,
		data_fifo_wdata => data_fifo_wdata
	);

	u8 : dram_mds port map(
		p5omds => p5omds,
		p5emds => p5emds,
		reset_serdes_mds => reset_serdes_mds,
		x2clk90_dram => x2clk90_dram,
		clk_dram => clk_dram,
		clk45_dram => clk45_dram,
		p_dram_dsp => p_dram_dsp,
		p_dram_dsn => p_dram_dsn
	);

	u9 : dram_alignment port map(
		dram_pattern => dram_pattern,
		dram_test_clr => dram_test_clr,
		dram_test_and => dram_test_and,
		clk_dram => clk_dram,
		clk => clk,
		dram_test_pattern => dram_test_pattern
	);

end Behavioral;


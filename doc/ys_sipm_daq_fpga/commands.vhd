library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity commands is port(
	signal command : in std_logic_vector(5 downto 1);
	signal sendcom : in std_logic;
	signal reg_wch : in std_logic_vector(4 downto 0);
	signal reg_waddr : in std_logic_vector(5 downto 0);
	signal reg_wdata : in std_logic_vector(27 downto 0);
	signal reg_wr : in std_logic;
	signal clk : in std_logic;
	signal clk_dram : in std_logic;
	signal reset : out std_logic;
	signal reset_dram : out std_logic;
	signal start : out std_logic;
	signal stop : out std_logic;
	signal drs_on : out std_logic;
--	signal cw : out std_logic_vector(3 downto 0);
	signal hv_data : out hv_data_array;
	signal hv_write : out std_logic_vector(3 downto 0);
	signal thr_data : out thr_data_array;
	signal thr_write : out std_logic_vector(31 downto 0);
	signal dram_start : out std_logic;
	signal dram_stop : out std_logic;
	signal dram_test_wr : out std_logic;
	signal dram_test_rd : out std_logic;
	signal dram_test_on : out std_logic;
	signal drs_rofs : out std_logic_vector(11 downto 0);
	signal drs_oofs : out std_logic_vector(11 downto 0);
	signal dac_ofs_write : out std_logic;
	signal drs_calib : out std_logic;
	signal adc_saddr : out std_logic_vector(7 downto 0);
	signal adc_sdata : out std_logic_vector(7 downto 0);
	signal adc_write : out std_logic;
	signal reset_refclk : out std_logic;
	signal dram_idly : out dram_idly_array;
	signal wdram_idly : out std_logic_vector(1 downto 0);
	signal dram_bitslip : out std_logic_vector(1 downto 0)
); end commands;

architecture Behavioral of commands is

component one_shot_inter_clock port(
	signal wsig : in std_logic;
	signal wclk : in std_logic;
	signal rclk : in std_logic;
	signal rsig : out std_logic
); end component;

signal reset_reg : std_logic;
signal reset_dram_reg : std_logic;
signal start_reg : std_logic;
signal stop_reg : std_logic;
signal drs_on_reg : std_logic := '0';
--signal cw_reg : std_logic_vector(3 downto 0) := "0010";
signal hv_data_reg : hv_data_array;
signal hv_write_reg : std_logic_vector(3 downto 0);
signal thr_data_reg : thr_data_array;
signal thr_write_reg : std_logic_vector(31 downto 0);
signal dram_start_reg : std_logic;
signal dram_stop_reg : std_logic;
signal dram_test_wr_reg : std_logic;
signal dram_test_rd_reg : std_logic;
signal dram_test_on_reg : std_logic;
signal drs_rofs_reg : std_logic_vector(11 downto 0);
signal drs_oofs_reg : std_logic_vector(11 downto 0);
signal dac_ofs_write_reg : std_logic;
signal drs_calib_reg : std_logic := '0';
signal adc_saddr_reg : std_logic_vector(7 downto 0);
signal adc_sdata_reg : std_logic_vector(7 downto 0);
signal adc_write_reg : std_logic;
signal reset_refclk_reg : std_logic;
signal dram_idly_reg : dram_idly_array;
signal wdram_idly_reg : std_logic_vector(1 downto 0);
signal dram_bitslip_reg : std_logic_vector(1 downto 0);

signal sel_ch : std_logic_vector(31 downto 0);
--signal sel_addr_cw : std_logic;
signal sel_addr_hv : std_logic;
signal sel_addr_thr : std_logic;
signal sel_addr_dram_onoff : std_logic;
signal sel_addr_dram_test : std_logic;
signal sel_addr_dac_ofs : std_logic;
signal sel_addr_drs_calib : std_logic;
signal sel_addr_adc_setup : std_logic;
signal sel_addr_reset_refclk : std_logic;
signal sel_addr_dram_idly : std_logic;
signal sel_addr_dram_bitslip : std_logic;

--signal wen_cw : std_logic;
signal wen_hv : std_logic_vector(3 downto 0);
signal wen_thr : std_logic_vector(31 downto 0);
signal wen_dram_onoff : std_logic;
signal wen_dram_test : std_logic;
signal wen_dac_ofs : std_logic;
signal wen_drs_calib : std_logic;
signal wen_adc_setup : std_logic;
signal wen_dram_idly : std_logic_vector(1 downto 0);

signal dram_start_clk : std_logic;
signal dram_stop_clk : std_logic;
signal dram_test_wr_clk : std_logic;
signal dram_test_rd_clk : std_logic;
signal dram_test_on_clk : std_logic;
signal dram_test_off_clk : std_logic;
signal dram_test_set : std_logic;
signal dram_test_clr : std_logic;
signal dram_idly_clk : dram_idly_array;
signal write_dram_idly_clk : std_logic_vector(1 downto 0);
signal dram_bitslip_clk : std_logic_vector(1 downto 0);
signal dram_adj_enable : std_logic := '0';
signal start_drs : std_logic;
signal stop_drs : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		reset_reg <= sendcom and command(1);
		start_reg <= sendcom and command(2);
		stop_reg <= sendcom and command(3);
		start_drs <= sendcom and command(4);
		stop_drs <= sendcom and command(5);
		
		if (stop_drs = '1') then
			drs_on_reg <= '0';
		elsif (start_drs = '1') then
			drs_on_reg <= '1';
		end if;
		
		sel_ch(0) <= (not reg_wch(4)) and (not reg_wch(3)) and (not reg_wch(2)) and (not reg_wch(1)) and (not reg_wch(0)); 
		sel_ch(1) <= (not reg_wch(4)) and (not reg_wch(3)) and (not reg_wch(2)) and (not reg_wch(1)) and reg_wch(0); 
		sel_ch(2) <= (not reg_wch(4)) and (not reg_wch(3)) and (not reg_wch(2)) and reg_wch(1) and (not reg_wch(0)); 
		sel_ch(3) <= (not reg_wch(4)) and (not reg_wch(3)) and (not reg_wch(2)) and reg_wch(1) and reg_wch(0); 
		sel_ch(4) <= (not reg_wch(4)) and (not reg_wch(3)) and reg_wch(2) and (not reg_wch(1)) and (not reg_wch(0)); 
		sel_ch(5) <= (not reg_wch(4)) and (not reg_wch(3)) and reg_wch(2) and (not reg_wch(1)) and reg_wch(0); 
		sel_ch(6) <= (not reg_wch(4)) and (not reg_wch(3)) and reg_wch(2) and reg_wch(1) and (not reg_wch(0)); 
		sel_ch(7) <= (not reg_wch(4)) and (not reg_wch(3)) and reg_wch(2) and reg_wch(1) and reg_wch(0); 
		sel_ch(8) <= (not reg_wch(4)) and reg_wch(3) and (not reg_wch(2)) and (not reg_wch(1)) and (not reg_wch(0)); 
		sel_ch(9) <= (not reg_wch(4)) and reg_wch(3) and (not reg_wch(2)) and (not reg_wch(1)) and reg_wch(0); 
		sel_ch(10) <= (not reg_wch(4)) and reg_wch(3) and (not reg_wch(2)) and reg_wch(1) and (not reg_wch(0)); 
		sel_ch(11) <= (not reg_wch(4)) and reg_wch(3) and (not reg_wch(2)) and reg_wch(1) and reg_wch(0); 
		sel_ch(12) <= (not reg_wch(4)) and reg_wch(3) and reg_wch(2) and (not reg_wch(1)) and (not reg_wch(0)); 
		sel_ch(13) <= (not reg_wch(4)) and reg_wch(3) and reg_wch(2) and (not reg_wch(1)) and reg_wch(0); 
		sel_ch(14) <= (not reg_wch(4)) and reg_wch(3) and reg_wch(2) and reg_wch(1) and (not reg_wch(0)); 
		sel_ch(15) <= (not reg_wch(4)) and reg_wch(3) and reg_wch(2) and reg_wch(1) and reg_wch(0); 
		sel_ch(16) <= reg_wch(4) and (not reg_wch(3)) and (not reg_wch(2)) and (not reg_wch(1)) and (not reg_wch(0)); 
		sel_ch(17) <= reg_wch(4) and (not reg_wch(3)) and (not reg_wch(2)) and (not reg_wch(1)) and reg_wch(0); 
		sel_ch(18) <= reg_wch(4) and (not reg_wch(3)) and (not reg_wch(2)) and reg_wch(1) and (not reg_wch(0)); 
		sel_ch(19) <= reg_wch(4) and (not reg_wch(3)) and (not reg_wch(2)) and reg_wch(1) and reg_wch(0); 
		sel_ch(20) <= reg_wch(4) and (not reg_wch(3)) and reg_wch(2) and (not reg_wch(1)) and (not reg_wch(0)); 
		sel_ch(21) <= reg_wch(4) and (not reg_wch(3)) and reg_wch(2) and (not reg_wch(1)) and reg_wch(0); 
		sel_ch(22) <= reg_wch(4) and (not reg_wch(3)) and reg_wch(2) and reg_wch(1) and (not reg_wch(0)); 
		sel_ch(23) <= reg_wch(4) and (not reg_wch(3)) and reg_wch(2) and reg_wch(1) and reg_wch(0); 
		sel_ch(24) <= reg_wch(4) and reg_wch(3) and (not reg_wch(2)) and (not reg_wch(1)) and (not reg_wch(0)); 
		sel_ch(25) <= reg_wch(4) and reg_wch(3) and (not reg_wch(2)) and (not reg_wch(1)) and reg_wch(0); 
		sel_ch(26) <= reg_wch(4) and reg_wch(3) and (not reg_wch(2)) and reg_wch(1) and (not reg_wch(0)); 
		sel_ch(27) <= reg_wch(4) and reg_wch(3) and (not reg_wch(2)) and reg_wch(1) and reg_wch(0); 
		sel_ch(28) <= reg_wch(4) and reg_wch(3) and reg_wch(2) and (not reg_wch(1)) and (not reg_wch(0)); 
		sel_ch(29) <= reg_wch(4) and reg_wch(3) and reg_wch(2) and (not reg_wch(1)) and reg_wch(0); 
		sel_ch(30) <= reg_wch(4) and reg_wch(3) and reg_wch(2) and reg_wch(1) and (not reg_wch(0)); 
		sel_ch(31) <= reg_wch(4) and reg_wch(3) and reg_wch(2) and reg_wch(1) and reg_wch(0); 

--		sel_addr_cw <= (not reg_waddr(5)) and (not reg_waddr(4)) and (not reg_waddr(3)) and (not reg_waddr(2)) and (not reg_waddr(1)) and reg_waddr(0); 
		sel_addr_hv <= (not reg_waddr(5)) and (not reg_waddr(4)) and (not reg_waddr(3)) and (not reg_waddr(2)) and reg_waddr(1) and (not reg_waddr(0)); 
		sel_addr_thr <= (not reg_waddr(5)) and (not reg_waddr(4)) and (not reg_waddr(3)) and (not reg_waddr(2)) and reg_waddr(1) and reg_waddr(0); 
		sel_addr_dram_onoff <= (not reg_waddr(5)) and (not reg_waddr(4)) and (not reg_waddr(3)) and reg_waddr(2) and reg_waddr(1) and (not reg_waddr(0)); 
		sel_addr_dram_test <= (not reg_waddr(5)) and (not reg_waddr(4)) and (not reg_waddr(3)) and reg_waddr(2) and reg_waddr(1) and reg_waddr(0); 

		sel_addr_dac_ofs <= reg_waddr(5) and (not reg_waddr(4)) and (not reg_waddr(3)) and (not reg_waddr(2)) and (not reg_waddr(1)) and (not reg_waddr(0)); 
		sel_addr_drs_calib <= reg_waddr(5) and (not reg_waddr(4)) and (not reg_waddr(3)) and (not reg_waddr(2)) and (not reg_waddr(1)) and reg_waddr(0); 
		sel_addr_adc_setup <= reg_waddr(5) and (not reg_waddr(4)) and (not reg_waddr(3)) and (not reg_waddr(2)) and reg_waddr(1) and (not reg_waddr(0)); 
		sel_addr_reset_refclk <= reg_waddr(5) and (not reg_waddr(4)) and (not reg_waddr(3)) and (not reg_waddr(2)) and reg_waddr(1) and reg_waddr(0); 
		sel_addr_dram_idly <= reg_waddr(5) and (not reg_waddr(4)) and (not reg_waddr(3)) and reg_waddr(2) and (not reg_waddr(1)) and (not reg_waddr(0)); 
		sel_addr_dram_bitslip <= reg_waddr(5) and (not reg_waddr(4)) and (not reg_waddr(3)) and reg_waddr(2) and (not reg_waddr(1)) and reg_waddr(0); 

--		wen_cw <= reg_wr and sel_addr_cw;

		for ch in 0 to 3 loop
			wen_hv(ch) <= reg_wr and sel_addr_hv and sel_ch(ch);
		end loop;

		for ch in 0 to 31 loop
			wen_thr(ch) <= reg_wr and sel_addr_thr and sel_ch(ch);
		end loop;

		wen_dram_onoff <= reg_wr and sel_addr_dram_onoff;
		wen_dram_test <= reg_wr and sel_addr_dram_test;
		wen_dac_ofs <= reg_wr and sel_addr_dac_ofs;
		wen_drs_calib <= reg_wr and sel_addr_drs_calib;
		wen_adc_setup <= reg_wr and sel_addr_adc_setup;

		for ch in 0 to 1 loop
			wen_dram_idly(ch) <= reg_wr and sel_addr_dram_idly and sel_ch(ch);
		end loop;
		
--		if (wen_cw = '1') then
--			cw_reg <= reg_wdata(3 downto 0);
--		end if;
		
		for ch in 0 to 3 loop
			if (wen_hv(ch) = '1') then
				hv_data_reg(ch) <= reg_wdata(7 downto 0);
			end if;
			hv_write_reg(ch) <= wen_hv(ch);
		end loop;

		for ch in 0 to 31 loop
			if (wen_thr(ch) = '1') then
				thr_data_reg(ch) <= reg_wdata(11 downto 0);
			end if;
			thr_write_reg(ch) <= wen_thr(ch);
		end loop;

		dram_start_clk <= wen_dram_onoff and reg_wdata(0);
		dram_stop_clk <= wen_dram_onoff and (not reg_wdata(0));

		dram_test_off_clk <= wen_dram_test and (not reg_wdata(1)) and (not reg_wdata(0));
		dram_test_on_clk <= wen_dram_test and (not reg_wdata(1)) and reg_wdata(0);
		dram_test_wr_clk <= wen_dram_test and reg_wdata(1) and (not reg_wdata(0));
		dram_test_rd_clk <= wen_dram_test and reg_wdata(1) and reg_wdata(0);

		if (dram_test_off_clk = '1') then
			dram_adj_enable <= '0';
		elsif (dram_test_on_clk = '1') then
			dram_adj_enable <= '1';
		end if;

		if (wen_dac_ofs = '1') then
			drs_rofs_reg <= reg_wdata(11 downto 0);
			drs_oofs_reg <= reg_wdata(27 downto 16);
		end if;
		dac_ofs_write_reg <= wen_dac_ofs;

		if (wen_drs_calib = '1') then
			drs_calib_reg <= reg_wdata(0);
		end if;
		
		if (wen_adc_setup = '1') then
			adc_sdata_reg <= reg_wdata(7 downto 0);
			adc_saddr_reg <= reg_wdata(15 downto 8);
		end if;
		adc_write_reg <= wen_adc_setup;

		reset_refclk_reg <= reg_wr and sel_addr_reset_refclk;

		for ch in 0 to 1 loop
			if (wen_dram_idly(ch) = '1') then
				dram_idly_clk(ch) <= reg_wdata(4 downto 0);
			end if;
			write_dram_idly_clk(ch) <= wen_dram_idly(ch);

			dram_bitslip_clk(ch) <= reg_wr and dram_adj_enable and sel_addr_dram_bitslip;
		end loop;

	end if;
	end process;

	osic_reset_dram : one_shot_inter_clock port map(
		wsig => reset_reg,
		wclk => clk,
		rclk => clk_dram,
		rsig => reset_dram_reg
	);

	osic_dram_start : one_shot_inter_clock port map(
		wsig => dram_start_clk,
		wclk => clk,
		rclk => clk_dram,
		rsig => dram_start_reg
	);

	osic_dram_stop : one_shot_inter_clock port map(
		wsig => dram_stop_clk,
		wclk => clk,
		rclk => clk_dram,
		rsig => dram_stop_reg
	);

	myloop1 : for ch in 0 to 1 generate
		osic_write_dram_idly : one_shot_inter_clock port map(
			wsig => write_dram_idly_clk(ch),
			wclk => clk,
			rclk => clk_dram,
			rsig => wdram_idly_reg(ch)
		);

		osic_dram_bitslip : one_shot_inter_clock port map(
			wsig => dram_bitslip_clk(ch),
			wclk => clk,
			rclk => clk_dram,
			rsig => dram_bitslip_reg(ch)
		);
	end generate;

	osic_dram_test_wr : one_shot_inter_clock port map(
		wsig => dram_test_wr_clk,
		wclk => clk,
		rclk => clk_dram,
		rsig => dram_test_wr_reg
	);

	osic_dram_test_rd : one_shot_inter_clock port map(
		wsig => dram_test_rd_clk,
		wclk => clk,
		rclk => clk_dram,
		rsig => dram_test_rd_reg
	);

	osic_dram_test_on : one_shot_inter_clock port map(
		wsig => dram_test_on_clk,
		wclk => clk,
		rclk => clk_dram,
		rsig => dram_test_set
	);

	osic_dram_test_off : one_shot_inter_clock port map(
		wsig => dram_test_off_clk,
		wclk => clk,
		rclk => clk_dram,
		rsig => dram_test_clr
	);

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then

		dram_idly_reg <= dram_idly_clk;

		if (dram_test_clr = '1') then
			dram_test_on_reg <= '0';
		elsif (dram_test_set = '1') then
			dram_test_on_reg <= '1';
		end if;
		
	end if;
	end process;

	reset <= reset_reg;
	reset_dram <= reset_dram_reg;
	start <= start_reg;
	stop <= stop_reg;
	drs_on <= drs_on_reg;
--	cw <= cw_reg;
	hv_data <= hv_data_reg;
	hv_write <= hv_write_reg;
	thr_data <= thr_data_reg;
	thr_write <= thr_write_reg;
	dram_start <= dram_start_reg;
	dram_stop <= dram_stop_reg;
	dram_test_wr <= dram_test_wr_reg;
	dram_test_rd <= dram_test_rd_reg;
	dram_test_on <= dram_test_on_reg;
	drs_rofs <= drs_rofs_reg;
	drs_oofs <= drs_oofs_reg;
	dac_ofs_write <= dac_ofs_write_reg;
	drs_calib <= drs_calib_reg;
	adc_saddr <= adc_saddr_reg;
	adc_sdata <= adc_sdata_reg;
	adc_write <= adc_write_reg;
	reset_refclk <= reset_refclk_reg;
	dram_idly <= dram_idly_reg;
	wdram_idly <= wdram_idly_reg;
	dram_bitslip <= dram_bitslip_reg;

end Behavioral;

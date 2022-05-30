library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity tcb_read is port(
	signal sidat : in std_logic;
	signal linkok : in std_logic;
	signal run : in std_logic;
	signal link_enable : in std_logic;
	signal mod_mid : in std_logic_vector(7 downto 0);
	signal tcb_mid : in std_logic_vector(7 downto 0);
	signal tcb_com : in std_logic_vector(5 downto 1);
	signal tcb_din_timer : in std_logic_vector(47 downto 0);
	signal tcb_din_trig_type : in std_logic_vector(1 downto 0);
	signal tcb_din_trig_ch : in std_logic_vector(4 downto 0);
	signal tcb_din_trig_addr : in std_logic_vector(5 downto 0);
	signal tcb_din_trig_data : in std_logic_vector(27 downto 0);
	signal tcb_recv : in std_logic;
	signal daq_busy : in std_logic;
	signal clk : in std_logic;
	signal run_number : out std_logic_vector(15 downto 0);
	signal local_ctime : out std_logic_vector(47 downto 0);
	signal local_ftime : out std_logic_vector(6 downto 0);
	signal adc_en : out std_logic;
	signal trig_type : out std_logic_vector(1 downto 0);
	signal trig_number : out std_logic_vector(31 downto 0);
	signal trig_ctime : out std_logic_vector(47 downto 0);
	signal trig_ftime : out std_logic_vector(6 downto 0);
	signal triged : out std_logic;
	signal command : out std_logic_vector(5 downto 1);
	signal sendcom : out std_logic;
	signal reg_wch : out std_logic_vector(4 downto 0);
	signal reg_waddr : out std_logic_vector(5 downto 0);
	signal reg_wdata : out std_logic_vector(27 downto 0);
	signal reg_wr : out std_logic;
	signal reg_rch : out std_logic_vector(4 downto 0);
	signal reg_raddr : out std_logic_vector(4 downto 0);
	signal reg_rd : out std_logic;
	signal reg_latch : out std_logic;
	signal p_adc_clkp : out std_logic_vector(3 downto 0);
	signal p_adc_clkn : out std_logic_vector(3 downto 0);
	signal p_drs_clkp : out std_logic_vector(3 downto 0);
	signal p_drs_clkn : out std_logic_vector(3 downto 0)
); end tcb_read;

architecture Behavioral of tcb_read is

signal run_number_reg : std_logic_vector(15 downto 0);
signal local_ctime_reg : std_logic_vector(47 downto 0);
signal local_ftime_reg : std_logic_vector(6 downto 0);
signal adc_en_reg : std_logic;
signal trig_type_reg : std_logic_vector(1 downto 0);
signal trig_number_reg : std_logic_vector(31 downto 0);
signal trig_ctime_reg : std_logic_vector(47 downto 0);
signal trig_ftime_reg : std_logic_vector(6 downto 0);
signal triged_reg : std_logic;
signal command_reg : std_logic_vector(5 downto 1);
signal sendcom_reg : std_logic;
signal reg_wch_reg : std_logic_vector(4 downto 0);
signal reg_waddr_reg : std_logic_vector(5 downto 0);
signal reg_wdata_reg : std_logic_vector(27 downto 0);
signal reg_wr_reg : std_logic;
signal reg_rch_reg : std_logic_vector(4 downto 0);
signal reg_raddr_reg : std_logic_vector(4 downto 0);
signal reg_rd_reg : std_logic;
signal reg_latch_reg : std_logic;
signal adc_clk : std_logic_vector(3 downto 0);
signal drs_clk : std_logic_vector(3 downto 0);

signal encom : std_logic;
signal midmat : std_logic;
signal enwrite : std_logic;
signal denwrite : std_logic;
signal cen : std_logic;
signal cnt : std_logic_vector(6 downto 0);
signal clr : std_logic;
signal trig_sr : std_logic_vector(47 downto 0);
signal get_type : std_logic;
signal get_ftime : std_logic;
signal get_ctime : std_logic;
signal get_trg_n : std_logic;
signal get_run_n : std_logic;
signal ipadc_clk : std_logic;
signal padc_clk : std_logic;
signal iadc_en : std_logic;
signal ipdrs_clk : std_logic;
signal pdrs_clk : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		if (tcb_recv = '1') then
			local_ctime_reg <= tcb_din_timer;
		end if;
		
		if (tcb_recv = '1') then
			local_ftime_reg <= (others => '0');
		else
			local_ftime_reg <= local_ftime_reg + 1;
		end if;
		
		encom <= tcb_recv and (tcb_com(1) or tcb_com(2) or tcb_com(3) or tcb_com(4) or tcb_com(5));
		sendcom_reg <= encom;
		
		if (encom = '1') then
			command_reg <= tcb_com;
		end if;
		
		if (tcb_mid = mod_mid) then
			midmat <= '1';
		else
			midmat <= '0';
		end if;

		enwrite <= (not run) and tcb_recv and midmat and (not tcb_din_trig_type(1)) and tcb_din_trig_type(0);
		denwrite <= enwrite;
		reg_wr_reg <= denwrite;
		
		reg_rd_reg <= (not run) and tcb_recv and midmat and tcb_din_trig_type(1) and tcb_din_trig_type(0);

		if (enwrite = '1') then
			reg_wch_reg <= tcb_din_trig_ch;
			reg_waddr_reg <= tcb_din_trig_addr;
			reg_wdata_reg <= tcb_din_trig_data;
		end if;

		if (reg_rd_reg = '1') then
			reg_rch_reg <= tcb_din_trig_ch;
			reg_raddr_reg <= tcb_din_trig_addr(4 downto 0);
		end if;
		
		reg_latch_reg <= reg_rd_reg;

		if (clr = '1') then
			cen <= '0';
		elsif (sidat = '1') then
			cen <= link_enable and linkok and run;
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(6) and cnt(5) and (not cnt(4)) 
		   and (not cnt(3)) and cnt(2) and cnt(1) and cnt(0);

		if (cen = '1') then
			trig_sr <= sidat & trig_sr(47 downto 1);
		end if;

		get_type <= (not cnt(6)) and (not cnt(5)) and (not cnt(4)) 
		        and (not cnt(3)) and (not cnt(2)) and (not cnt(1)) and cnt(0);

		get_ftime <= (not cnt(6)) and (not cnt(5)) and (not cnt(4)) 
		        and cnt(3) and (not cnt(2)) and (not cnt(1)) and (not cnt(0));

		get_ctime <= (not cnt(6)) and cnt(5) and cnt(4) 
		        and cnt(3) and (not cnt(2)) and (not cnt(1)) and (not cnt(0));

		get_trg_n <= cnt(6) and (not cnt(5)) and cnt(4) 
		        and cnt(3) and (not cnt(2)) and (not cnt(1)) and (not cnt(0));
				  
		get_run_n <= clr;
			
		if (get_type = '1') then
			trig_type_reg <= trig_sr(47 downto 46);
		end if;
			
		if (get_ftime = '1') then
			trig_ftime_reg <= trig_sr(47 downto 41);
		end if;
			
		if (get_ctime = '1') then
			trig_ctime_reg <= trig_sr;
		end if;
			
		if (get_trg_n = '1') then
			trig_number_reg <= trig_sr(47 downto 16);
		end if;
			
		if (get_run_n = '1') then
			run_number_reg <= trig_sr(47 downto 32);
		end if;
		
		triged_reg <= get_run_n and (not daq_busy);

		padc_clk <= link_enable and linkok and ipadc_clk;
		adc_clk(0) <= padc_clk;
		adc_clk(1) <= padc_clk;
		adc_clk(2) <= not padc_clk;
		adc_clk(3) <= not padc_clk;

		adc_en_reg <= link_enable and linkok and iadc_en;
		
		pdrs_clk <= link_enable and linkok and ipdrs_clk;
		drs_clk(0) <= pdrs_clk;
		drs_clk(1) <= pdrs_clk;
		drs_clk(2) <= pdrs_clk;
		drs_clk(3) <= pdrs_clk;
			
	end if;
	end process;

	rom128x1_padc_clk : ROM128X1
	generic map (INIT => X"0000000000E38E38E38E38E38E38E38E")
	port map (
		A0 => local_ftime_reg(0),
		A1 => local_ftime_reg(1),
		A2 => local_ftime_reg(2),
		A3 => local_ftime_reg(3),
		A4 => local_ftime_reg(4),
		A5 => local_ftime_reg(5),
		A6 => local_ftime_reg(6),
		O => ipadc_clk
	);

	rom128x1_adc_en : ROM128X1
	generic map (INIT => X"00000000010210210210210210210210")
	port map (
		A0 => local_ftime_reg(0),
		A1 => local_ftime_reg(1),
		A2 => local_ftime_reg(2),
		A3 => local_ftime_reg(3),
		A4 => local_ftime_reg(4),
		A5 => local_ftime_reg(5),
		A6 => local_ftime_reg(6),
		O => iadc_en
	);

	rom256x1_pdrs_clk : ROM256X1
	generic map (INIT => X"0000000000FFFFC0000FFFFC0000FFFFFFFFFFFFFF00003FFFF00003FFFF0000")
	port map (
		A0 => local_ftime_reg(0),
		A1 => local_ftime_reg(1),
		A2 => local_ftime_reg(2),
		A3 => local_ftime_reg(3),
		A4 => local_ftime_reg(4),
		A5 => local_ftime_reg(5),
		A6 => local_ftime_reg(6),
		A7 => local_ctime_reg(0),
		O => ipdrs_clk
	);

	run_number <= run_number_reg;
	local_ctime <= local_ctime_reg;
	local_ftime <= local_ftime_reg;
	adc_en <= adc_en_reg;
	trig_type <= trig_type_reg;
	trig_number <= trig_number_reg;
	trig_ctime <= trig_ctime_reg;
	trig_ftime <= trig_ftime_reg;
	triged <= triged_reg;
	command <= command_reg;
	sendcom <= sendcom_reg;
	reg_wch <= reg_wch_reg;
	reg_waddr <= reg_waddr_reg;
	reg_wdata <= reg_wdata_reg;
	reg_wr <= reg_wr_reg;
	reg_rch <= reg_rch_reg;
	reg_raddr <= reg_raddr_reg;
	reg_rd <= reg_rd_reg;
	reg_latch <= reg_latch_reg;

	obufds_adc_clk0 : obufds port map(i => adc_clk(0), o => p_adc_clkp(0), ob => p_adc_clkn(0));
	obufds_adc_clk1 : obufds port map(i => adc_clk(1), o => p_adc_clkp(1), ob => p_adc_clkn(1));
	obufds_adc_clk2 : obufds port map(i => adc_clk(2), o => p_adc_clkn(2), ob => p_adc_clkp(2));
	obufds_adc_clk3 : obufds port map(i => adc_clk(3), o => p_adc_clkn(3), ob => p_adc_clkp(3));

	obufds_drs_clk0 : obufds port map(i => drs_clk(0), o => p_drs_clkp(0), ob => p_drs_clkn(0));
	obufds_drs_clk1 : obufds port map(i => drs_clk(1), o => p_drs_clkp(1), ob => p_drs_clkn(1));
	obufds_drs_clk2 : obufds port map(i => drs_clk(2), o => p_drs_clkp(2), ob => p_drs_clkn(2));
	obufds_drs_clk3 : obufds port map(i => drs_clk(3), o => p_drs_clkp(3), ob => p_drs_clkn(3));

end Behavioral;

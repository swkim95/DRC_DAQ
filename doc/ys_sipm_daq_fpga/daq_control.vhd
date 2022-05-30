library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity daq_control is port(
	signal drs_fifo_rdata : in adc_data_array;
	signal run_number : in std_logic_vector(15 downto 0);
	signal local_ctime : in std_logic_vector(47 downto 0);
	signal local_ftime : in std_logic_vector(6 downto 0);
	signal trig_type : in std_logic_vector(1 downto 0);
	signal trig_number : in std_logic_vector(31 downto 0);
	signal trig_ctime : in std_logic_vector(47 downto 0);
	signal trig_ftime : in std_logic_vector(6 downto 0);
	signal mod_mid : in std_logic_vector(7 downto 0);
	signal trig_pattern : in std_logic_vector(31 downto 0);
	signal triged : in std_logic;
	signal drs_stop_addr : in std_logic_vector(9 downto 0);
	signal drs_read_end : in std_logic;
	signal drs_calib : in std_logic;
	signal drs_on : in std_logic;
	signal start : in std_logic;
	signal stop : in std_logic;
	signal reset : in std_logic;
	signal clk : in std_logic;
	signal run : out std_logic;
	signal trig_armed : out std_logic;
	signal drs_fifo_raddr : out std_logic_vector(9 downto 0);
	signal dram_fifo_wdata : out std_logic_vector(511 downto 0);
	signal dram_fifo_waddr : out std_logic_vector(10 downto 0);
	signal dram_fifo_write : out std_logic;
	signal add_dram_fifo_cnt : out std_logic
); end daq_control;

architecture Behavioral of daq_control is

signal run_reg : std_logic;
signal trig_armed_reg : std_logic;
signal drs_fifo_raddr_reg : std_logic_vector(9 downto 0);
signal dram_fifo_wdata_reg : std_logic_vector(511 downto 0);
signal dram_fifo_waddr_reg : std_logic_vector(10 downto 0);
signal dram_fifo_write_reg : std_logic;
signal add_dram_fifo_cnt_reg : std_logic;

signal ddrs_on : std_logic;
signal dreset : std_logic;
signal drs_run : std_logic;
signal iswaddr : std_logic_vector(9 downto 0);
signal swaddr : std_logic_vector(9 downto 0);
signal cen : std_logic;
signal cnt : std_logic_vector(9 downto 0);
signal clr : std_logic;
signal drs_daq_done : std_logic;
signal done_cen : std_logic;
signal done_cnt : std_logic_vector(9 downto 0);
signal local_trig_number : std_logic_vector(31 downto 0);
signal local_trig_ftime : std_logic_vector(6 downto 0);
signal local_trig_ctime : std_logic_vector(47 downto 0);
signal header : std_logic;
signal idram_fifo_wdata : std_logic_vector(511 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		if (reset = '1') then
			run_reg <= '0';
		elsif (stop = '1') then
			run_reg <= '0';
		elsif (start = '1') then
			run_reg <= '1';
		end if;
		
		ddrs_on <= drs_on;
		dreset <= reset;
		drs_run <= drs_daq_done or (drs_on and (not ddrs_on)) or ((not reset) and dreset);

		if (drs_on = '0') then
			trig_armed_reg <= '0';
		elsif (triged = '1') then
			trig_armed_reg <= '0';
		elsif (drs_run = '1') then
			trig_armed_reg <= '1';
		end if;

		if (drs_read_end = '1') then
			swaddr <= iswaddr;
		end if;

		if (reset = '1') then
			cen <= '0';
		elsif (clr = '1') then
			cen <= '0';
		elsif (drs_read_end = '1') then
			cen <= '1';
		end if;
		
		if (reset = '1') then
			cnt <= (others => '0');
		elsif (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(9) and cnt(8) and cnt(7) and cnt(6) and cnt(5)
		   and cnt(4) and cnt(3) and cnt(2) and cnt(1) and (not cnt(0));
			
		if (reset = '1') then
			local_trig_number <= (others => '0');
		elsif (clr = '1') then
			local_trig_number <= local_trig_number + 1;
		end if;
		
		if (triged = '1') then
			local_trig_ftime <= local_ftime;
			local_trig_ctime <= local_ctime;
		end if;
		
		drs_fifo_raddr_reg <= swaddr + cnt;

		dram_fifo_wdata_reg <= idram_fifo_wdata;
		
		if (reset = '1') then
			dram_fifo_waddr_reg <= (others => '0');
		elsif (dram_fifo_write_reg = '1') then
			dram_fifo_waddr_reg <= dram_fifo_waddr_reg + 1;
		end if;
		
		add_dram_fifo_cnt_reg <= dram_fifo_waddr_reg(9) and dram_fifo_waddr_reg(8) 
									and dram_fifo_waddr_reg(7) and dram_fifo_waddr_reg(6) 
									and dram_fifo_waddr_reg(5) and dram_fifo_waddr_reg(4)
									and dram_fifo_waddr_reg(3) and dram_fifo_waddr_reg(2) 
									and dram_fifo_waddr_reg(1)	and dram_fifo_waddr_reg(0) 
									and dram_fifo_write_reg;

		if (reset = '1') then
			done_cen <= '0';
		elsif (drs_daq_done = '1') then
			done_cen <= '0';
		elsif (clr = '1') then
			done_cen <= '1';
		end if;
		
		if (reset = '1') then
			done_cnt <= (others => '0');
		elsif (drs_daq_done = '1') then
			done_cnt <= (others => '0');
		elsif(done_cen = '1') then
			done_cnt <= done_cnt + 1;
		end if;
		
		drs_daq_done <= done_cnt(9) and done_cnt(8) and done_cnt(7) and done_cnt(6) 
					   and done_cnt(5) and done_cnt(4) and (not done_cnt(3)) 
						and (not done_cnt(2)) and done_cnt(1) and done_cnt(0);

	end if;
	end process;

	iswaddr <= drs_stop_addr when drs_calib = '0' else (others => '0');

	idram_fifo_wdata <= "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
	                  & "0000000000000000" 
							& local_trig_ctime(47 downto 32)
							& local_trig_ctime(31 downto 16)
							& local_trig_ctime(15 downto 0)
							& '0' & local_trig_ftime & trig_pattern(31 downto 24)
							& trig_pattern(23 downto 8)
							& trig_pattern(7 downto 0) & local_trig_number(31 downto 24)
							& local_trig_number(23 downto 8)
							& local_trig_number(7 downto 0) & mod_mid
							& trig_ctime(47 downto 32)
							& trig_ctime(31 downto 16)
							& trig_ctime(15 downto 0)
							& '0' & trig_ftime & trig_number(31 downto 24)
							& trig_number(23 downto 8)
							& trig_number(7 downto 0) & "000000" & trig_type
							& run_number
							& "0000000000000000"
							& "0000000000000001"	when header = '1'
	               else "0000" & drs_fifo_rdata(31)
						   & "0000" & drs_fifo_rdata(30)
						   & "0000" & drs_fifo_rdata(29)
						   & "0000" & drs_fifo_rdata(28)
						   & "0000" & drs_fifo_rdata(27)
						   & "0000" & drs_fifo_rdata(26)
						   & "0000" & drs_fifo_rdata(25)
						   & "0000" & drs_fifo_rdata(24)
						   & "0000" & drs_fifo_rdata(23)
						   & "0000" & drs_fifo_rdata(22)
						   & "0000" & drs_fifo_rdata(21)
						   & "0000" & drs_fifo_rdata(20)
						   & "0000" & drs_fifo_rdata(19)
						   & "0000" & drs_fifo_rdata(18)
						   & "0000" & drs_fifo_rdata(17)
						   & "0000" & drs_fifo_rdata(16)
						   & "0000" & drs_fifo_rdata(15)
						   & "0000" & drs_fifo_rdata(14)
						   & "0000" & drs_fifo_rdata(13)
						   & "0000" & drs_fifo_rdata(12)
						   & "0000" & drs_fifo_rdata(11)
						   & "0000" & drs_fifo_rdata(10)
						   & "0000" & drs_fifo_rdata(9)
						   & "0000" & drs_fifo_rdata(8)
						   & "0000" & drs_fifo_rdata(7)
						   & "0000" & drs_fifo_rdata(6)
						   & "0000" & drs_fifo_rdata(5)
						   & "0000" & drs_fifo_rdata(4)
						   & "0000" & drs_fifo_rdata(3)
						   & "0000" & drs_fifo_rdata(2)
						   & "0000" & drs_fifo_rdata(1)
						   & "0000" & drs_fifo_rdata(0);

	srl16e_header : SRL16E
	generic map(INIT => x"0000")
	port map(
		D => drs_read_end,
		A0 => '0',
		A1 => '1',
		A2 => '0',
		A3 => '0',
		CE => '1',
		CLK => clk,
		Q => header
	);

	srl16e_dram_fifo_write : SRL16E
	generic map(INIT => x"0000")
	port map(
		D => cen,
		A0 => '0',
		A1 => '1',
		A2 => '0',
		A3 => '0',
		CE => '1',
		CLK => clk,
		Q => dram_fifo_write_reg
	);

	run <= run_reg;
	trig_armed <= trig_armed_reg;
	drs_fifo_raddr <= drs_fifo_raddr_reg;
	dram_fifo_wdata <= dram_fifo_wdata_reg;
	dram_fifo_waddr <= dram_fifo_waddr_reg;
	dram_fifo_write <= dram_fifo_write_reg;
	add_dram_fifo_cnt <= add_dram_fifo_cnt_reg;

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity drs_ctrl_daq is port(
	signal p_drs_srout : in std_logic;
	signal triged : in std_logic;
	signal reset : in std_logic;
	signal adc_en : in std_logic;
	signal clk : in std_logic;
	signal drs_daq_a : out std_logic_vector(1 downto 0);
	signal drs_daq_srclk : out std_logic;
	signal drs_cal_raddr : out std_logic_vector(9 downto 0);
	signal drs_fifo_waddr : out std_logic_vector(9 downto 0);
	signal drs_fifo_write : out std_logic;
	signal drs_stop_addr : out std_logic_vector(9 downto 0);
	signal drs_read_done : out std_logic;
	signal drs_read_end : out std_logic;
	signal p_drs_rsrload : out std_logic_vector(3 downto 0)
); end drs_ctrl_daq;

architecture Behavioral of drs_ctrl_daq is

signal drs_srout_in : std_logic;
signal drs_srout : std_logic;
signal drs_daq_a_reg : std_logic_vector(1 downto 0);
signal drs_daq_srclk_reg : std_logic;
signal drs_cal_raddr_reg : std_logic_vector(9 downto 0);
signal drs_fifo_waddr_reg : std_logic_vector(9 downto 0);
signal drs_fifo_write_reg : std_logic;
signal drs_stop_addr_reg : std_logic_vector(9 downto 0);
signal drs_read_done_reg : std_logic;
signal drs_rsrload : std_logic_vector(3 downto 0);

signal dtriged : std_logic;
signal d2triged : std_logic;
signal d3triged : std_logic;
signal daqen : std_logic;
signal start_daq : std_logic;
signal cen : std_logic;
signal add_cnt : std_logic;
signal dadd_cnt : std_logic;
signal cnt : std_logic_vector(9 downto 0);
signal clr : std_logic;
signal dclr : std_logic;
signal d2clr : std_logic;
signal add_cal_raddr : std_logic;
signal pdrs_fifo_write : std_logic_vector(2 downto 0);
signal rcen : std_logic;
signal rcnt : std_logic_vector(5 downto 0);
signal rclr : std_logic;
signal pdrs_rsrload : std_logic;
signal rclk : std_logic;
signal shift_sp : std_logic;

attribute iob : string;
attribute iob of drs_srout : signal is "true";
attribute iob of drs_rsrload : signal is "true";

begin

	ibuf_drs_srout : ibuf port map(i => p_drs_srout, o => drs_srout_in);

	process(clk) begin
	if (clk'event and clk = '1') then

		dtriged <= triged;
		d2triged <= dtriged;
		d3triged <= d2triged;
		
		if (reset = '1') then
			drs_daq_a_reg(1) <= '0';
		elsif (d3triged = '1') then
			drs_daq_a_reg(1) <= '0';
		elsif (triged = '1') then
			drs_daq_a_reg(1) <= '1';
		end if;
		
		if (reset = '1') then
			daqen <= '0';
		elsif (triged = '1') then
			daqen <= '1';
		elsif (start_daq = '1') then
			daqen <= '0';
		end if;
		
		start_daq <= daqen and adc_en;
		
		if (reset = '1') then
			cen <= '0';
		elsif (clr = '1') then
			cen <= '0';
		elsif (start_daq = '1') then
			cen <= '1';
		end if;
		add_cnt <= cen and adc_en;
		dadd_cnt <= add_cnt;
		drs_daq_srclk_reg <= (drs_daq_a_reg(1) and dtriged) or dadd_cnt or rclk;
		
		if (reset = '1') then
			cnt <= (others => '0');
		elsif (clr = '1') then
			cnt <= (others => '0');
		elsif (add_cnt = '1') then
			cnt <= cnt + 1;
		end if;
				
		clr <= adc_en and cnt(9) and cnt(8)
		   and cnt(7) and cnt(6) and cnt(5) and cnt(4) 
			and cnt(3) and cnt(2) and cnt(1) and cnt(0);
		dclr <= clr;
		d2clr <= dclr;
		
		if (reset = '1') then
			drs_daq_a_reg(0) <= '0';
		elsif (d2clr = '1') then
			drs_daq_a_reg(0) <= '0';
		elsif (triged = '1') then 
			drs_daq_a_reg(0) <= '1';
		end if;

		if (reset = '1') then
			drs_cal_raddr_reg <= (others => '0');
		elsif (start_daq = '1') then
			drs_cal_raddr_reg <= (others => '0');
		elsif (add_cal_raddr = '1') then
			drs_cal_raddr_reg <= drs_cal_raddr_reg + 1;
		end if;

		add_cal_raddr <= drs_fifo_write_reg;

		if (reset = '1') then
			drs_fifo_waddr_reg <= (others => '0');
		elsif (start_daq = '1') then
			drs_fifo_waddr_reg <= (others => '0');
		elsif (drs_fifo_write_reg = '1') then
			drs_fifo_waddr_reg <= drs_fifo_waddr_reg + 1;
		end if;

		if (reset = '1') then
			rcen <= '0';
		elsif (rclr = '1') then
			rcen <= '0';
		elsif (clr = '1') then
			rcen <= '1';
		end if;
		
		if (reset = '1') then
			rcnt <= (others => '0');
		elsif (rclr = '1') then
			rcnt <= (others => '0');
		elsif (rcen = '1') then
			rcnt <= rcnt + 1;
		end if;

		rclr <= rcnt(5) and (not rcnt(4)) and rcnt(3) and rcnt(2) and rcnt(1) and (not rcnt(0));
		drs_read_done_reg <= rclr;

		pdrs_rsrload <= (not rcnt(5)) and (not rcnt(4)) and (not rcnt(3))
		            and rcnt(2) and (not rcnt(1)) and rcnt(0);
		drs_rsrload <= (others => pdrs_rsrload);

		rclk <= (rcnt(5) or rcnt(4) or rcnt(3)) and (not rcnt(1)) and rcnt(0);
		shift_sp <= rclk;
		
		drs_srout <= drs_srout_in;
		if (shift_sp = '1') then
			drs_stop_addr_reg <= drs_stop_addr_reg(8 downto 0) & drs_srout;
		end if;

	end if;
	end process;
	
	srl16e_pdrs_fifo_write0 : SRL16E
	generic map(INIT => x"0000")
	port map(
		D => dadd_cnt,
		A0 => '1',
		A1 => '1',
		A2 => '1',
		A3 => '1',
		CE => '1',
		CLK => clk,
		Q => pdrs_fifo_write(0)
	);

	srl16e_pdrs_fifo_write1 : SRL16E
	generic map(INIT => x"0000")
	port map(
		D => pdrs_fifo_write(0),
		A0 => '1',
		A1 => '1',
		A2 => '1',
		A3 => '1',
		CE => '1',
		CLK => clk,
		Q => pdrs_fifo_write(1)
	);

	srl16e_pdrs_fifo_write2 : SRL16E
	generic map(INIT => x"0000")
	port map(
		D => pdrs_fifo_write(1),
		A0 => '1',
		A1 => '1',
		A2 => '1',
		A3 => '1',
		CE => '1',
		CLK => clk,
		Q => pdrs_fifo_write(2)
	);

	srl16e_drs_fifo_write : SRL16E
	generic map(INIT => x"0000")
	port map(
		D => pdrs_fifo_write(2),
		A0 => '0',
		A1 => '0',
		A2 => '1',
		A3 => '1',
		CE => '1',
		CLK => clk,
		Q => drs_fifo_write_reg
	);

	srl16e_drs_read_end : SRL16E
	generic map(INIT => x"0000")
	port map(
		D => rclr,
		A0 => '1',
		A1 => '1',
		A2 => '0',
		A3 => '1',
		CE => '1',
		CLK => clk,
		Q => drs_read_end
	);

	drs_daq_a <= drs_daq_a_reg;
	drs_daq_srclk <= drs_daq_srclk_reg;
	drs_cal_raddr <= drs_cal_raddr_reg;
	drs_fifo_waddr <= drs_fifo_waddr_reg;
	drs_fifo_write <= drs_fifo_write_reg;
	drs_stop_addr <= drs_stop_addr_reg;
	drs_read_done <= drs_read_done_reg;

	myloop2 : for ch in 0 to 3 generate
		obuf_drs_rsrload : obuf port map(i => drs_rsrload(ch), o => p_drs_rsrload(ch));
	end generate;

end Behavioral;

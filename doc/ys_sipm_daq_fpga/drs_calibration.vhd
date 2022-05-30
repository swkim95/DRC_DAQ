library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity drs_calibration is port(
	signal adc_data : in adc_data_array;
	signal drs_cal_raddr : in std_logic_vector(9 downto 0);
	signal cal_wen : in std_logic;
	signal cal_sck : in std_logic;
	signal cal_sdi : in std_logic;
	signal drs_calib : in std_logic;
	signal clk : in std_logic;
	signal drs_fifo_wdata : out adc_data_array
); end drs_calibration;

architecture Behavioral of drs_calibration is

type cal_md_array is array(7 downto 0) of std_logic_vector(31 downto 0);
type cal_mwe_array is array(7 downto 0) of std_logic_vector(7 downto 0);
type lut_data_array is array(31 downto 0) of std_logic_vector(7 downto 0);
type cal_data_array is array(31 downto 0) of std_logic_vector(12 downto 0);

signal drs_fifo_wdata_reg : adc_data_array;
signal wa : std_logic_vector(17 downto 0);
signal wd : std_logic_vector(7 downto 0);
signal we : std_logic_vector(7 downto 0);
signal mwd : cal_md_array;
signal mrd : cal_md_array;
signal mwe : cal_mwe_array;
signal mwa : std_logic_vector(15 downto 0);
signal mra : std_logic_vector(15 downto 0);
signal lut_data : lut_data_array;
signal cal_data : cal_data_array;

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		wd <= (others => cal_sdi);

		if (cal_wen = '0') then
			wa <= (others => '0');
		elsif (cal_sck = '1') then
			wa <= wa + 1;
		end if;

		we(0) <= cal_sck and (not wa(17)) and (not wa(16)) and (not wa(15));
		we(1) <= cal_sck and (not wa(17)) and (not wa(16)) and wa(15);
		we(2) <= cal_sck and (not wa(17)) and wa(16) and (not wa(15));
		we(3) <= cal_sck and (not wa(17)) and wa(16) and wa(15);
		we(4) <= cal_sck and wa(17) and (not wa(16)) and (not wa(15));
		we(5) <= cal_sck and wa(17) and (not wa(16)) and wa(15);
		we(6) <= cal_sck and wa(17) and wa(16) and (not wa(15));
		we(7) <= cal_sck and wa(17) and wa(16) and wa(15);
	
		for i in 0 to 7 loop
			lut_data(4 * i) <= mrd(i)(7 downto 0);
			lut_data(4 * i + 1) <= mrd(i)(15 downto 8);
			lut_data(4 * i + 2) <= mrd(i)(23 downto 16);
			lut_data(4 * i + 3) <= mrd(i)(31 downto 24);
		end loop;
			
		for ch in 0 to 31 loop
			if (drs_calib = '1') then
				cal_data(ch) <= ('0' & adc_data(ch)) + "0000000000000";
			else
				cal_data(ch) <= ('0' & adc_data(ch)) + ("00000" & lut_data(ch));
			end if;

			for i in 0 to 11 loop
				drs_fifo_wdata_reg(ch)(i) <= cal_data(ch)(i) or cal_data(ch)(12);
			end loop;
		end loop;
	
	end if;
	end process;

	mwa <= '1' & wa(4 downto 3) & wa(14 downto 5) & wa(2 downto 0);
	mra <= '1' & drs_cal_raddr & "00000";
	
	myloop1 : for i in 0 to 7 generate
		mwd(i) <= "0000000000000000000000000000000" & wd(i);
		mwe(i) <= (others => we(i));
	
		ramb36e1_mrd : ramb36e1
		generic map (
			SIM_DEVICE => "7SERIES",
			READ_WIDTH_A => 36,
			READ_WIDTH_B => 1,
			WRITE_WIDTH_A => 36,
			WRITE_WIDTH_B => 1,
			DOA_REG => 0
		)
		port map (
			diadi => "11111111111111111111111111111111",
			dibdi => mwd(i),
			dipadip => "1111",
			dipbdip => "1111",
			addrardaddr => mra,
			addrbwraddr => mwa,
			wea => "0000",
			webwe => mwe(i),
			cascadeina => '0',
			cascadeinb => '0',
			clkardclk => clk,
			clkbwrclk => clk,
			enarden => '1',
			enbwren => '1',
			injectdbiterr => '0',
			injectsbiterr => '0',
			regcearegce => '1',
			regceb => '1',
			rstramarstram => '0',
			rstramb => '0',
			rstregarstreg => '0',
			rstregb => '0',
			doado => mrd(i),
			dobdo => open,
			dopadop => open,
			dopbdop => open,
			eccparity => open,
			rdaddrecc => open,
			cascadeouta => open,
			cascadeoutb => open,
			dbiterr => open,
			sbiterr => open
		);
	end generate;

	drs_fifo_wdata <= drs_fifo_wdata_reg;

end Behavioral;


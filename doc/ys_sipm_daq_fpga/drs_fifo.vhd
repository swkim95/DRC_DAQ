library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity drs_fifo is port(
	signal drs_fifo_wdata : in adc_data_array;
	signal drs_fifo_waddr : in std_logic_vector(9 downto 0);
	signal drs_fifo_raddr : in std_logic_vector(9 downto 0);
	signal drs_fifo_write : in std_logic;
	signal clk : in std_logic;
	signal drs_fifo_rdata : out adc_data_array
); end drs_fifo;

architecture Behavioral of drs_fifo is

type drs_fifo_md_array is array(11 downto 0) of std_logic_vector(31 downto 0);

signal drs_fifo_rdata_reg : adc_data_array;
signal mwa : std_logic_vector(15 downto 0);
signal mra : std_logic_vector(15 downto 0);
signal mwe : std_logic_vector(7 downto 0);
signal mwd : drs_fifo_md_array;
signal mrd : drs_fifo_md_array;

begin

	mwa <= '1' & drs_fifo_waddr & "00000";
	mra <= '1' & drs_fifo_raddr & "00000";
	mwe <= (others => drs_fifo_write);
	mwd(0) <= drs_fifo_wdata(2)(7 downto 0) & drs_fifo_wdata(1) & drs_fifo_wdata(0);
	mwd(1) <= drs_fifo_wdata(5)(3 downto 0) & drs_fifo_wdata(4) & drs_fifo_wdata(3) & drs_fifo_wdata(2)(11 downto 8);
	mwd(2) <= drs_fifo_wdata(7) & drs_fifo_wdata(6) & drs_fifo_wdata(5)(11 downto 4);
	mwd(3) <= drs_fifo_wdata(10)(7 downto 0) & drs_fifo_wdata(9) & drs_fifo_wdata(8);
	mwd(4) <= drs_fifo_wdata(13)(3 downto 0) & drs_fifo_wdata(12) & drs_fifo_wdata(11) & drs_fifo_wdata(10)(11 downto 8);
	mwd(5) <= drs_fifo_wdata(15) & drs_fifo_wdata(14) & drs_fifo_wdata(13)(11 downto 4);
	mwd(6) <= drs_fifo_wdata(18)(7 downto 0) & drs_fifo_wdata(17) & drs_fifo_wdata(16);
	mwd(7) <= drs_fifo_wdata(21)(3 downto 0) & drs_fifo_wdata(20) & drs_fifo_wdata(19) & drs_fifo_wdata(18)(11 downto 8);
	mwd(8) <= drs_fifo_wdata(23) & drs_fifo_wdata(22) & drs_fifo_wdata(21)(11 downto 4);
	mwd(9) <= drs_fifo_wdata(26)(7 downto 0) & drs_fifo_wdata(25) & drs_fifo_wdata(24);
	mwd(10) <= drs_fifo_wdata(29)(3 downto 0) & drs_fifo_wdata(28) & drs_fifo_wdata(27) & drs_fifo_wdata(26)(11 downto 8);
	mwd(11) <= drs_fifo_wdata(31) & drs_fifo_wdata(30) & drs_fifo_wdata(29)(11 downto 4);

	myloop1 : for i in 0 to 11 generate
		ramb36e1_dram_fifo : ramb36e1
		generic map (
			SIM_DEVICE => "7SERIES",
			READ_WIDTH_A => 36,
			READ_WIDTH_B => 36,
			WRITE_WIDTH_A => 36,
			WRITE_WIDTH_B => 36,
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
			webwe => mwe,
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

	process(clk) begin
	if (clk'event and clk = '1') then
	
		drs_fifo_rdata_reg(0) <= mrd(0)(11 downto 0);
		drs_fifo_rdata_reg(1) <= mrd(0)(23 downto 12);
		drs_fifo_rdata_reg(2) <= mrd(1)(3 downto 0) & mrd(0)(31 downto 24);
		drs_fifo_rdata_reg(3) <= mrd(1)(15 downto 4);
		drs_fifo_rdata_reg(4) <= mrd(1)(27 downto 16);
		drs_fifo_rdata_reg(5) <= mrd(2)(7 downto 0) & mrd(1)(31 downto 28);
		drs_fifo_rdata_reg(6) <= mrd(2)(19 downto 8);
		drs_fifo_rdata_reg(7) <= mrd(2)(31 downto 20);
		drs_fifo_rdata_reg(8) <= mrd(3)(11 downto 0);
		drs_fifo_rdata_reg(9) <= mrd(3)(23 downto 12);
		drs_fifo_rdata_reg(10) <= mrd(4)(3 downto 0) & mrd(3)(31 downto 24);
		drs_fifo_rdata_reg(11) <= mrd(4)(15 downto 4);
		drs_fifo_rdata_reg(12) <= mrd(4)(27 downto 16);
		drs_fifo_rdata_reg(13) <= mrd(5)(7 downto 0) & mrd(4)(31 downto 28);
		drs_fifo_rdata_reg(14) <= mrd(5)(19 downto 8);
		drs_fifo_rdata_reg(15) <= mrd(5)(31 downto 20);
		drs_fifo_rdata_reg(16) <= mrd(6)(11 downto 0);
		drs_fifo_rdata_reg(17) <= mrd(6)(23 downto 12);
		drs_fifo_rdata_reg(18) <= mrd(7)(3 downto 0) & mrd(6)(31 downto 24);
		drs_fifo_rdata_reg(19) <= mrd(7)(15 downto 4);
		drs_fifo_rdata_reg(20) <= mrd(7)(27 downto 16);
		drs_fifo_rdata_reg(21) <= mrd(8)(7 downto 0) & mrd(7)(31 downto 28);
		drs_fifo_rdata_reg(22) <= mrd(8)(19 downto 8);
		drs_fifo_rdata_reg(23) <= mrd(8)(31 downto 20);
		drs_fifo_rdata_reg(24) <= mrd(9)(11 downto 0);
		drs_fifo_rdata_reg(25) <= mrd(9)(23 downto 12);
		drs_fifo_rdata_reg(26) <= mrd(10)(3 downto 0) & mrd(9)(31 downto 24);
		drs_fifo_rdata_reg(27) <= mrd(10)(15 downto 4);
		drs_fifo_rdata_reg(28) <= mrd(10)(27 downto 16);
		drs_fifo_rdata_reg(29) <= mrd(11)(7 downto 0) & mrd(10)(31 downto 28);
		drs_fifo_rdata_reg(30) <= mrd(11)(19 downto 8);
		drs_fifo_rdata_reg(31) <= mrd(11)(31 downto 20);
		
	end if;
	end process;
	
	drs_fifo_rdata <= drs_fifo_rdata_reg;

end Behavioral;


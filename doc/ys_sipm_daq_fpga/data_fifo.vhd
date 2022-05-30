library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity data_fifo is port(
	signal data_fifo_wdata : in std_logic_vector(63 downto 0);
	signal data_fifo_waddr : in std_logic_vector(11 downto 0);
	signal data_fifo_raddr : in std_logic_vector(12 downto 0);
	signal data_fifo_write : in std_logic;
	signal clk_dram : in std_logic;
	signal clk : in std_logic;
	signal data_fifo_rdata : out std_logic_vector(31 downto 0)
); end data_fifo;

architecture Behavioral of data_fifo is

type data_fifo_wdat_array is array(7 downto 0) of std_logic_vector(7 downto 0);
type data_fifo_md_array is array(7 downto 0) of std_logic_vector(31 downto 0);

signal data_fifo_rdata_reg : std_logic_vector(31 downto 0);

signal wdat : data_fifo_wdat_array;
signal rdat : std_logic_vector(31 downto 0);
signal waddr : std_logic_vector(11 downto 0);
signal wrec : std_logic;
signal mwd : data_fifo_md_array;
signal mrd : data_fifo_md_array;
signal mwa : std_logic_vector(15 downto 0);
signal mra : std_logic_vector(15 downto 0);
signal mwe : std_logic_vector(7 downto 0);

begin

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then
	
		for i in 0 to 7 loop
			wdat(i) <= data_fifo_wdata(i * 4 + 35 downto i * 4 + 32) 
			         & data_fifo_wdata(i * 4 + 3 downto i * 4 );
		end loop;
		
		waddr <= data_fifo_waddr;
		wrec <= data_fifo_write;

	end if;
	end process;

	process(clk) begin
	if (clk'event and clk = '1') then
	
		data_fifo_rdata_reg <= rdat;

	end if;
	end process;

	mwa <= '0' & waddr & "000";
	mra <= '0' & data_fifo_raddr & "00";
	mwe <= (others => wrec);

	myloop1 : for i in 0 to 7 generate
		mwd(i) <= "000000000000000000000000" & wdat(i);
		
	ramb36e1_mrd : ramb36e1
	generic map (
		SIM_DEVICE => "7SERIES",
		READ_WIDTH_A => 4,
		READ_WIDTH_B => 9,
		WRITE_WIDTH_A => 4,
		WRITE_WIDTH_B => 9,
		DOA_REG => 1
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
			clkbwrclk => clk_dram,
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

	rdat <= mrd(7)(3 downto 0) & mrd(6)(3 downto 0)
			& mrd(5)(3 downto 0) & mrd(4)(3 downto 0)
			& mrd(3)(3 downto 0) & mrd(2)(3 downto 0)
			& mrd(1)(3 downto 0) & mrd(0)(3 downto 0);

	data_fifo_rdata <= data_fifo_rdata_reg;

end Behavioral;


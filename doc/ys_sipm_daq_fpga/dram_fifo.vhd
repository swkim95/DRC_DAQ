library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_fifo is port(
	signal dram_fifo_wdata : in std_logic_vector(511 downto 0);
	signal dram_fifo_waddr : in std_logic_vector(10 downto 0);
	signal dram_fifo_raddr : in std_logic_vector(13 downto 0);
	signal dram_fifo_write : in std_logic;
	signal clk : in std_logic;
	signal clk_dram : in std_logic;
	signal dram_fifo_rdata : out std_logic_vector(63 downto 0)
); end dram_fifo;

architecture Behavioral of dram_fifo is

type dram_fifo_md_array is array(31 downto 0) of std_logic_vector(31 downto 0);

signal mwd : dram_fifo_md_array;
signal mrd : dram_fifo_md_array;
signal mwa : std_logic_vector(15 downto 0);
signal mra : std_logic_vector(15 downto 0);
signal mwe : std_logic_vector(7 downto 0);
signal idram_fifo_rdata : std_logic_vector(63 downto 0);
signal dram_fifo_rdata_reg : std_logic_vector(63 downto 0);

begin

	mwa <= '1' & dram_fifo_waddr & "0000";
	mra <= '1' & dram_fifo_raddr & '0';
	mwe <= (others => dram_fifo_write);

	myloop1 : for i in 0 to 31 generate
		mwd(i) <= "0000000000000000" 
		        & dram_fifo_wdata(2 * i + 449 downto 2 * i + 448)
		        & dram_fifo_wdata(2 * i + 385 downto 2 * i + 384)
		        & dram_fifo_wdata(2 * i + 321 downto 2 * i + 320)
		        & dram_fifo_wdata(2 * i + 257 downto 2 * i + 256)
		        & dram_fifo_wdata(2 * i + 193 downto 2 * i + 192)
		        & dram_fifo_wdata(2 * i + 129 downto 2 * i + 128)
		        & dram_fifo_wdata(2 * i + 65 downto 2 * i + 64)
		        & dram_fifo_wdata(2 * i + 1 downto 2 * i);
	
		ramb36e1_dram_fifo : ramb36e1
		generic map (
			SIM_DEVICE => "7SERIES",
			READ_WIDTH_A => 2,
			READ_WIDTH_B => 18,
			WRITE_WIDTH_A => 2,
			WRITE_WIDTH_B => 18,
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
			clkardclk => clk_dram,
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
	
	idram_fifo_rdata <= mrd(31)(1 downto 0) & mrd(30)(1 downto 0) 
							& mrd(29)(1 downto 0) & mrd(28)(1 downto 0)
							& mrd(27)(1 downto 0) & mrd(26)(1 downto 0)
							& mrd(25)(1 downto 0) & mrd(24)(1 downto 0)
							& mrd(23)(1 downto 0) & mrd(22)(1 downto 0)
							& mrd(21)(1 downto 0) & mrd(20)(1 downto 0)
							& mrd(19)(1 downto 0) & mrd(18)(1 downto 0)
							& mrd(17)(1 downto 0) & mrd(16)(1 downto 0)
							& mrd(15)(1 downto 0) & mrd(14)(1 downto 0)
							& mrd(13)(1 downto 0) & mrd(12)(1 downto 0)
							& mrd(11)(1 downto 0) & mrd(10)(1 downto 0)
							& mrd(9)(1 downto 0) & mrd(8)(1 downto 0)
							& mrd(7)(1 downto 0) & mrd(6)(1 downto 0)
							& mrd(5)(1 downto 0) & mrd(4)(1 downto 0)
							& mrd(3)(1 downto 0) & mrd(2)(1 downto 0) 
							& mrd(1)(1 downto 0) & mrd(0)(1 downto 0);

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then
		
		dram_fifo_rdata_reg <= idram_fifo_rdata;
		
	end if;
	end process;
	
	dram_fifo_rdata <= dram_fifo_rdata_reg;

end Behavioral;


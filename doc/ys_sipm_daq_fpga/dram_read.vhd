library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_read is port(
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
); end dram_read;

architecture Behavioral of dram_read is

signal dram_test_clr_reg : std_logic;
signal dram_test_and_reg : std_logic;
signal data_fifo_waddr_reg : std_logic_vector(11 downto 0);
signal dram_ra_reg : std_logic_vector(13 downto 0);
signal dram_rba_reg : std_logic_vector(2 downto 0);
signal dram_rcs_reg : std_logic;
signal dram_rras_reg : std_logic;
signal dram_rcas_reg : std_logic;
signal dram_rmwe_reg : std_logic;
signal data_fifo_write_reg : std_logic;
signal add_data_fifo_cnt_reg : std_logic;
signal sub_dram_cnt_reg : std_logic;

signal scen : std_logic;
signal cen : std_logic;
signal cnt : std_logic_vector(7 downto 0);
signal clr : std_logic;
signal dclr : std_logic;
signal padd_dram_rpage : std_logic;
signal pdata_fifo_write : std_logic;
signal pdata_fifo_waddr : std_logic_vector(7 downto 0);
signal pdram_test_clr : std_logic;

attribute keep:string;
attribute keep of data_fifo_waddr_reg :signal is "true";
attribute keep of data_fifo_write_reg :signal is "true";

begin

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then
	
		sub_dram_cnt_reg <= read_dram and (not dram_test_on);
		add_data_fifo_cnt_reg <= read_dram and (not dram_test_on);
		scen <= read_dram;
	
		if (clr = '1') then
			cen <= '0';
		elsif (scen = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(7) and cnt(6) and cnt(5) and cnt(4) and cnt(3) 
		   and cnt(2) and cnt(1) and (not cnt(0));
			
		dram_rcs_reg <= read_dram or cnt(0) or dclr;
		dram_rras_reg <= read_dram or dclr;
		dram_rcas_reg <= cnt(0);
		dram_rmwe_reg <= dclr;

		for i in 0 to 2 loop
			dram_ra_reg(i) <= read_dram and dram_rpage(i);
		end loop;

		for i in 3 to 9 loop
			dram_ra_reg(i) <= (read_dram and dram_rpage(i)) or (cnt(0) and cnt(i - 2));
		end loop;

		dram_ra_reg(10) <= dclr or (read_dram and dram_rpage(10));

		for i in 11 to 13 loop
			dram_ra_reg(i) <= read_dram and dram_rpage(i);
		end loop;
		
		for i in 0 to 2 loop
			dram_rba_reg(i) <= dram_rpage(i + 14) and (read_dram or cnt(0));
		end loop;

		data_fifo_waddr_reg(8) <= dram_rpage(0);
		data_fifo_waddr_reg(9) <= dram_rpage(1);
		data_fifo_waddr_reg(10) <= dram_rpage(2);
		data_fifo_waddr_reg(11) <= dram_rpage(3);
		
		padd_dram_rpage <= dclr and (not dram_test_on);
		
		pdata_fifo_write <= cen and (not dram_test_on);
		
		for i in 0 to 7 loop
			pdata_fifo_waddr(i) <= cnt(i) and (not dram_test_on);
		end loop;

		pdram_test_clr <= scen and dram_test_on;

		if (clr = '1') then 
			dram_test_and_reg <= '0';
		elsif (dram_test_clr_reg = '1') then
			dram_test_and_reg <= dram_test_on;
		end if;

	end if;
	end process;

	srl16e_dclr : srl16e
	generic map(init => x"0000")
	port map(
		d => clr,
		a0 => '0',
		a1 => '1',
		a2 => '1',
		a3 => '0',
		ce => '1',
		clk => clk_dram,
		q => dclr
	);

	srl16e_add_dram_rpage : srl16e
	generic map(init => x"0000")
	port map(
		d => padd_dram_rpage,
		a0 => '1',
		a1 => '0',
		a2 => '0',
		a3 => '0',
		ce => '1',
		clk => clk_dram,
		q => add_dram_rpage
	);

	srl16e_data_fifo_write : srl16e
	generic map(init => x"0000")
	port map(
		d => pdata_fifo_write,
		a0 => '1',
		a1 => '0',
		a2 => '0',
		a3 => '1',
		ce => '1',
		clk => clk_dram,
		q => data_fifo_write_reg
	);

	myloop1 : for i in 0 to 7 generate
		srl16e_data_fifo_waddr : srl16e
		generic map(init => x"0000")
		port map(
			d => pdata_fifo_waddr(i),
			a0 => '1',
			a1 => '0',
			a2 => '0',
			a3 => '1',
			ce => '1',
			clk => clk_dram,
			q => data_fifo_waddr_reg(i)
		);
	end generate;

	srl16e_dram_test_clr : srl16e
	generic map(init => x"0000")
	port map(
		d => pdram_test_clr,
		a0 => '1',
		a1 => '0',
		a2 => '1',
		a3 => '1',
		ce => '1',
		clk => clk_dram,
		q => dram_test_clr_reg
	);

	dram_test_clr <= dram_test_clr_reg;
	dram_test_and <= dram_test_and_reg;
	data_fifo_waddr <= data_fifo_waddr_reg;
	dram_ra <= dram_ra_reg;
	dram_rba <= dram_rba_reg;
	dram_rcs <= dram_rcs_reg;
	dram_rras <= dram_rras_reg;
	dram_rcas <= dram_rcas_reg;
	dram_rmwe <= dram_rmwe_reg;
	data_fifo_write <= data_fifo_write_reg;
	add_data_fifo_cnt <= add_data_fifo_cnt_reg;
	sub_dram_cnt <= sub_dram_cnt_reg;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_write is port(
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
); end dram_write;

architecture Behavioral of dram_write is

signal dram_fifo_raddr_reg : std_logic_vector(13 downto 0);
signal dram_wa_reg : std_logic_vector(13 downto 0);
signal dram_wba_reg : std_logic_vector(2 downto 0);
signal dram_wcs_reg : std_logic;
signal dram_wras_reg : std_logic;
signal dram_wcas_reg : std_logic;
signal dram_wmwe_reg : std_logic;
signal p3emd_reg : std_logic;
signal p5omds_reg : std_logic;
signal p5emds_reg : std_logic;
signal add_dram_wpage_reg : std_logic;
signal sub_dram_fifo_cnt_reg : std_logic;
signal add_dram_cnt_reg : std_logic;

signal scen : std_logic;
signal cen : std_logic;
signal dcen : std_logic;
signal d2cen : std_logic;
signal cnt : std_logic_vector(7 downto 0) := (others => '0');
signal clr : std_logic;
signal dclr : std_logic;
signal addbufcnt : std_logic;
signal bufcnt : std_logic_vector(5 downto 0);

attribute keep:string;
attribute keep of dram_fifo_raddr_reg :signal is "true";

begin

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then
	
		add_dram_cnt_reg <= write_dram and (not dram_test_on);
		sub_dram_fifo_cnt_reg <= write_dram and (not dram_test_on);
		scen <= write_dram;
	
		if (clr = '1') then
			cen <= '0';
		elsif (scen = '1') then
			cen <= '1';
		end if;
		dcen <= cen;
		d2cen <= dcen;
		p5emds_reg <= dcen or d2cen;
		p5omds_reg <= d2cen;
		p3emd_reg <= p5omds_reg;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(7) and cnt(6) and cnt(5) and cnt(4) and cnt(3) 
		   and cnt(2) and cnt(1) and (not cnt(0));

		dram_wcs_reg <= write_dram or cnt(0) or dclr;
		dram_wras_reg <= write_dram or dclr;
		dram_wcas_reg <= cnt(0);
		dram_wmwe_reg <= cnt(0) or dclr;
		
		addbufcnt <= clr and (not dram_test_on);
		
		if (reset_dram = '1') then
			bufcnt <= (others => '0');
		elsif (addbufcnt = '1') then
			bufcnt <= bufcnt + 1;
		end if;
		
		for i in 0 to 7 loop
			dram_fifo_raddr_reg(i) <= cnt(i) and (not dram_test_on);
		end loop;

		for i in 0 to 5 loop
			dram_fifo_raddr_reg(i + 8) <= bufcnt(i);
		end loop;
		
		for i in 0 to 2 loop
			dram_wa_reg(i) <= write_dram and dram_wpage(i);
		end loop;

		for i in 3 to 9 loop
			dram_wa_reg(i) <= (write_dram and dram_wpage(i)) or (cnt(0) and cnt(i - 2));
		end loop;

		dram_wa_reg(10) <= dclr or (write_dram and dram_wpage(10));

		for i in 11 to 13 loop
			dram_wa_reg(i) <= write_dram and dram_wpage(i);
		end loop;
		
		for i in 0 to 2 loop
			dram_wba_reg(i) <= dram_wpage(i + 14) and (write_dram or cnt(0));
		end loop;
		
		add_dram_wpage_reg <= dclr and (not dram_test_on);

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

	dram_fifo_raddr <= dram_fifo_raddr_reg;
	dram_wa <= dram_wa_reg;
	dram_wba <= dram_wba_reg;
	dram_wcs <= dram_wcs_reg;
	dram_wras <= dram_wras_reg;
	dram_wcas <= dram_wcas_reg;
	dram_wmwe <= dram_wmwe_reg;
	p3emd <= p3emd_reg;
	p5omds <= p5omds_reg;
	p5emds <= p5emds_reg;
	add_dram_wpage <= add_dram_wpage_reg;
	sub_dram_fifo_cnt <= sub_dram_fifo_cnt_reg;
	add_dram_cnt <= add_dram_cnt_reg;

end Behavioral;


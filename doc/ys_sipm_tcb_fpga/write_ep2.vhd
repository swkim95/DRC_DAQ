library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity write_ep2 is port(
	signal p_usb_d : inout std_logic_vector(31 downto 0);
	signal usb_rdata : in std_logic_vector(31 downto 0);
	signal usb_raddr : in std_logic_vector(5 downto 0);
	signal usb_rucnt : in std_logic_vector(29 downto 0);
	signal usb_sucom : in std_logic;
	signal usb_sudmp : in std_logic;
	signal clk : in std_logic;
	signal usb_icd : out std_logic_vector(31 downto 0);
	signal usb_ra : out std_logic_vector(5 downto 0);
	signal usb_bufn : out std_logic;
	signal usb_eudmp : out std_logic;
	signal usb_rend : out std_logic;
	signal p_usb_wr : out std_logic;
	signal p_usb_pktend : out std_logic
); end write_ep2;

architecture Behavioral of write_ep2 is

signal usb_ecd : std_logic_vector(31 downto 0);
signal usb_ra_reg : std_logic_vector(5 downto 0);
signal usb_bufn_reg : std_logic;
signal usb_eudmp_reg : std_logic;
signal usb_rend_reg : std_logic;
signal usb_wr : std_logic;
signal usb_pktend : std_logic;

signal addra : std_logic;
signal racnt : std_logic_vector(29 downto 0);
signal saddr : std_logic_vector(5 downto 0);
signal sracnt : std_logic_vector(5 downto 0);
signal rdtc : std_logic;
signal enpke : std_logic;
signal dusb_sudmp : std_logic;
signal cen : std_logic := '0';
signal ncen : std_logic;
signal cnt : std_logic_vector(11 downto 0);
signal tcnt : std_logic;
signal pusb_ecd : std_logic;
signal drdtc : std_logic;
signal raclr : std_logic;
signal dtcnt : std_logic;
signal clr : std_logic;
signal pusb_pktend : std_logic;
signal dpusb_pktend : std_logic;

attribute iob : string;
attribute iob of usb_ecd : signal is "true";
attribute iob of usb_wr : signal is "true";
attribute iob of usb_pktend : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		if (usb_sucom = '1') then
			racnt <= (others => '0');
		elsif (addra = '1') then
			racnt <= racnt + 1;
		end if;

		saddr <= usb_raddr + sracnt;

		if (racnt >= usb_rucnt) then
			rdtc <= '1';
		else
			rdtc <= '0';
		end if;
		
		enpke <= usb_rucnt(0) or usb_rucnt(1) or usb_rucnt(2) or usb_rucnt(3)
		      or usb_rucnt(4) or usb_rucnt(5) or usb_rucnt(6) or usb_rucnt(7)
		      or usb_rucnt(8) or usb_rucnt(9) or usb_rucnt(10) or usb_rucnt(11);
				
		usb_bufn_reg <= racnt(12);
		
		for i in 0 to 5 loop
			usb_ra_reg(i) <= saddr(i);
		end loop;
		
		if (raclr = '1') then
			addra <= '0';
		elsif (usb_sudmp = '1') then
			addra <= '1';
		end if;
		
		if (clr = '1') then
			cen <= '0';
		elsif (dusb_sudmp = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		tcnt <= cnt(11) and cnt(10) and cnt(9) and cnt(8) and cnt(7)
		    and cnt(6) and cnt(5) and cnt(4) and cnt(3) 
			 and (not cnt(2)) and cnt(1) and (not cnt(0));
		
		usb_ecd <= (others => pusb_ecd);
		usb_wr <= pusb_ecd;
		
		drdtc <= rdtc;
		raclr <= tcnt or (rdtc and (not drdtc));
		clr <= dtcnt or (rdtc and (not drdtc));
		usb_rend_reg <= rdtc and (not drdtc);
		
		usb_eudmp_reg <= clr;
		
		pusb_pktend <= enpke and rdtc and (not drdtc);
		usb_pktend <= not dpusb_pktend;
	
	end if;
	end process;

	sracnt <= racnt(5 downto 0);

	srl16e_dusb_sudmp : SRL16E
	generic map(INIT => x"0000")
	port map(
		D => usb_sudmp,
		A0 => '0',
		A1 => '1',
		A2 => '0',
		A3 => '0',
		CE => '1',
		CLK => clk,
		Q => dusb_sudmp
	);

	ncen <= not cen;

	srl16e_pusb_ecd : SRL16E
	generic map(INIT => x"FFFF")
	port map(
		D => ncen,
		A0 => '0',
		A1 => '1',
		A2 => '0',
		A3 => '0',
		CE => '1',
		CLK => clk,
		Q => pusb_ecd
	);

	srl16e_dtcnt : SRL16E
	generic map(INIT => x"0000")
	port map(
		D => tcnt,
		A0 => '0',
		A1 => '1',
		A2 => '0',
		A3 => '0',
		CE => '1',
		CLK => clk,
		Q => dtcnt
	);

	srl16e_dpusb_pktend : SRL16E
	generic map(INIT => x"0000")
	port map(
		D => pusb_pktend,
		A0 => '0',
		A1 => '1',
		A2 => '0',
		A3 => '0',
		CE => '1',
		CLK => clk,
		Q => dpusb_pktend
	);

	usb_ra <= usb_ra_reg;
	usb_bufn <= usb_bufn_reg;
	usb_eudmp <= usb_eudmp_reg;
	usb_rend <= usb_rend_reg;

	myloop1 : for i in 0 to 31 generate
		ibuf_usb_d : ibuf port map(i => p_usb_d(i), o => usb_icd(i));
		obuft_usb_d : obuft port map(i => usb_rdata(i), t => usb_ecd(i), o => p_usb_d(i));
	end generate;
	
	obuf_usb_wr : obuf port map(i => usb_wr, o => p_usb_wr);
	obuf_usb_pktend : obuf port map(i => usb_pktend, o => p_usb_pktend);
	
end Behavioral;

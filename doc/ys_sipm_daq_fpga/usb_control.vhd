library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity usb_control is port(
	signal p_usb_rflag : in std_logic_vector(1 downto 0);
	signal p_usb_wflag : in std_logic;
	signal p_usb_on : in std_logic;
	signal usb_rmux : in std_logic;
	signal data_fifo_empty : in std_logic;
	signal usb_bufn : in std_logic;
	signal usb_clrbn : in std_logic;
	signal usb_eudmp : in std_logic;
	signal usb_rend : in std_logic;
	signal clk : in std_logic;
	signal usb_sucom : out std_logic;
	signal usb_sudmp : out std_logic;
	signal usb_reset : out std_logic;
	signal p_usb_a : out std_logic_vector(1 downto 0)
); end usb_control;

architecture Behavioral of usb_control is

signal iusb_rflag : std_logic_vector(1 downto 0);
signal iusb_wflag : std_logic;
signal iusb_on : std_logic;
signal usb_a : std_logic_vector(1 downto 0);
signal usb_sucom_reg : std_logic;
signal usb_sudmp_reg : std_logic;
signal usb_reset_reg : std_logic;

signal usb_rflag : std_logic_vector(1 downto 0);
signal usb_wflag : std_logic;
signal usb_on : std_logic;

signal usb_rdon : std_logic;
signal usbok : std_logic;
signal cen : std_logic;
signal cblk : std_logic :='1';
signal cnt : std_logic_vector(4 downto 0);
signal pusb_a : std_logic_vector(1 downto 0);
signal ucen : std_logic;
signal uden : std_logic;
signal mlrfg : std_logic;

attribute iob : string;
attribute iob of usb_rflag : signal is "true";
attribute iob of usb_wflag : signal is "true";
attribute iob of usb_on : signal is "true";
attribute iob of usb_a : signal is "true";

begin

	ibuf_usb_rflag0 : ibuf port map(i => p_usb_rflag(0), o => iusb_rflag(0));
	ibuf_usb_rflag1 : ibuf port map(i => p_usb_rflag(1), o => iusb_rflag(1));
	ibuf_usb_wflag : ibuf port map(i => p_usb_wflag, o => iusb_wflag);
	ibuf_usb_on : ibuf port map(i => p_usb_on, o => iusb_on);

	process(clk) begin
	if (clk'event and clk = '1') then
	
		usb_on <= iusb_on;
		usbok <= usb_on;
		usb_reset_reg <= not usb_on;
		
		usb_wflag <= iusb_wflag;
		usb_rflag <= iusb_rflag;
		
		if (usb_reset_reg = '1') then
			usb_rdon <= '0';
		elsif (usb_rend = '1') then
			usb_rdon <= '0';
		elsif (usb_clrbn = '1') then
			usb_rdon <= '1';
		end if;
		
		cen <= usbok and (not cblk);
		
		if (usb_reset_reg = '1') then
			cblk <= '0';
		elsif (usb_eudmp = '1') then
			cblk <= '0';
		elsif (usb_sudmp_reg = '1') then
			cblk <= '1';
		end if;

		if (usb_reset_reg = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		pusb_a(0) <= not(cnt(4) and (not usb_bufn));
		pusb_a(1) <= not cnt(4);
		usb_a <= pusb_a;
		
		ucen <= (not cnt(4)) and (not cnt(3)) and cnt(2) and cnt(1) and (not cnt(0));
		uden <= cnt(4) and (not cnt(3)) and cnt(2) and cnt(1) and cnt(0);
		
		usb_sucom_reg <= ucen and usb_wflag;
		
		mlrfg <= (usb_rflag(0) and (not usb_bufn)) or (usb_rflag(1) and usb_bufn);
		usb_sudmp_reg <= usb_rdon and uden and mlrfg 
		         and ((usb_rmux and (not data_fifo_empty)) or (not usb_rmux));
		
	end if;
	end process;

	usb_sucom <= usb_sucom_reg;
	usb_sudmp <= usb_sudmp_reg;
	usb_reset <= usb_reset_reg;

	obuf_usb_a0 : obuf port map(i => usb_a(0), o => p_usb_a(0));
	obuf_usb_a1 : obuf port map(i => usb_a(1), o => p_usb_a(1));

end Behavioral;



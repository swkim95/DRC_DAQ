library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity read_ep6 is port(
	signal usb_icd : in std_logic_vector(31 downto 0);
	signal usb_sucom : in std_logic;
	signal clk : in std_logic;
	signal usb_mid : out std_logic_vector(7 downto 0);
	signal usb_addr : out std_logic_vector(13 downto 0);
	signal usb_wdata : out std_logic_vector(31 downto 0);
	signal usb_write : out std_logic;
	signal usb_read : out std_logic;
	signal usb_raddr : out std_logic_vector(5 downto 0);
	signal usb_rucnt : out std_logic_vector(29 downto 0);
	signal usb_clrbn : out std_logic;
	signal mod_wait : out std_logic;
	signal p_usb_cs : out std_logic;
	signal p_usb_oe : out std_logic;
	signal p_usb_rd : out std_logic
); end read_ep6;

architecture Behavioral of read_ep6 is

signal usb_mid_reg : std_logic_vector(7 downto 0);
signal usb_addr_reg : std_logic_vector(13 downto 0);
signal usb_wdata_reg : std_logic_vector(31 downto 0);
signal usb_write_reg : std_logic;
signal usb_rucnt_reg : std_logic_vector(29 downto 0);
signal usb_clrbn_reg : std_logic;
signal mod_wait_reg : std_logic;
signal usb_oe : std_logic;
signal usb_rd : std_logic;

signal dusb_sucom : std_logic;
signal d2usb_sucom : std_logic;
signal pusb_rd : std_logic;
signal en_data : std_logic;
signal pusb_oe : std_logic := '1';
signal en_addr : std_logic;
signal en_mid : std_logic;
signal lcd : std_logic_vector(31 downto 0);
signal usb_dir : std_logic;
signal scen : std_logic;
signal cnt : std_logic_vector(7 downto 0);
signal clr : std_logic;

attribute iob : string;
attribute iob of lcd : signal is "true";
attribute iob of usb_rd : signal is "true";
attribute iob of usb_oe : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		dusb_sucom <= usb_sucom;
		d2usb_sucom <= dusb_sucom;
		pusb_rd <= not(usb_sucom or dusb_sucom or d2usb_sucom);
		usb_rd <= pusb_rd;

		if (en_data = '1') then
			pusb_oe <= '1';
		elsif (usb_sucom = '1') then
			pusb_oe <= '0';
		end if;
		usb_oe <= pusb_oe;
		
		en_addr <= en_data;
		en_mid <= en_addr;
		
		lcd <= usb_icd;
		
		if (en_data = '1') then
			usb_wdata_reg <= lcd(31 downto 0);
			usb_rucnt_reg <= lcd(29 downto 0);
		end if;
		
		if (en_addr = '1') then
			usb_addr_reg <= lcd(13 downto 0);
			usb_dir <= lcd(31);
		end if;
		
		if (en_mid = '1') then
			usb_mid_reg <= lcd(7 downto 0);
		end if;

		scen <= en_mid and (lcd(0) or lcd(1) or lcd(2) or lcd(3) or lcd(4) or lcd(5) or lcd(6) or lcd(7));

		if (clr = '1') then
			mod_wait_reg <= '0';
		elsif (scen = '1') then
			mod_wait_reg <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (mod_wait_reg = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(7) and cnt(6) and cnt(5) and cnt(4)
		   and cnt(3) and cnt(2) and cnt(1) and (not cnt(0));

		usb_write_reg <= en_mid and (not usb_dir);
		usb_clrbn_reg <= en_mid and usb_dir;
		
	end if;
	end process;
	
	srl16e_en_data : srl16e
	generic map(
		init => "0000"
	)
	port map(
		d => dusb_sucom,
		a0 => '1',
		a1 => '1',
		a2 => '0',
		a3 => '0',
		ce => '1',
		clk => clk,
		q => en_data
	);
	
	usb_mid <= usb_mid_reg;
	usb_addr <= usb_addr_reg;
	usb_wdata <= usb_wdata_reg;
	usb_write <= usb_write_reg;
	usb_read <= usb_clrbn_reg;
	usb_raddr <= usb_addr_reg(5 downto 0);
	usb_rucnt <= usb_rucnt_reg;
	usb_clrbn <= usb_clrbn_reg;
	mod_wait <= mod_wait_reg;

	obuf_usb_cs : obuf port map(i => '0', o => p_usb_cs);
	obuf_usb_rd : obuf port map(i => usb_rd, o => p_usb_rd);
	obuf_usb_oe : obuf port map(i => usb_oe, o => p_usb_oe);

end Behavioral;

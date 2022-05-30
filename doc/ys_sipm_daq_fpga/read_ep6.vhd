library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity read_ep6 is port(
	signal usb_icd : in std_logic_vector(31 downto 0);
	signal usb_sucom : in std_logic;
	signal clk : in std_logic;
	signal usb_addr : out std_logic_vector(12 downto 0);
	signal usb_rucnt : out std_logic_vector(29 downto 0);
	signal latch_data_size : out std_logic;
	signal usb_clrbn : out std_logic;
	signal p_usb_cs : out std_logic;
	signal p_usb_oe : out std_logic;
	signal p_usb_rd : out std_logic
); end read_ep6;

architecture Behavioral of read_ep6 is

signal usb_addr_reg : std_logic_vector(12 downto 0);
signal usb_rucnt_reg : std_logic_vector(29 downto 0);
signal latch_data_size_reg : std_logic;
signal usb_clrbn_reg : std_logic;
signal usb_rd : std_logic;
signal usb_oe : std_logic;

signal lcd : std_logic_vector(31 downto 0);
signal dusb_sucom : std_logic;
signal pusb_rd : std_logic := '1';
signal endat : std_logic;
signal pusb_oe : std_logic := '1';
signal enaddr : std_logic;

attribute iob : string;
attribute iob of lcd : signal is "true";
attribute iob of usb_rd : signal is "true";
attribute iob of usb_oe : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		dusb_sucom <= usb_sucom;
		pusb_rd <= not(usb_sucom or dusb_sucom);
		usb_rd <= pusb_rd;
		
		if (endat = '1') then
			pusb_oe <= '1';
		elsif (usb_sucom = '1') then
			pusb_oe <= '0';
		end if;
		usb_oe <= pusb_oe;

		enaddr <= endat;
		
		lcd <= usb_icd;

		if (endat = '1') then
			usb_rucnt_reg <= lcd(29 downto 0);
		end if;

		if (enaddr = '1') then
			for i in 0 to 11 loop
				usb_addr_reg(i) <= lcd(i);
			end loop;

			usb_addr_reg(12) <= lcd(30);
		end if;

		usb_clrbn_reg <= enaddr and lcd(31);

		latch_data_size_reg <= usb_clrbn_reg and (not usb_addr_reg(12));

	end if;
	end process;
	
	srl16e_endat : SRL16E
	generic map(INIT => "0000")
	port map(
		D => dusb_sucom,
		A0 => '1',
		A1 => '1',
		A2 => '0',
		A3 => '0',
		CE => '1',
		CLK => clk,
		Q => endat
	);

	usb_addr <= usb_addr_reg;
	usb_rucnt <= usb_rucnt_reg;
	latch_data_size <= latch_data_size_reg;
	usb_clrbn <= usb_clrbn_reg;

	obuf_usb_cs : obuf port map(i => '0', o => p_usb_cs);
	obuf_usb_rd : obuf port map(i => usb_rd, o => p_usb_rd);
	obuf_usb_oe : obuf port map(i => usb_oe, o => p_usb_oe);

end Behavioral;

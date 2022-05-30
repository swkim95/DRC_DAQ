library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity led_driver is port(
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(13 downto 0);
	signal triged : in std_logic_vector(39 downto 0);
	signal response : in std_logic_vector(39 downto 0);
	signal linked : in std_logic_vector(39 downto 0);
	signal clk : in std_logic;
	signal p_led_cs : out std_logic;
	signal p_led_sck : out std_logic;
	signal p_led_sdi : out std_logic
); end led_driver;

architecture Behavioral of led_driver is

component led_data port(
	signal triged : in std_logic;
	signal response : in std_logic;
	signal sled : in std_logic;
	signal clk : in std_logic;
	signal enled : out std_logic
); end component;
	
signal led_cs : std_logic;
signal led_sck : std_logic;
signal led_sdi : std_logic;

attribute iob : string;
attribute iob of led_cs : signal is "true";
attribute iob of led_sck : signal is "true";
attribute iob of led_sdi : signal is "true";

signal sled : std_logic;
signal enled : std_logic_vector(39 downto 0);
signal sdat : std_logic_vector(80 downto 0);
signal cen : std_logic;
signal cnt : std_logic_vector(10 downto 0);
signal clr : std_logic;
signal shift : std_logic;
signal sck : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		sled <= tcb_ctime(13) and tcb_ctime(12) and tcb_ctime(11) and tcb_ctime(10)
		    and tcb_ctime(9) and tcb_ctime(8) and tcb_ctime(7) and tcb_ctime(6)
		    and tcb_ctime(5) and tcb_ctime(4) and tcb_ctime(3) and tcb_ctime(2)
		    and tcb_ctime(1) and tcb_ctime(0) and tcb_ftime(6) and tcb_ftime(5)
			 and tcb_ftime(4) and tcb_ftime(3) and tcb_ftime(2) 
			 and (not tcb_ftime(1)) and (not tcb_ftime(0));
			 
		if (sled = '1') then
			sdat <= enled & '0' & linked;
		elsif (shift = '1') then
			sdat <= '0' & sdat(80 downto 1);
		end if;

		if (clr = '1') then
			cen <= '0';
		elsif (sled = '1') then
			cen <= '1';
		end if;

		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;

		clr <= cnt(10) and (not cnt(9)) and cnt(8)
		  and (not cnt(7)) and (not cnt(6)) and (not cnt(5)) and cnt(4)
		  and cnt(3) and cnt(2) and cnt(1) and cnt(0);
		  
		shift <= cnt(3) and cnt(2) and cnt(1) and cnt(0);
		sck <= cnt(3);

		led_cs <= not cen;
		led_sck <= sck;
		led_sdi <= sdat(0);
	
	end if;
	end process;

	myloop1 : for ch in 0 to 39 generate
		u1 : led_data port map(
			triged => triged(ch), 
			response => response(ch), 
			sled => sled, 
			clk => clk, 
			enled => enled(ch)
		);
	end generate;

	obuf_led_cs : obuf port map(i => led_cs, o => p_led_cs);
	obuf_led_sck : obuf port map(i => led_sck, o => p_led_sck);
	obuf_led_sdi : obuf port map(i => led_sdi, o => p_led_sdi);

end Behavioral;

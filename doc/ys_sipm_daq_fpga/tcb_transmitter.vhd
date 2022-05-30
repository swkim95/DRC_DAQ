library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity tcb_transmitter is port(
	signal mod_mid : in std_logic_vector(7 downto 0);
	signal mod_type : in std_logic;
	signal mod_din : in std_logic_vector(31 downto 0);
	signal fcnt : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal parout : out std_logic_vector(9 downto 0)
); end tcb_transmitter;

architecture Behavioral of tcb_transmitter is

component encoder_8b10b port(
	signal sdout : in std_logic_vector(7 downto 0);
	signal charisk : in std_logic;
	signal disparity : in std_logic;
	signal clk : in std_logic;
	signal parout : out std_logic_vector(9 downto 0);
	signal dispp : out std_logic;
	signal dispm : out std_logic
); end component;

signal clr : std_logic;
signal iaddmux : std_logic;
signal addmux : std_logic;
signal daddmux : std_logic;
signal muxcnt : std_logic_vector(3 downto 0);
signal charisk : std_logic;
signal dispp : std_logic := '0';
signal dispm : std_logic := '0';
signal disparity : std_logic := '0';
signal isdout : std_logic_vector(7 downto 0);
signal sdout : std_logic_vector(7 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		clr <= fcnt(6) and (not fcnt(5)) and fcnt(4) and fcnt(3) 
		   and (not fcnt(2)) and (not fcnt(1)) and (not fcnt(0));

		addmux <= iaddmux and (not fcnt(0)); 
		daddmux <= addmux;
				 
		if (clr = '1') then
			muxcnt <= (others => '0');
		elsif (addmux = '1') then
			muxcnt <= muxcnt + 1;
		end if;
		
		charisk <= (not muxcnt(0)) and (not muxcnt(1)) and (not muxcnt(2)) and (not muxcnt(3));
		
		if (daddmux = '1') then
			if (dispp = '1') then
				disparity <= '1';
			elsif (dispm = '1') then
				disparity <= '0';
			else
				disparity <= disparity;
			end if;
		end if;
		
		sdout <= isdout;
	
	end if;
	end process;

	lut6_addmux : LUT6
	generic map(INIT => X"0000008421084210")
	port map(
		I5 => fcnt(6),
		I4 => fcnt(5),
		I3 => fcnt(4),
		I2 => fcnt(3),
		I1 => fcnt(2),
		I0 => fcnt(1),
		O => iaddmux
	);

	u1 : encoder_8b10b port map(
		sdout => sdout,
		charisk => charisk,
		disparity => disparity,
		clk => clk,
		parout => parout,
		dispp => dispp,
		dispm => dispm
	);
	
	isdout <= "00111100" when muxcnt = "0000"
	     else mod_mid when muxcnt = "0001"
	     else "000000" & mod_type & mod_type when muxcnt = "0010"
		  else mod_din(7 downto 0) when muxcnt = "0011"
		  else mod_din(15 downto 8) when muxcnt = "0100"
		  else mod_din(23 downto 16) when muxcnt = "0101"
		  else mod_din(31 downto 24) when muxcnt = "0110"
		  else "10110101";

end Behavioral;


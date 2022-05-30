library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity tcb_transmitter_timer is port(
	signal send_com : in std_logic_vector(7 downto 0);
	signal send_data : in std_logic_vector(47 downto 0);
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal parout_timer : out std_logic_vector(9 downto 0)
); end tcb_transmitter_timer;

architecture Behavioral of tcb_transmitter_timer is

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
signal olddisp : std_logic := '0';
signal disparity : std_logic := '0';
signal isdout : std_logic_vector(7 downto 0);
signal sdout : std_logic_vector(7 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		clr <= tcb_ftime(6) and (not tcb_ftime(5)) and tcb_ftime(4) and tcb_ftime(3) 
		   and (not tcb_ftime(2)) and (not tcb_ftime(1)) and (not tcb_ftime(0));

		addmux <= iaddmux and (not tcb_ftime(0)); 
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
		I5 => tcb_ftime(6),
		I4 => tcb_ftime(5),
		I3 => tcb_ftime(4),
		I2 => tcb_ftime(3),
		I1 => tcb_ftime(2),
		I0 => tcb_ftime(1),
		O => iaddmux
	);

	u1 : encoder_8b10b port map(
		sdout => sdout,
		charisk => charisk,
		disparity => disparity,
		clk => clk,
		parout => parout_timer,
		dispp => dispp,
		dispm => dispm
	);
	
	isdout <= "00111100" when muxcnt = "0000"
	     else send_com when muxcnt = "0001"
		  else send_data(7 downto 0) when muxcnt = "0010"
		  else send_data(15 downto 8) when muxcnt = "0011"
		  else send_data(23 downto 16) when muxcnt = "0100"
		  else send_data(31 downto 24) when muxcnt = "0101"
		  else send_data(39 downto 32) when muxcnt = "0110"
		  else send_data(47 downto 40) when muxcnt = "0111"
		  else "10110101";

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity tcb_serializer is port(
	signal parout : in std_logic_vector(9 downto 0);
	signal fcnt : in std_logic_vector(6 downto 0);
	signal trgdat : in std_logic;
	signal run : in std_logic;
	signal linkok : in std_logic;
	signal clk : in std_logic;
	signal p_adc_trigp : out std_logic;
	signal p_adc_trign : out std_logic
); end tcb_serializer;

architecture Behavioral of tcb_serializer is

signal adc_trig : std_logic;

signal dlinkok : std_logic;
signal d2linkok : std_logic;
signal load : std_logic;
signal iload : std_logic;
signal serdat : std_logic_vector(9 downto 0);

attribute iob : string;
attribute iob of adc_trig : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		dlinkok <= linkok;
		d2linkok <= dlinkok;

		load <= iload and fcnt(0);
		
		if (d2linkok = '0') then
			serdat <= "0000000000";
		elsif (load = '1') then
			serdat <= parout;
		else
			serdat <= '0' & serdat(9 downto 1);
		end if;
	
		adc_trig <= (serdat(0) and (not run)) or (trgdat and run);
	
	end if;
	end process;
	
	lut6_load : LUT6
	generic map(INIT => X"0000010842108421")
	port map(
		I5 => fcnt(6),
		I4 => fcnt(5),
		I3 => fcnt(4),
		I2 => fcnt(3),
		I1 => fcnt(2),
		I0 => fcnt(1),
		O => iload
	);

	obufds_adc_trig : obufds port map(i => adc_trig, o => p_adc_trigp, ob => p_adc_trign);

end Behavioral;

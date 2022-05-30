library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity tcb_serializer_timer is port(
	signal parout_timer : in std_logic_vector(9 downto 0);
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal p_tcb_timerp : out std_logic_vector(39 downto 0);
	signal p_tcb_timern : out std_logic_vector(39 downto 0)
); end tcb_serializer_timer;

architecture Behavioral of tcb_serializer_timer is

signal tcb_timer : std_logic_vector(39 downto 0);

signal load : std_logic;
signal iload : std_logic;
signal serdat : std_logic_vector(9 downto 0);

attribute iob : string;
attribute iob of tcb_timer : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		load <= iload and tcb_ftime(0);
		
		if (load = '1') then
			serdat <= parout_timer;
		else
			serdat <= '0' & serdat(9 downto 1);
		end if;
	
		tcb_timer(0) <= not serdat(0);
		tcb_timer(1) <= not serdat(0);
		tcb_timer(2) <= not serdat(0);
		tcb_timer(3) <= serdat(0);
		tcb_timer(4) <= not serdat(0);
		tcb_timer(5) <= serdat(0);
		tcb_timer(6) <= not serdat(0);
		tcb_timer(7) <= serdat(0);
		tcb_timer(8) <= not serdat(0);
		tcb_timer(9) <= not serdat(0);
		tcb_timer(10) <= not serdat(0);
		tcb_timer(11) <= not serdat(0);
		tcb_timer(12) <= not serdat(0);
		tcb_timer(13) <= serdat(0);
		tcb_timer(14) <= not serdat(0);
		tcb_timer(15) <= serdat(0);
		tcb_timer(16) <= not serdat(0);
		tcb_timer(17) <= serdat(0);
		tcb_timer(18) <= not serdat(0);
		tcb_timer(19) <= serdat(0);
		tcb_timer(20) <= serdat(0);
		tcb_timer(21) <= not serdat(0);
		tcb_timer(22) <= serdat(0);
		tcb_timer(23) <= serdat(0);
		tcb_timer(24) <= not serdat(0);
		tcb_timer(25) <= not serdat(0);
		tcb_timer(26) <= serdat(0);
		tcb_timer(27) <= serdat(0);
		tcb_timer(28) <= serdat(0);
		tcb_timer(29) <= serdat(0);
		tcb_timer(30) <= not serdat(0);
		tcb_timer(31) <= serdat(0);
		tcb_timer(32) <= not serdat(0);
		tcb_timer(33) <= not serdat(0);
		tcb_timer(34) <= serdat(0);
		tcb_timer(35) <= serdat(0);
		tcb_timer(36) <= not serdat(0);
		tcb_timer(37) <= serdat(0);
		tcb_timer(38) <= not serdat(0);
		tcb_timer(39) <= serdat(0);
		
	end if;
	end process;
	
	lut6_load : LUT6
	generic map(INIT => X"0000010842108421")
	port map(
		I5 => tcb_ftime(6),
		I4 => tcb_ftime(5),
		I3 => tcb_ftime(4),
		I2 => tcb_ftime(3),
		I1 => tcb_ftime(2),
		I0 => tcb_ftime(1),
		O => iload
	);

	obufds_tcb_timer0 : obufds port map(i => tcb_timer(0), o => p_tcb_timern(0), ob => p_tcb_timerp(0));
	obufds_tcb_timer1 : obufds port map(i => tcb_timer(1), o => p_tcb_timern(1), ob => p_tcb_timerp(1));
	obufds_tcb_timer2 : obufds port map(i => tcb_timer(2), o => p_tcb_timern(2), ob => p_tcb_timerp(2));
	obufds_tcb_timer3 : obufds port map(i => tcb_timer(3), o => p_tcb_timerp(3), ob => p_tcb_timern(3));
	obufds_tcb_timer4 : obufds port map(i => tcb_timer(4), o => p_tcb_timern(4), ob => p_tcb_timerp(4));
	obufds_tcb_timer5 : obufds port map(i => tcb_timer(5), o => p_tcb_timerp(5), ob => p_tcb_timern(5));
	obufds_tcb_timer6 : obufds port map(i => tcb_timer(6), o => p_tcb_timern(6), ob => p_tcb_timerp(6));
	obufds_tcb_timer7 : obufds port map(i => tcb_timer(7), o => p_tcb_timerp(7), ob => p_tcb_timern(7));
	obufds_tcb_timer8 : obufds port map(i => tcb_timer(8), o => p_tcb_timern(8), ob => p_tcb_timerp(8));
	obufds_tcb_timer9 : obufds port map(i => tcb_timer(9), o => p_tcb_timern(9), ob => p_tcb_timerp(9));
	obufds_tcb_timer10 : obufds port map(i => tcb_timer(10), o => p_tcb_timern(10), ob => p_tcb_timerp(10));
	obufds_tcb_timer11 : obufds port map(i => tcb_timer(11), o => p_tcb_timern(11), ob => p_tcb_timerp(11));
	obufds_tcb_timer12 : obufds port map(i => tcb_timer(12), o => p_tcb_timern(12), ob => p_tcb_timerp(12));
	obufds_tcb_timer13 : obufds port map(i => tcb_timer(13), o => p_tcb_timerp(13), ob => p_tcb_timern(13));
	obufds_tcb_timer14 : obufds port map(i => tcb_timer(14), o => p_tcb_timern(14), ob => p_tcb_timerp(14));
	obufds_tcb_timer15 : obufds port map(i => tcb_timer(15), o => p_tcb_timerp(15), ob => p_tcb_timern(15));
	obufds_tcb_timer16 : obufds port map(i => tcb_timer(16), o => p_tcb_timern(16), ob => p_tcb_timerp(16));
	obufds_tcb_timer17 : obufds port map(i => tcb_timer(17), o => p_tcb_timerp(17), ob => p_tcb_timern(17));
	obufds_tcb_timer18 : obufds port map(i => tcb_timer(18), o => p_tcb_timern(18), ob => p_tcb_timerp(18));
	obufds_tcb_timer19 : obufds port map(i => tcb_timer(19), o => p_tcb_timerp(19), ob => p_tcb_timern(19));
	obufds_tcb_timer20 : obufds port map(i => tcb_timer(20), o => p_tcb_timerp(20), ob => p_tcb_timern(20));
	obufds_tcb_timer21 : obufds port map(i => tcb_timer(21), o => p_tcb_timern(21), ob => p_tcb_timerp(21));
	obufds_tcb_timer22 : obufds port map(i => tcb_timer(22), o => p_tcb_timerp(22), ob => p_tcb_timern(22));
	obufds_tcb_timer23 : obufds port map(i => tcb_timer(23), o => p_tcb_timerp(23), ob => p_tcb_timern(23));
	obufds_tcb_timer24 : obufds port map(i => tcb_timer(24), o => p_tcb_timern(24), ob => p_tcb_timerp(24));
	obufds_tcb_timer25 : obufds port map(i => tcb_timer(25), o => p_tcb_timern(25), ob => p_tcb_timerp(25));
	obufds_tcb_timer26 : obufds port map(i => tcb_timer(26), o => p_tcb_timerp(26), ob => p_tcb_timern(26));
	obufds_tcb_timer27 : obufds port map(i => tcb_timer(27), o => p_tcb_timerp(27), ob => p_tcb_timern(27));
	obufds_tcb_timer28 : obufds port map(i => tcb_timer(28), o => p_tcb_timerp(28), ob => p_tcb_timern(28));
	obufds_tcb_timer29 : obufds port map(i => tcb_timer(29), o => p_tcb_timerp(29), ob => p_tcb_timern(29));
	obufds_tcb_timer30 : obufds port map(i => tcb_timer(30), o => p_tcb_timern(30), ob => p_tcb_timerp(30));
	obufds_tcb_timer31 : obufds port map(i => tcb_timer(31), o => p_tcb_timerp(31), ob => p_tcb_timern(31));
	obufds_tcb_timer32 : obufds port map(i => tcb_timer(32), o => p_tcb_timern(32), ob => p_tcb_timerp(32));
	obufds_tcb_timer33 : obufds port map(i => tcb_timer(33), o => p_tcb_timern(33), ob => p_tcb_timerp(33));
	obufds_tcb_timer34 : obufds port map(i => tcb_timer(34), o => p_tcb_timerp(34), ob => p_tcb_timern(34));
	obufds_tcb_timer35 : obufds port map(i => tcb_timer(35), o => p_tcb_timerp(35), ob => p_tcb_timern(35));
	obufds_tcb_timer36 : obufds port map(i => tcb_timer(36), o => p_tcb_timern(36), ob => p_tcb_timerp(36));
	obufds_tcb_timer37 : obufds port map(i => tcb_timer(37), o => p_tcb_timerp(37), ob => p_tcb_timern(37));
	obufds_tcb_timer38 : obufds port map(i => tcb_timer(38), o => p_tcb_timern(38), ob => p_tcb_timerp(38));
	obufds_tcb_timer39 : obufds port map(i => tcb_timer(39), o => p_tcb_timerp(39), ob => p_tcb_timern(39));

end Behavioral;


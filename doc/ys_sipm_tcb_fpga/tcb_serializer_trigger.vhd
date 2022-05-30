library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity tcb_serializer_trigger is port(
	signal parout_trg : in std_logic_vector(9 downto 0);
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal trgdat : in std_logic;
	signal run : in std_logic;
	signal clk : in std_logic;
	signal p_tcb_triggerp : out std_logic_vector(39 downto 0);
	signal p_tcb_triggern : out std_logic_vector(39 downto 0)
); end tcb_serializer_trigger;

architecture Behavioral of tcb_serializer_trigger is

signal tcb_trigger : std_logic_vector(39 downto 0);

signal load : std_logic;
signal iload : std_logic;
signal serdat : std_logic_vector(9 downto 0);
signal pdigout : std_logic_vector(39 downto 0);

attribute iob : string;
attribute iob of tcb_trigger : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		load <= iload and tcb_ftime(0);
		
		if (load = '1') then
			serdat <= parout_trg;
		else
			serdat <= '0' & serdat(9 downto 1);
		end if;
	
		tcb_trigger(0) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(1) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(2) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(3) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(4) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(5) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(6) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(7) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(8) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(9) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(10) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(11) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(12) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(13) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(14) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(15) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(16) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(17) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(18) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(19) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(20) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(21) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(22) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(23) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(24) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(25) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(26) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(27) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(28) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(29) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(30) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(31) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(32) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(33) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(34) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(35) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(36) <= not((serdat(0) and (not run)) or (trgdat and run));
		tcb_trigger(37) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(38) <= (serdat(0) and (not run)) or (trgdat and run);
		tcb_trigger(39) <= (serdat(0) and (not run)) or (trgdat and run);

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

	obufds_tcb_trigger0 : obufds port map(i => tcb_trigger(0), o => p_tcb_triggern(0), ob => p_tcb_triggerp(0));
	obufds_tcb_trigger1 : obufds port map(i => tcb_trigger(1), o => p_tcb_triggerp(1), ob => p_tcb_triggern(1));
	obufds_tcb_trigger2 : obufds port map(i => tcb_trigger(2), o => p_tcb_triggern(2), ob => p_tcb_triggerp(2));
	obufds_tcb_trigger3 : obufds port map(i => tcb_trigger(3), o => p_tcb_triggerp(3), ob => p_tcb_triggern(3));
	obufds_tcb_trigger4 : obufds port map(i => tcb_trigger(4), o => p_tcb_triggerp(4), ob => p_tcb_triggern(4));
	obufds_tcb_trigger5 : obufds port map(i => tcb_trigger(5), o => p_tcb_triggerp(5), ob => p_tcb_triggern(5));
	obufds_tcb_trigger6 : obufds port map(i => tcb_trigger(6), o => p_tcb_triggerp(6), ob => p_tcb_triggern(6));
	obufds_tcb_trigger7 : obufds port map(i => tcb_trigger(7), o => p_tcb_triggern(7), ob => p_tcb_triggerp(7));
	obufds_tcb_trigger8 : obufds port map(i => tcb_trigger(8), o => p_tcb_triggerp(8), ob => p_tcb_triggern(8));
	obufds_tcb_trigger9 : obufds port map(i => tcb_trigger(9), o => p_tcb_triggern(9), ob => p_tcb_triggerp(9));
	obufds_tcb_trigger10 : obufds port map(i => tcb_trigger(10), o => p_tcb_triggerp(10), ob => p_tcb_triggern(10));
	obufds_tcb_trigger11 : obufds port map(i => tcb_trigger(11), o => p_tcb_triggern(11), ob => p_tcb_triggerp(11));
	obufds_tcb_trigger12 : obufds port map(i => tcb_trigger(12), o => p_tcb_triggerp(12), ob => p_tcb_triggern(12));
	obufds_tcb_trigger13 : obufds port map(i => tcb_trigger(13), o => p_tcb_triggerp(13), ob => p_tcb_triggern(13));
	obufds_tcb_trigger14 : obufds port map(i => tcb_trigger(14), o => p_tcb_triggerp(14), ob => p_tcb_triggern(14));
	obufds_tcb_trigger15 : obufds port map(i => tcb_trigger(15), o => p_tcb_triggern(15), ob => p_tcb_triggerp(15));
	obufds_tcb_trigger16 : obufds port map(i => tcb_trigger(16), o => p_tcb_triggerp(16), ob => p_tcb_triggern(16));
	obufds_tcb_trigger17 : obufds port map(i => tcb_trigger(17), o => p_tcb_triggerp(17), ob => p_tcb_triggern(17));
	obufds_tcb_trigger18 : obufds port map(i => tcb_trigger(18), o => p_tcb_triggern(18), ob => p_tcb_triggerp(18));
	obufds_tcb_trigger19 : obufds port map(i => tcb_trigger(19), o => p_tcb_triggerp(19), ob => p_tcb_triggern(19));
	obufds_tcb_trigger20 : obufds port map(i => tcb_trigger(20), o => p_tcb_triggerp(20), ob => p_tcb_triggern(20));
	obufds_tcb_trigger21 : obufds port map(i => tcb_trigger(21), o => p_tcb_triggerp(21), ob => p_tcb_triggern(21));
	obufds_tcb_trigger22 : obufds port map(i => tcb_trigger(22), o => p_tcb_triggerp(22), ob => p_tcb_triggern(22));
	obufds_tcb_trigger23 : obufds port map(i => tcb_trigger(23), o => p_tcb_triggern(23), ob => p_tcb_triggerp(23));
	obufds_tcb_trigger24 : obufds port map(i => tcb_trigger(24), o => p_tcb_triggerp(24), ob => p_tcb_triggern(24));
	obufds_tcb_trigger25 : obufds port map(i => tcb_trigger(25), o => p_tcb_triggern(25), ob => p_tcb_triggerp(25));
	obufds_tcb_trigger26 : obufds port map(i => tcb_trigger(26), o => p_tcb_triggern(26), ob => p_tcb_triggerp(26));
	obufds_tcb_trigger27 : obufds port map(i => tcb_trigger(27), o => p_tcb_triggerp(27), ob => p_tcb_triggern(27));
	obufds_tcb_trigger28 : obufds port map(i => tcb_trigger(28), o => p_tcb_triggern(28), ob => p_tcb_triggerp(28));
	obufds_tcb_trigger29 : obufds port map(i => tcb_trigger(29), o => p_tcb_triggerp(29), ob => p_tcb_triggern(29));
	obufds_tcb_trigger30 : obufds port map(i => tcb_trigger(30), o => p_tcb_triggern(30), ob => p_tcb_triggerp(30));
	obufds_tcb_trigger31 : obufds port map(i => tcb_trigger(31), o => p_tcb_triggern(31), ob => p_tcb_triggerp(31));
	obufds_tcb_trigger32 : obufds port map(i => tcb_trigger(32), o => p_tcb_triggern(32), ob => p_tcb_triggerp(32));
	obufds_tcb_trigger33 : obufds port map(i => tcb_trigger(33), o => p_tcb_triggerp(33), ob => p_tcb_triggern(33));
	obufds_tcb_trigger34 : obufds port map(i => tcb_trigger(34), o => p_tcb_triggern(34), ob => p_tcb_triggerp(34));
	obufds_tcb_trigger35 : obufds port map(i => tcb_trigger(35), o => p_tcb_triggerp(35), ob => p_tcb_triggern(35));
	obufds_tcb_trigger36 : obufds port map(i => tcb_trigger(36), o => p_tcb_triggern(36), ob => p_tcb_triggerp(36));
	obufds_tcb_trigger37 : obufds port map(i => tcb_trigger(37), o => p_tcb_triggerp(37), ob => p_tcb_triggern(37));
	obufds_tcb_trigger38 : obufds port map(i => tcb_trigger(38), o => p_tcb_triggerp(38), ob => p_tcb_triggern(38));
	obufds_tcb_trigger39 : obufds port map(i => tcb_trigger(39), o => p_tcb_triggerp(39), ob => p_tcb_triggern(39));

end Behavioral;


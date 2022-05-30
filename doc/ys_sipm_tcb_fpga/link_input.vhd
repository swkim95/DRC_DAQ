library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity link_input is port(
	signal p_adc_triggerp : in std_logic_vector(39 downto 0);
	signal p_adc_triggern : in std_logic_vector(39 downto 0);
	signal run : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal mod_mid : out mod_mid_array;
	signal triged : out std_logic_vector(39 downto 0);
	signal mod_nhit : out mod_nhit_array;
	signal mod_rdat : out mod_rdat_array;
	signal response : out std_logic_vector(39 downto 0);
	signal linked : out std_logic_vector(39 downto 0)
); end link_input;

architecture Behavioral of link_input is

component link_input_ch port(
	signal adc_trigger : in std_logic;
	signal run : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal mod_mid : out std_logic_vector(7 downto 0);
	signal triged : out std_logic;
	signal mod_nhit : out std_logic_vector(5 downto 0);
	signal mod_rdat : out std_logic_vector(31 downto 0);
	signal response : out std_logic;
	signal linked : out std_logic
); end component;

signal padc_trigger : std_logic_vector(39 downto 0);
signal adc_trigger : std_logic_vector(39 downto 0);

begin

	ibufds_adc_trigger0 : ibufds port map(i => p_adc_triggern(0), ib => p_adc_triggerp(0), o => padc_trigger(0));
	ibufds_adc_trigger1 : ibufds port map(i => p_adc_triggern(1), ib => p_adc_triggerp(1), o => padc_trigger(1));
	ibufds_adc_trigger2 : ibufds port map(i => p_adc_triggerp(2), ib => p_adc_triggern(2), o => padc_trigger(2));
	ibufds_adc_trigger3 : ibufds port map(i => p_adc_triggerp(3), ib => p_adc_triggern(3), o => padc_trigger(3));
	ibufds_adc_trigger4 : ibufds port map(i => p_adc_triggerp(4), ib => p_adc_triggern(4), o => padc_trigger(4));
	ibufds_adc_trigger5 : ibufds port map(i => p_adc_triggern(5), ib => p_adc_triggerp(5), o => padc_trigger(5));
	ibufds_adc_trigger6 : ibufds port map(i => p_adc_triggerp(6), ib => p_adc_triggern(6), o => padc_trigger(6));
	ibufds_adc_trigger7 : ibufds port map(i => p_adc_triggerp(7), ib => p_adc_triggern(7), o => padc_trigger(7));
	ibufds_adc_trigger8 : ibufds port map(i => p_adc_triggern(8), ib => p_adc_triggerp(8), o => padc_trigger(8));
	ibufds_adc_trigger9 : ibufds port map(i => p_adc_triggerp(9), ib => p_adc_triggern(9), o => padc_trigger(9));
	ibufds_adc_trigger10 : ibufds port map(i => p_adc_triggern(10), ib => p_adc_triggerp(10), o => padc_trigger(10));
	ibufds_adc_trigger11 : ibufds port map(i => p_adc_triggerp(11), ib => p_adc_triggern(11), o => padc_trigger(11));
	ibufds_adc_trigger12 : ibufds port map(i => p_adc_triggern(12), ib => p_adc_triggerp(12), o => padc_trigger(12));
	ibufds_adc_trigger13 : ibufds port map(i => p_adc_triggerp(13), ib => p_adc_triggern(13), o => padc_trigger(13));
	ibufds_adc_trigger14 : ibufds port map(i => p_adc_triggerp(14), ib => p_adc_triggern(14), o => padc_trigger(14));
	ibufds_adc_trigger15 : ibufds port map(i => p_adc_triggern(15), ib => p_adc_triggerp(15), o => padc_trigger(15));
	ibufds_adc_trigger16 : ibufds port map(i => p_adc_triggerp(16), ib => p_adc_triggern(16), o => padc_trigger(16));
	ibufds_adc_trigger17 : ibufds port map(i => p_adc_triggerp(17), ib => p_adc_triggern(17), o => padc_trigger(17));
	ibufds_adc_trigger18 : ibufds port map(i => p_adc_triggerp(18), ib => p_adc_triggern(18), o => padc_trigger(18));
	ibufds_adc_trigger19 : ibufds port map(i => p_adc_triggern(19), ib => p_adc_triggerp(19), o => padc_trigger(19));
	ibufds_adc_trigger20 : ibufds port map(i => p_adc_triggern(20), ib => p_adc_triggerp(20), o => padc_trigger(20));
	ibufds_adc_trigger21 : ibufds port map(i => p_adc_triggerp(21), ib => p_adc_triggern(21), o => padc_trigger(21));
	ibufds_adc_trigger22 : ibufds port map(i => p_adc_triggerp(22), ib => p_adc_triggern(22), o => padc_trigger(22));
	ibufds_adc_trigger23 : ibufds port map(i => p_adc_triggerp(23), ib => p_adc_triggern(23), o => padc_trigger(23));
	ibufds_adc_trigger24 : ibufds port map(i => p_adc_triggerp(24), ib => p_adc_triggern(24), o => padc_trigger(24));
	ibufds_adc_trigger25 : ibufds port map(i => p_adc_triggern(25), ib => p_adc_triggerp(25), o => padc_trigger(25));
	ibufds_adc_trigger26 : ibufds port map(i => p_adc_triggerp(26), ib => p_adc_triggern(26), o => padc_trigger(26));
	ibufds_adc_trigger27 : ibufds port map(i => p_adc_triggern(27), ib => p_adc_triggerp(27), o => padc_trigger(27));
	ibufds_adc_trigger28 : ibufds port map(i => p_adc_triggerp(28), ib => p_adc_triggern(28), o => padc_trigger(28));
	ibufds_adc_trigger29 : ibufds port map(i => p_adc_triggern(29), ib => p_adc_triggerp(29), o => padc_trigger(29));
	ibufds_adc_trigger30 : ibufds port map(i => p_adc_triggerp(30), ib => p_adc_triggern(30), o => padc_trigger(30));
	ibufds_adc_trigger31 : ibufds port map(i => p_adc_triggerp(31), ib => p_adc_triggern(31), o => padc_trigger(31));
	ibufds_adc_trigger32 : ibufds port map(i => p_adc_triggerp(32), ib => p_adc_triggern(32), o => padc_trigger(32));
	ibufds_adc_trigger33 : ibufds port map(i => p_adc_triggerp(33), ib => p_adc_triggern(33), o => padc_trigger(33));
	ibufds_adc_trigger34 : ibufds port map(i => p_adc_triggern(34), ib => p_adc_triggerp(34), o => padc_trigger(34));
	ibufds_adc_trigger35 : ibufds port map(i => p_adc_triggerp(35), ib => p_adc_triggern(35), o => padc_trigger(35));
	ibufds_adc_trigger36 : ibufds port map(i => p_adc_triggern(36), ib => p_adc_triggerp(36), o => padc_trigger(36));
	ibufds_adc_trigger37 : ibufds port map(i => p_adc_triggerp(37), ib => p_adc_triggern(37), o => padc_trigger(37));
	ibufds_adc_trigger38 : ibufds port map(i => p_adc_triggern(38), ib => p_adc_triggerp(38), o => padc_trigger(38));
	ibufds_adc_trigger39 : ibufds port map(i => p_adc_triggerp(39), ib => p_adc_triggern(39), o => padc_trigger(39));

	adc_trigger(0) <= not padc_trigger(0);
	adc_trigger(1) <= not padc_trigger(1);
	adc_trigger(2) <= padc_trigger(2);
	adc_trigger(3) <= padc_trigger(3);
	adc_trigger(4) <= padc_trigger(4);
	adc_trigger(5) <= not padc_trigger(5);
	adc_trigger(6) <= padc_trigger(6);
	adc_trigger(7) <= padc_trigger(7);
	adc_trigger(8) <= not padc_trigger(8);
	adc_trigger(9) <= padc_trigger(9);
	adc_trigger(10) <= not padc_trigger(10);
	adc_trigger(11) <= padc_trigger(11);
	adc_trigger(12) <= not padc_trigger(12);
	adc_trigger(13) <= padc_trigger(13);
	adc_trigger(14) <= padc_trigger(14);
	adc_trigger(15) <= not padc_trigger(15);
	adc_trigger(16) <= padc_trigger(16);
	adc_trigger(17) <= padc_trigger(17);
	adc_trigger(18) <= padc_trigger(18);
	adc_trigger(19) <= not padc_trigger(19);
	adc_trigger(20) <= not padc_trigger(20);
	adc_trigger(21) <= padc_trigger(21);
	adc_trigger(22) <= padc_trigger(22);
	adc_trigger(23) <= padc_trigger(23);
	adc_trigger(24) <= padc_trigger(24);
	adc_trigger(25) <= not padc_trigger(25);
	adc_trigger(26) <= padc_trigger(26);
	adc_trigger(27) <= not padc_trigger(27);
	adc_trigger(28) <= padc_trigger(28);
	adc_trigger(29) <= not padc_trigger(29);
	adc_trigger(30) <= padc_trigger(30);
	adc_trigger(31) <= padc_trigger(31);
	adc_trigger(32) <= padc_trigger(32);
	adc_trigger(33) <= padc_trigger(33);
	adc_trigger(34) <= not padc_trigger(34);
	adc_trigger(35) <= padc_trigger(35);
	adc_trigger(36) <= not padc_trigger(36);
	adc_trigger(37) <= padc_trigger(37);
	adc_trigger(38) <= not padc_trigger(38);
	adc_trigger(39) <= padc_trigger(39);

	myloop1 : for ch in 0 to 39 generate
		u1 : link_input_ch port map(
			adc_trigger => adc_trigger(ch),
			run => run,
			x2clk => x2clk,
			clk => clk,
			mod_mid => mod_mid(ch),
			triged => triged(ch),
			mod_nhit => mod_nhit(ch),
			mod_rdat => mod_rdat(ch),
			response => response(ch),
			linked => linked(ch)
		);
	end generate;

end Behavioral;


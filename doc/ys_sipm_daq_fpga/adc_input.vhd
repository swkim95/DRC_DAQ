library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity adc_input is port(
	signal p_adc_dp : in std_logic_vector(31 downto 0);
	signal p_adc_dn : in std_logic_vector(31 downto 0);
	signal adc_in : out std_logic_vector(31 downto 0)
); end adc_input;

architecture Behavioral of adc_input is

signal padc_in : std_logic_vector(31 downto 0);

begin

	ibufds_padc_in0 : ibufds port map(i => p_adc_dp(0), ib => p_adc_dn(0), o => padc_in(0));
	ibufds_padc_in1 : ibufds port map(i => p_adc_dn(1), ib => p_adc_dp(1), o => padc_in(1));
	ibufds_padc_in2 : ibufds port map(i => p_adc_dp(2), ib => p_adc_dn(2), o => padc_in(2));
	ibufds_padc_in3 : ibufds port map(i => p_adc_dp(3), ib => p_adc_dn(3), o => padc_in(3));
	ibufds_padc_in4 : ibufds port map(i => p_adc_dn(4), ib => p_adc_dp(4), o => padc_in(4));
	ibufds_padc_in5 : ibufds port map(i => p_adc_dn(5), ib => p_adc_dp(5), o => padc_in(5));
	ibufds_padc_in6 : ibufds port map(i => p_adc_dn(6), ib => p_adc_dp(6), o => padc_in(6));
	ibufds_padc_in7 : ibufds port map(i => p_adc_dn(7), ib => p_adc_dp(7), o => padc_in(7));
	ibufds_padc_in8 : ibufds port map(i => p_adc_dp(8), ib => p_adc_dn(8), o => padc_in(8));
	ibufds_padc_in9 : ibufds port map(i => p_adc_dp(9), ib => p_adc_dn(9), o => padc_in(9));
	ibufds_padc_in10 : ibufds port map(i => p_adc_dp(10), ib => p_adc_dn(10), o => padc_in(10));
	ibufds_padc_in11 : ibufds port map(i => p_adc_dp(11), ib => p_adc_dn(11), o => padc_in(11));
	ibufds_padc_in12 : ibufds port map(i => p_adc_dp(12), ib => p_adc_dn(12), o => padc_in(12));
	ibufds_padc_in13 : ibufds port map(i => p_adc_dn(13), ib => p_adc_dp(13), o => padc_in(13));
	ibufds_padc_in14 : ibufds port map(i => p_adc_dn(14), ib => p_adc_dp(14), o => padc_in(14));
	ibufds_padc_in15 : ibufds port map(i => p_adc_dn(15), ib => p_adc_dp(15), o => padc_in(15));
	ibufds_padc_in16 : ibufds port map(i => p_adc_dn(16), ib => p_adc_dp(16), o => padc_in(16));
	ibufds_padc_in17 : ibufds port map(i => p_adc_dn(17), ib => p_adc_dp(17), o => padc_in(17));
	ibufds_padc_in18 : ibufds port map(i => p_adc_dn(18), ib => p_adc_dp(18), o => padc_in(18));
	ibufds_padc_in19 : ibufds port map(i => p_adc_dn(19), ib => p_adc_dp(19), o => padc_in(19));
	ibufds_padc_in20 : ibufds port map(i => p_adc_dn(20), ib => p_adc_dp(20), o => padc_in(20));
	ibufds_padc_in21 : ibufds port map(i => p_adc_dp(21), ib => p_adc_dn(21), o => padc_in(21));
	ibufds_padc_in22 : ibufds port map(i => p_adc_dp(22), ib => p_adc_dn(22), o => padc_in(22));
	ibufds_padc_in23 : ibufds port map(i => p_adc_dp(23), ib => p_adc_dn(23), o => padc_in(23));
	ibufds_padc_in24 : ibufds port map(i => p_adc_dp(24), ib => p_adc_dn(24), o => padc_in(24));
	ibufds_padc_in25 : ibufds port map(i => p_adc_dp(25), ib => p_adc_dn(25), o => padc_in(25));
	ibufds_padc_in26 : ibufds port map(i => p_adc_dp(26), ib => p_adc_dn(26), o => padc_in(26));
	ibufds_padc_in27 : ibufds port map(i => p_adc_dp(27), ib => p_adc_dn(27), o => padc_in(27));
	ibufds_padc_in28 : ibufds port map(i => p_adc_dp(28), ib => p_adc_dn(28), o => padc_in(28));
	ibufds_padc_in29 : ibufds port map(i => p_adc_dp(29), ib => p_adc_dn(29), o => padc_in(29));
	ibufds_padc_in30 : ibufds port map(i => p_adc_dn(30), ib => p_adc_dp(30), o => padc_in(30));
	ibufds_padc_in31 : ibufds port map(i => p_adc_dn(31), ib => p_adc_dp(31), o => padc_in(31));

	adc_in(0) <= not padc_in(0);
	adc_in(1) <= padc_in(1);
	adc_in(2) <= not padc_in(2);
	adc_in(3) <= not padc_in(3);
	adc_in(4) <= padc_in(4);
	adc_in(5) <= padc_in(5);
	adc_in(6) <= padc_in(6);
	adc_in(7) <= padc_in(7);
	adc_in(8) <= not padc_in(8);
	adc_in(9) <= not padc_in(9);
	adc_in(10) <= not padc_in(10);
	adc_in(11) <= not padc_in(11);
	adc_in(12) <= not padc_in(12);
	adc_in(13) <= padc_in(13);
	adc_in(14) <= padc_in(14);
	adc_in(15) <= padc_in(15);
	adc_in(16) <= padc_in(16);
	adc_in(17) <= padc_in(17);
	adc_in(18) <= padc_in(18);
	adc_in(19) <= padc_in(19);
	adc_in(20) <= padc_in(20);
	adc_in(21) <= not padc_in(21);
	adc_in(22) <= not padc_in(22);
	adc_in(23) <= not padc_in(23);
	adc_in(24) <= not padc_in(24);
	adc_in(25) <= not padc_in(25);
	adc_in(26) <= not padc_in(26);
	adc_in(27) <= not padc_in(27);
	adc_in(28) <= not padc_in(28);
	adc_in(29) <= not padc_in(29);
	adc_in(30) <= padc_in(30);
	adc_in(31) <= padc_in(31);

end Behavioral;


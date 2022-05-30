library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity trigger_pulse is port(
	signal cw : in std_logic_vector(3 downto 0);
	signal mod_nhit : in mod_nhit_array;
	signal triged : in std_logic_vector(39 downto 0);
	signal clk : in std_logic;
	signal tpulse : out tpulse_array
); end trigger_pulse;

architecture Behavioral of trigger_pulse is

component trigger_pulse_ch port(
	signal cw : in std_logic_vector(3 downto 0);
	signal mod_nhit : in std_logic_vector(5 downto 0);
	signal triged : in std_logic;
	signal clk : in std_logic;
	signal tpulse : out std_logic_vector(5 downto 0)
); end component;

begin

	myloop1 : for ch in 0 to 39 generate
		u1 : trigger_pulse_ch port map(
			cw => cw,
			mod_nhit => mod_nhit(ch),
			triged => triged(ch),
			clk => clk,
			tpulse => tpulse(ch)
		);
	end generate;

end Behavioral;


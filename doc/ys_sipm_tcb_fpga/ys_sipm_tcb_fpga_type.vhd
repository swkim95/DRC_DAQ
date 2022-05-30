library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ys_sipm_tcb_fpga_type is

	type mod_mid_array is array(39 downto 0) of std_logic_vector(7 downto 0);
	type mod_nhit_array is array(39 downto 0) of std_logic_vector(5 downto 0);
	type mod_rdat_array is array(39 downto 0) of std_logic_vector(31 downto 0);
	type tpulse_array is array(39 downto 0) of std_logic_vector(5 downto 0);

end ys_sipm_tcb_fpga_type;


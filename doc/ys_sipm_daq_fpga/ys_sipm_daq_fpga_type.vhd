library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ys_sipm_daq_fpga_type is

	type drs_a_array is array(3 downto 0) of std_logic_vector(2 downto 0);
	type hv_data_array is array(3 downto 0) of std_logic_vector(7 downto 0);
	type thr_data_array is array(31 downto 0) of std_logic_vector(11 downto 0);
	type adc_data_array is array(31 downto 0) of std_logic_vector(11 downto 0);
--	type drs_stop_addr_array is array(3 downto 0) of std_logic_vector(9 downto 0);
	type dram_idly_array is array(1 downto 0) of std_logic_vector(4 downto 0);

end ys_sipm_daq_fpga_type;


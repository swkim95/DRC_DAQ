library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity dram_alignment is port(
	signal dram_pattern : in std_logic_vector(63 downto 0);
	signal dram_test_clr : in std_logic;
	signal dram_test_and : in std_logic;
	signal clk_dram : in std_logic;
	signal clk : in std_logic;
	signal dram_test_pattern : out std_logic_vector(63 downto 0)
); end dram_alignment;

architecture Behavioral of dram_alignment is

signal dram_test_pattern_reg : std_logic_vector(63 downto 0);
signal pdram_test_pattern : std_logic_vector(63 downto 0);

begin

	process(clk_dram) begin
	if (clk_dram'event and clk_dram = '1') then
	
		for i in 0 to 63 loop
			if (dram_test_clr = '1') then
				pdram_test_pattern(i) <= '1';
			elsif (dram_test_and = '1') then
				pdram_test_pattern(i) <= pdram_test_pattern(i) and dram_pattern(i);
			end if;
		end loop;

	end if;
	end process;

	process(clk) begin
	if (clk'event and clk = '1') then
	
		dram_test_pattern_reg <= pdram_test_pattern;

	end if;
	end process;

	dram_test_pattern <= dram_test_pattern_reg;

end Behavioral;


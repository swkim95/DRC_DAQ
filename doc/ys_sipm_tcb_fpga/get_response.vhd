library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity get_response is port(
	signal mod_rdat : in mod_rdat_array;
	signal response : in std_logic_vector(39 downto 0);
	signal mid_addr : in std_logic_vector(5 downto 0);
	signal clk : in std_logic;
	signal mod_rdata : out std_logic_vector(31 downto 0)
); end get_response;

architecture Behavioral of get_response is

signal mod_rdata_reg : std_logic_vector(31 downto 0);
signal reg_rdat : mod_rdat_array;
signal imod_rdata : std_logic_vector(31 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		for ch in 0 to 39 loop
			if (response(ch) = '1') then
				reg_rdat(ch) <= mod_rdat(ch);
			end if;
		end loop;
		
		mod_rdata_reg <= imod_rdata;

	end if;
	end process;
	
	imod_rdata <= reg_rdat(0) when mid_addr = "000001"
			   else reg_rdat(1) when mid_addr = "000010"
			   else reg_rdat(2) when mid_addr = "000011"
			   else reg_rdat(3) when mid_addr = "000100"
			   else reg_rdat(4) when mid_addr = "000101"
			   else reg_rdat(5) when mid_addr = "000110"
			   else reg_rdat(6) when mid_addr = "000111"
			   else reg_rdat(7) when mid_addr = "001000"
			   else reg_rdat(8) when mid_addr = "001001"
			   else reg_rdat(9) when mid_addr = "001010"
			   else reg_rdat(10) when mid_addr = "001011"
			   else reg_rdat(11) when mid_addr = "001100"
			   else reg_rdat(12) when mid_addr = "001101"
			   else reg_rdat(13) when mid_addr = "001110"
			   else reg_rdat(14) when mid_addr = "001111"
			   else reg_rdat(15) when mid_addr = "010000"
			   else reg_rdat(16) when mid_addr = "010001"
			   else reg_rdat(17) when mid_addr = "010010"
			   else reg_rdat(18) when mid_addr = "010011"
			   else reg_rdat(19) when mid_addr = "010100"
			   else reg_rdat(20) when mid_addr = "010101"
			   else reg_rdat(21) when mid_addr = "010110"
			   else reg_rdat(22) when mid_addr = "010111"
			   else reg_rdat(23) when mid_addr = "011000"
			   else reg_rdat(24) when mid_addr = "011001"
			   else reg_rdat(25) when mid_addr = "011010"
			   else reg_rdat(26) when mid_addr = "011011"
			   else reg_rdat(27) when mid_addr = "011100"
			   else reg_rdat(28) when mid_addr = "011101"
			   else reg_rdat(29) when mid_addr = "011110"
			   else reg_rdat(30) when mid_addr = "011111"
			   else reg_rdat(31) when mid_addr = "100000"
			   else reg_rdat(32) when mid_addr = "100001"
			   else reg_rdat(33) when mid_addr = "100010"
			   else reg_rdat(34) when mid_addr = "100011"
			   else reg_rdat(35) when mid_addr = "100100"
			   else reg_rdat(36) when mid_addr = "100101"
			   else reg_rdat(37) when mid_addr = "100110"
			   else reg_rdat(38) when mid_addr = "100111"
			   else reg_rdat(39) when mid_addr = "101000"
			   else "00000000000000000000000000000000";

	mod_rdata <= mod_rdata_reg;

end Behavioral;


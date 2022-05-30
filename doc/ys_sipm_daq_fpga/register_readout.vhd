library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity register_readout is port(
	signal run : in std_logic;
--	signal cw : in std_logic_vector(3 downto 0);
	signal hv_data : in hv_data_array;
	signal thr_data : in thr_data_array;
	signal temp_data : in std_logic_vector(11 downto 0);
	signal drs_pll_locked : in std_logic_vector(3 downto 0);
	signal dram_ready : in std_logic;
	signal dram_test_pattern : in std_logic_vector(63 downto 0);
	signal reg_rch : in std_logic_vector(4 downto 0);
	signal reg_raddr : in std_logic_vector(4 downto 0);
	signal reg_latch : in std_logic;
	signal clk : in std_logic;
	signal latch_temp : out std_logic;
	signal latch_pll_lock : out std_logic;
	signal reg_rdata : out std_logic_vector(31 downto 0)
); end register_readout;

architecture Behavioral of register_readout is

signal latch_temp_reg : std_logic;
signal latch_pll_lock_reg : std_logic;
signal reg_rdata_reg : std_logic_vector(31 downto 0);
signal irb_hv_data : std_logic_vector(7 downto 0);
signal rb_hv_data : std_logic_vector(7 downto 0);
signal irb_thr_data : std_logic_vector(11 downto 0);
signal rb_thr_data : std_logic_vector(11 downto 0);
signal irb_dram_pattern : std_logic_vector(31 downto 0);
signal rb_dram_pattern : std_logic_vector(31 downto 0);
signal ireg_rdata : std_logic_vector(31 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		latch_temp_reg <= reg_latch and (not reg_raddr(4)) and (not reg_raddr(3))
		             and reg_raddr(2) and reg_raddr(1) and (not reg_raddr(0));

		latch_pll_lock_reg <= reg_latch and (not reg_raddr(4)) and (not reg_raddr(3))
		                  and reg_raddr(2) and reg_raddr(1) and reg_raddr(0);

		rb_hv_data <= irb_hv_data;
		rb_thr_data <= irb_thr_data;
		rb_dram_pattern <= irb_dram_pattern;

		reg_rdata_reg <= ireg_rdata;
		
	end if;
	end process;
	
	irb_hv_data <= hv_data(0) when reg_rch(1 downto 0) = "00"
	          else hv_data(1) when reg_rch(1 downto 0) = "01"
	          else hv_data(2) when reg_rch(1 downto 0) = "10"
	          else hv_data(3);

	irb_thr_data <= thr_data(0) when reg_rch = "00000"
 	           else thr_data(1) when reg_rch = "00001"
 	           else thr_data(2) when reg_rch = "00010"
 	           else thr_data(3) when reg_rch = "00011"
 	           else thr_data(4) when reg_rch = "00100"
 	           else thr_data(5) when reg_rch = "00101"
 	           else thr_data(6) when reg_rch = "00110"
 	           else thr_data(7) when reg_rch = "00111"
 	           else thr_data(8) when reg_rch = "01000"
 	           else thr_data(9) when reg_rch = "01001"
 	           else thr_data(10) when reg_rch = "01010"
 	           else thr_data(11) when reg_rch = "01011"
 	           else thr_data(12) when reg_rch = "01100"
 	           else thr_data(13) when reg_rch = "01101"
 	           else thr_data(14) when reg_rch = "01110"
 	           else thr_data(15) when reg_rch = "01111"
 	           else thr_data(16) when reg_rch = "10000"
 	           else thr_data(17) when reg_rch = "10001"
 	           else thr_data(18) when reg_rch = "10010"
 	           else thr_data(19) when reg_rch = "10011"
 	           else thr_data(20) when reg_rch = "10100"
 	           else thr_data(21) when reg_rch = "10101"
 	           else thr_data(22) when reg_rch = "10110"
 	           else thr_data(23) when reg_rch = "10111"
 	           else thr_data(24) when reg_rch = "11000"
 	           else thr_data(25) when reg_rch = "11001"
 	           else thr_data(26) when reg_rch = "11010"
 	           else thr_data(27) when reg_rch = "11011"
 	           else thr_data(28) when reg_rch = "11100"
 	           else thr_data(29) when reg_rch = "11101"
 	           else thr_data(30) when reg_rch = "11110"
 	           else thr_data(31);
				  
	irb_dram_pattern <= dram_test_pattern(63 downto 56) 
	                  & dram_test_pattern(47 downto 40) 
	                  & dram_test_pattern(31 downto 24) 
	                  & dram_test_pattern(15 downto 8) when reg_rch(0) = '1'
	               else dram_test_pattern(55 downto 48) 
	                  & dram_test_pattern(39 downto 32) 
	                  & dram_test_pattern(23 downto 16) 
	                  & dram_test_pattern(7 downto 0);

	ireg_rdata <= "0000000000000000000000000000000" & run when reg_raddr = "00000"
--	         else "0000000000000000000000000000" & cw when reg_raddr = "00001"
				else "000000000000000000000000" & rb_hv_data when reg_raddr = "00010"
				else "00000000000000000000" & rb_thr_data when reg_raddr = "00011"
				else "00000000000000000000" & temp_data when reg_raddr = "00100"
	         else "0000000000000000000000000000" & drs_pll_locked when reg_raddr = "00101"
				else "0000000000000000000000000000000" & dram_ready when reg_raddr = "00110"
				else rb_dram_pattern when reg_raddr = "00111"
				else (others => '0');

	latch_temp <= latch_temp_reg;
	latch_pll_lock <= latch_pll_lock_reg;
	reg_rdata <= reg_rdata_reg;

end Behavioral;


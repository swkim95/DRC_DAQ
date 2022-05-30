library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity readout is port(
	signal usb_mid : in std_logic_vector(7 downto 0);
	signal usb_ra : in std_logic_vector(5 downto 0);
	signal mod_rdata : in std_logic_vector(31 downto 0);
	signal run : in std_logic;
	signal linked : in std_logic_vector(39 downto 0);
	signal mod_mid : in mod_mid_array;
	signal cw : in std_logic_vector(3 downto 0);
	signal run_number : in std_logic_vector(15 downto 0);
	signal ptrig_interval : in std_logic_vector(15 downto 0);
	signal trig_enable : in std_logic_vector(3 downto 0);
	signal thr : in std_logic_vector(10 downto 0);
	signal trig_dly : in std_logic_vector(3 downto 0);
	signal clk : in std_logic;
	signal usb_rdata : out std_logic_vector(31 downto 0)
); end readout;

architecture Behavioral of readout is

signal usb_rdata_reg : std_logic_vector(31 downto 0);
signal sel_mod : std_logic;
signal dusb_ra : std_logic_vector(5 downto 0);
signal mux_a : std_logic_vector(3 downto 0);
signal mux_b : std_logic_vector(1 downto 0);
signal ireg_p_a : std_logic_vector(31 downto 0);
signal reg_p_a : std_logic_vector(31 downto 0);
signal ireg_p_b : std_logic_vector(7 downto 0);
signal reg_p_b : std_logic_vector(7 downto 0);
signal ireg_p_c : std_logic_vector(15 downto 0);
signal reg_p_c : std_logic_vector(15 downto 0);
signal ireg_p_d : std_logic_vector(10 downto 0);
signal reg_p_d : std_logic_vector(10 downto 0);
signal ireg_tcb : std_logic_vector(31 downto 0);
signal reg_tcb : std_logic_vector(31 downto 0);
signal ipusb_rdata : std_logic_vector(31 downto 0);
signal pusb_rdata : std_logic_vector(31 downto 0);

attribute iob : string;
attribute iob of usb_rdata_reg : signal is "true";

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		sel_mod <= usb_mid(0) or usb_mid(1) or usb_mid(2) or usb_mid(3)
		        or usb_mid(4) or usb_mid(5) or usb_mid(6) or usb_mid(7);
				 
		dusb_ra <= usb_ra;
		mux_b <= dusb_ra(5 downto 4);

		reg_p_a <= ireg_p_a;
		reg_p_b <= ireg_p_b;
		reg_p_c <= ireg_p_c;
		reg_p_d <= ireg_p_d;

		reg_tcb <= ireg_tcb;

		pusb_rdata <= ipusb_rdata;
		usb_rdata_reg <= pusb_rdata;
		
	end if;
	end process;

	mux_a <= dusb_ra(3 downto 0);
	
	ireg_p_a <= "0000000000000000000000000000000" & run when mux_a = "0000"
	       else linked(31 downto 0) when mux_a = "0001"
			 else "000000000000000000000000" & linked(39 downto 32) when mux_a = "0010"
			 else "000000000000000000000000" & mod_mid(0) when mux_a = "0011"
			 else "000000000000000000000000" & mod_mid(1) when mux_a = "0100"
			 else "000000000000000000000000" & mod_mid(2) when mux_a = "0101"
			 else "000000000000000000000000" & mod_mid(3) when mux_a = "0110"
			 else "000000000000000000000000" & mod_mid(4) when mux_a = "0111"
			 else "000000000000000000000000" & mod_mid(5) when mux_a = "1000"
			 else "000000000000000000000000" & mod_mid(6) when mux_a = "1001"
			 else "000000000000000000000000" & mod_mid(7) when mux_a = "1010"
			 else "000000000000000000000000" & mod_mid(8) when mux_a = "1011"
			 else "000000000000000000000000" & mod_mid(9) when mux_a = "1100"
			 else "000000000000000000000000" & mod_mid(10) when mux_a = "1101"
			 else "000000000000000000000000" & mod_mid(11) when mux_a = "1110"
			 else "000000000000000000000000" & mod_mid(12);

	ireg_p_b <= mod_mid(13) when mux_a = "0000"
			 else mod_mid(14) when mux_a = "0001"
			 else mod_mid(15) when mux_a = "0010"
			 else mod_mid(16) when mux_a = "0011"
			 else mod_mid(17) when mux_a = "0100"
			 else mod_mid(18) when mux_a = "0101"
			 else mod_mid(19) when mux_a = "0110"
			 else mod_mid(20) when mux_a = "0111"
			 else mod_mid(21) when mux_a = "1000"
			 else mod_mid(22) when mux_a = "1001"
			 else mod_mid(23) when mux_a = "1010"
			 else mod_mid(24) when mux_a = "1011"
			 else mod_mid(25) when mux_a = "1100"
			 else mod_mid(26) when mux_a = "1101"
			 else mod_mid(27) when mux_a = "1110"
			 else mod_mid(28);

	ireg_p_c <= "00000000" & mod_mid(29) when mux_a = "0000"
			 else "00000000" & mod_mid(30) when mux_a = "0001"
			 else "00000000" & mod_mid(31) when mux_a = "0010"
			 else "00000000" & mod_mid(32) when mux_a = "0011"
			 else "00000000" & mod_mid(33) when mux_a = "0100"
			 else "00000000" & mod_mid(34) when mux_a = "0101"
			 else "00000000" & mod_mid(35) when mux_a = "0110"
			 else "00000000" & mod_mid(36) when mux_a = "0111"
			 else "00000000" & mod_mid(37) when mux_a = "1000"
			 else "00000000" & mod_mid(38) when mux_a = "1001"
			 else "00000000" & mod_mid(39) when mux_a = "1010"
			 else "000000000000" & cw when mux_a = "1011"
			 else run_number when mux_a = "1100"
			 else ptrig_interval when mux_a = "1110"
			 else "000000000000" & trig_enable when mux_a = "1111"
			 else (others => '0');
			 
	ireg_p_d <= thr when mux_a = "0000"
			 else "0000000" & trig_dly when mux_a = "0001"
			 else (others => '0');
	
	ireg_tcb <= reg_p_a when mux_b = "00"
	       else "000000000000000000000000" & reg_p_b when mux_b = "01"
	       else "0000000000000000" & reg_p_c when mux_b = "10"
			 else "000000000000000000000" & reg_p_d;

	ipusb_rdata <= mod_rdata when sel_mod = '1'
	          else reg_tcb;

	usb_rdata <= usb_rdata_reg;

end Behavioral;


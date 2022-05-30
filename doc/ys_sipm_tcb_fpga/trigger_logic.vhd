library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity trigger_logic is port(
	signal tpulse : in tpulse_array;
	signal thr : in std_logic_vector(10 downto 0);
	signal clk : in std_logic;
	signal strig : out std_logic
); end trigger_logic;

architecture Behavioral of trigger_logic is

type trig_sum_a_array is array(19 downto 0) of std_logic_vector(6 downto 0);
type trig_sum_b_array is array(9 downto 0) of std_logic_vector(7 downto 0);
type trig_sum_c_array is array(4 downto 0) of std_logic_vector(8 downto 0);
type trig_sum_d_array is array(1 downto 0) of std_logic_vector(9 downto 0);

signal sum_a : trig_sum_a_array;
signal sum_b : trig_sum_b_array;
signal sum_c : trig_sum_c_array;
signal sum_d : trig_sum_d_array;
signal sum_e : std_logic_vector(10 downto 0);
signal sum_all : std_logic_vector(10 downto 0);
signal cmp : std_logic;
signal dcmp : std_logic;
signal strig_reg : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		for i in 0 to 9 loop
			sum_b(i) <= ('0' & sum_a(2 * i)) + ('0' & sum_a(2 * i + 1));
		end loop;

		sum_all <= sum_e + ("00" & sum_c(4));
		
		if (sum_all >= thr) then
			cmp <= '1';
		else
			cmp <= '0';
		end if;
		dcmp <= cmp;
		
		strig_reg <= cmp and (not dcmp);

	end if;
	end process;

	myloop1 : for i in 0 to 19 generate
		sum_a(i) <= ('0' & tpulse(2 * i)) + ('0' & tpulse(2 * i + 1));
	end generate;

	myloop2 : for i in 0 to 4 generate
		sum_c(i) <= ('0' & sum_b(2 * i)) + ('0' & sum_b(2 * i + 1));
	end generate;

	sum_d(0) <= ('0' & sum_c(0)) + ('0' & sum_c(1));
	sum_d(1) <= ('0' & sum_c(2)) + ('0' & sum_c(3));

	sum_e <= ('0' & sum_d(0)) + ('0' & sum_d(1));
	
	strig <= strig_reg;

end Behavioral;


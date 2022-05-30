library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity drs_ctrl_init is port(
	signal drs_init : in std_logic;
	signal drs_read_done : in std_logic;
	signal clk : in std_logic;
	signal drs_init_a : out std_logic;
	signal drs_init_srclk : out std_logic
); end drs_ctrl_init;

architecture Behavioral of drs_ctrl_init is

signal drs_init_a_reg : std_logic;
signal drs_init_srclk_reg : std_logic;

signal cen : std_logic;
signal cnt : std_logic_vector(10 downto 0);
signal clr : std_logic;
signal dclr : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		if (clr = '1') then
			cen <= '0';
		elsif ((drs_init = '1') or (drs_read_done = '1')) then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(10) and cnt(9) and cnt(8) 
			and cnt(7) and cnt(6) and cnt(5) and cnt(4) 
			and cnt(3) and cnt(2) and cnt(1) and (not cnt(0));
		dclr <= clr;
		
		if (dclr = '1') then
			drs_init_a_reg <= '0';
		elsif ((drs_init = '1') or (drs_read_done = '1')) then
			drs_init_a_reg <= '1';
		end if;

		drs_init_srclk_reg <= cen and (not cnt(0));

	end if;
	end process;

	drs_init_a <= drs_init_a_reg;
	drs_init_srclk <= drs_init_srclk_reg;

end Behavioral;


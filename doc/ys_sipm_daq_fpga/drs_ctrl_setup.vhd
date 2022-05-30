library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity drs_ctrl_setup is port(
	signal drs_on : in std_logic;
	signal clk : in std_logic;
	signal drs_su_a : out std_logic_vector(2 downto 0);
	signal drs_su_srclk : out std_logic;
	signal drs_init : out std_logic
); end drs_ctrl_setup;

architecture Behavioral of drs_ctrl_setup is

signal drs_su_a_reg : std_logic_vector(2 downto 0);
signal drs_su_srclk_reg : std_logic;
signal drs_init_reg : std_logic;

signal ddrs_on : std_logic;
signal scen : std_logic;
signal cen : std_logic;
signal cnt : std_logic_vector(5 downto 0);
signal clr : std_logic;
signal idrs_su_a : std_logic_vector(1 downto 0);
signal idrs_su_srclk : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		ddrs_on <= drs_on;
		scen <= drs_on and (not ddrs_on);

		if (clr = '1') then
			cen <= '0';
		elsif (scen = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(5) and cnt(4) and (not cnt(3))
		   and (not cnt(2)) and (not cnt(1)) and cnt(0);
		
		drs_su_a_reg(0) <= idrs_su_a(0);
		drs_su_a_reg(1) <= idrs_su_a(1);
		drs_su_a_reg(2) <= cen;
		drs_su_srclk_reg <= idrs_su_srclk;
		drs_init_reg <= clr;
		
	end if;
	end process;

	lut6_drs_su_a0 : LUT6
	generic map(INIT => x"00000003FFFE0000")
	port map(
		I0 => cnt(0),
		I1 => cnt(1),
		I2 => cnt(2),
		I3 => cnt(3),
		I4 => cnt(4),
		I5 => cnt(5),
		O => idrs_su_a(0)
	);

	lut6_drs_su_a1 : LUT6
	generic map(INIT => x"0007FFFC00000000")
	port map(
		I0 => cnt(0),
		I1 => cnt(1),
		I2 => cnt(2),
		I3 => cnt(3),
		I4 => cnt(4),
		I5 => cnt(5),
		O => idrs_su_a(1)
	);

	lut6_drs_su_srclk : LUT6
	generic map(INIT => x"0002AAA95554AAAA")
	port map(
		I0 => cnt(0),
		I1 => cnt(1),
		I2 => cnt(2),
		I3 => cnt(3),
		I4 => cnt(4),
		I5 => cnt(5),
		O => idrs_su_srclk
	);

	drs_su_a <= drs_su_a_reg;
	drs_su_srclk <= drs_su_srclk_reg;
	drs_init <= drs_init_reg;

end Behavioral;


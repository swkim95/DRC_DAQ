library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity drs_ctrl_status is port(
	signal p_drs_pll_lock : in std_logic_vector(3 downto 0);
	signal latch_pll_lock : in std_logic;
	signal clk : in std_logic;
	signal drs_pll_locked : out std_logic_vector(3 downto 0)
); end drs_ctrl_status;

architecture Behavioral of drs_ctrl_status is

signal drs_pll_lock_in : std_logic_vector(3 downto 0);
signal drs_pll_locked_reg : std_logic_vector(3 downto 0);
signal drs_pll_lock : std_logic_vector(3 downto 0);

attribute iob : string;
attribute iob of drs_pll_lock : signal is "true";

begin

	myloop1 : for ch in 0 to 3 generate
		ibuf_drs_pll_lock : ibuf port map(i => p_drs_pll_lock(ch), o => drs_pll_lock_in(ch));
	end generate;

	process(clk) begin
	if (clk'event and clk = '1') then

		drs_pll_lock <= drs_pll_lock_in;
		
		if (latch_pll_lock = '1') then
			drs_pll_locked_reg <= drs_pll_lock;
		end if;
		
	end if;
	end process;

	drs_pll_locked <= drs_pll_locked_reg;

end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity trigger is port(
	signal p_disc : in std_logic_vector(31 downto 0);
--	signal cw : in std_logic_vector(3 downto 0);
	signal trig_armed : in std_logic;
	signal run : in std_logic;
--	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal trig_pattern : out std_logic_vector(31 downto 0);
	signal trig_nhit : out std_logic_vector(5 downto 0);
	signal local_trig : out std_logic
); end trigger;

architecture Behavioral of trigger is

component trig_pattern_capture port(
	signal trig_ch : in std_logic;
	signal clk : in std_logic;
	signal trig_pattern : out std_logic
); end component;

signal idisc : std_logic_vector(31 downto 0);
signal disc : std_logic_vector(31 downto 0);
signal ddisc : std_logic_vector(31 downto 0);
signal local_trig_reg : std_logic;
signal trig_ch : std_logic_vector(31 downto 0);

attribute iob : string;
attribute iob of disc : signal is "true";

begin

	myloop1 : for ch in 0 to 31 generate
		ibuf_disc : ibuf port map(i => p_disc(ch), o => idisc(ch));
	end generate;

	process(clk) begin
	if (clk'event and clk = '1') then

		disc <= idisc;
		ddisc <= disc;
		
		for ch in 0 to 31 loop
			trig_ch(ch) <= disc(ch) and (not ddisc(ch));
		end loop;

		local_trig_reg <= trig_armed and run and (trig_ch(0) or trig_ch(1) or trig_ch(2) or trig_ch(3)
		                                       or trig_ch(4) or trig_ch(5) or trig_ch(6) or trig_ch(7)
		                                       or trig_ch(8) or trig_ch(9) or trig_ch(10) or trig_ch(11)
		                                       or trig_ch(12) or trig_ch(13) or trig_ch(14) or trig_ch(15)
		                                       or trig_ch(16) or trig_ch(17) or trig_ch(18) or trig_ch(19)
		                                       or trig_ch(20) or trig_ch(21) or trig_ch(22) or trig_ch(23)
		                                       or trig_ch(24) or trig_ch(25) or trig_ch(26) or trig_ch(27)
		                                       or trig_ch(28) or trig_ch(29) or trig_ch(30) or trig_ch(31));

	end if;
	end process;
	
	myloop2 : for ch in 0 to 31 generate
		u1 : trig_pattern_capture port map(
			trig_ch => trig_ch(ch),
			clk => clk,
			trig_pattern => trig_pattern(ch)
		);
	end generate;

	trig_nhit <= "000001";
	local_trig <= local_trig_reg;

end Behavioral;


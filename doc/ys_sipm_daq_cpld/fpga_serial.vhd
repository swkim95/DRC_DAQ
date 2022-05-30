library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity fpga_serial is port(
	signal p_cpld_cs : in std_logic;
	signal p_cpld_sck : in std_logic;
	signal p_cpld_sdi : in std_logic;
	signal clk : in std_logic;
	signal p_dac_cs : out std_logic_vector(4 downto 0);
	signal p_dac_sck : out std_logic_vector(4 downto 0);
	signal p_dac_sdi : out std_logic_vector(4 downto 0);
	signal p_bias_cs : out std_logic_vector(3 downto 0);
	signal p_bias_sck : out std_logic_vector(3 downto 0);
	signal p_bias_sdi : out std_logic_vector(3 downto 0)
); end fpga_serial;

architecture Behavioral of fpga_serial is

signal icpld_cs : std_logic;
signal icpld_sck : std_logic;
signal icpld_sdi : std_logic;
signal cpld_cs : std_logic;
signal cpld_sck : std_logic;
signal cpld_sdi : std_logic;
signal dcpld_cs : std_logic;
signal dcpld_sck : std_logic;
signal d2cpld_sck : std_logic;
signal dcpld_sdi : std_logic;
signal set_mux : std_logic;
signal mux : std_logic_vector(3 downto 0);
signal dac_cs : std_logic_vector(4 downto 0);
signal dac_sck : std_logic_vector(4 downto 0);
signal dac_sdi : std_logic_vector(4 downto 0);
signal bias_cs : std_logic_vector(3 downto 0);
signal bias_sck : std_logic_vector(3 downto 0);
signal bias_sdi : std_logic_vector(3 downto 0);

begin

	ibuf_cpld_cs : ibuf port map(i => p_cpld_cs, o => icpld_cs);
	ibuf_cpld_sck : ibuf port map(i => p_cpld_sck, o => icpld_sck);
	ibuf_cpld_sdi : ibuf port map(i => p_cpld_sdi, o => icpld_sdi);

	process(clk) begin
	if (clk'event and clk = '1') then

		cpld_cs <= icpld_cs;
		cpld_sck <= icpld_sck;
		cpld_sdi <= icpld_sdi;
		
		dcpld_cs <= cpld_cs;
		dcpld_sck <= cpld_sck;
		dcpld_sdi <= cpld_sdi;
		
		d2cpld_sck <= dcpld_sck;
		set_mux <= dcpld_cs and d2cpld_sck and (not dcpld_sck);

		if (set_mux = '1') then
			mux <= mux(2 downto 0) & dcpld_sdi;
		end if;
		
		dac_cs(0) <= not((not dcpld_cs) and mux(3) and (not mux(2)) and (not mux(1)) and (not mux(0)));
		dac_cs(1) <= not((not dcpld_cs) and mux(3) and (not mux(2)) and (not mux(1)) and mux(0));
		dac_cs(2) <= not((not dcpld_cs) and mux(3) and (not mux(2)) and mux(1) and (not mux(0)));
		dac_cs(3) <= not((not dcpld_cs) and mux(3) and (not mux(2)) and mux(1) and mux(0));
		dac_cs(4) <= not((not dcpld_cs) and mux(3) and mux(2) and (not mux(1)) and (not mux(0)));

		dac_sck(0) <= not((not dcpld_cs) and dcpld_sck and mux(3) and (not mux(2)) and (not mux(1)) and (not mux(0)));
		dac_sck(1) <= not((not dcpld_cs) and dcpld_sck and mux(3) and (not mux(2)) and (not mux(1)) and mux(0));
		dac_sck(2) <= not((not dcpld_cs) and dcpld_sck and mux(3) and (not mux(2)) and mux(1) and (not mux(0)));
		dac_sck(3) <= not((not dcpld_cs) and dcpld_sck and mux(3) and (not mux(2)) and mux(1) and mux(0));
		dac_sck(4) <= not((not dcpld_cs) and dcpld_sck and mux(3) and mux(2) and (not mux(1)) and (not mux(0)));

		dac_sdi(0) <= (not dcpld_cs) and dcpld_sdi and mux(3) and (not mux(2)) and (not mux(1)) and (not mux(0));
		dac_sdi(1) <= (not dcpld_cs) and dcpld_sdi and mux(3) and (not mux(2)) and (not mux(1)) and mux(0);
		dac_sdi(2) <= (not dcpld_cs) and dcpld_sdi and mux(3) and (not mux(2)) and mux(1) and (not mux(0));
		dac_sdi(3) <= (not dcpld_cs) and dcpld_sdi and mux(3) and (not mux(2)) and mux(1) and mux(0);
		dac_sdi(4) <= (not dcpld_cs) and dcpld_sdi and mux(3) and mux(2) and (not mux(1)) and (not mux(0));

		bias_cs(0) <= not((not dcpld_cs) and (not mux(3)) and (not mux(2)) and (not mux(1)) and (not mux(0)));
		bias_cs(1) <= not((not dcpld_cs) and (not mux(3)) and (not mux(2)) and (not mux(1)) and mux(0));
		bias_cs(2) <= not((not dcpld_cs) and (not mux(3)) and (not mux(2)) and mux(1) and (not mux(0)));
		bias_cs(3) <= not((not dcpld_cs) and (not mux(3)) and (not mux(2)) and mux(1) and mux(0));

		bias_sck(0) <= (not dcpld_cs) and dcpld_sck and (not mux(3)) and (not mux(2)) and (not mux(1)) and (not mux(0));
		bias_sck(1) <= (not dcpld_cs) and dcpld_sck and (not mux(3)) and (not mux(2)) and (not mux(1)) and mux(0);
		bias_sck(2) <= (not dcpld_cs) and dcpld_sck and (not mux(3)) and (not mux(2)) and mux(1) and (not mux(0));
		bias_sck(3) <= (not dcpld_cs) and dcpld_sck and (not mux(3)) and (not mux(2)) and mux(1) and mux(0);

		bias_sdi(0) <= (not dcpld_cs) and dcpld_sdi and (not mux(3)) and (not mux(2)) and (not mux(1)) and (not mux(0));
		bias_sdi(1) <= (not dcpld_cs) and dcpld_sdi and (not mux(3)) and (not mux(2)) and (not mux(1)) and mux(0);
		bias_sdi(2) <= (not dcpld_cs) and dcpld_sdi and (not mux(3)) and (not mux(2)) and mux(1) and (not mux(0));
		bias_sdi(3) <= (not dcpld_cs) and dcpld_sdi and (not mux(3)) and (not mux(2)) and mux(1) and mux(0);

	end if;
	end process;

	myloop1 : for i in 0 to 4 generate
		obuf_dac_cs : obuf port map(i => dac_cs(i), o => p_dac_cs(i));
		obuf_dac_sck : obuf port map(i => dac_sck(i), o => p_dac_sck(i));
		obuf_dac_sdi : obuf port map(i => dac_sdi(i), o => p_dac_sdi(i));
	end generate;

	myloop2 : for i in 0 to 3 generate
		obuf_bias_cs : obuf port map(i => bias_cs(i), o => p_bias_cs(i));
		obuf_bias_sck : obuf port map(i => bias_sck(i), o => p_bias_sck(i));
		obuf_bias_sdi : obuf port map(i => bias_sdi(i), o => p_bias_sdi(i));
	end generate;

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity link_input_ch is port(
	signal adc_trigger : in std_logic;
	signal run : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal mod_mid : out std_logic_vector(7 downto 0);
	signal triged : out std_logic;
	signal mod_nhit : out std_logic_vector(5 downto 0);
	signal mod_rdat : out std_logic_vector(31 downto 0);
	signal response : out std_logic;
	signal linked : out std_logic
); end link_input_ch;

architecture Behavioral of link_input_ch is

component tcb_sync port(
	signal adc_trigger : in std_logic;
	signal linkerr : in std_logic;
	signal run : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal sidat : out std_logic;
	signal fcnt : out std_logic_vector(6 downto 0);
	signal linked : out std_logic
); end component;

signal sidat : std_logic;
signal fcnt : std_logic_vector(6 downto 0);
signal linked_reg : std_logic;

component tcb_deserializer port(
	signal sidat : in std_logic;
	signal fcnt : in std_logic_vector(6 downto 0);
	signal linked : in std_logic;
	signal clk : in std_logic;
	signal tcbin : out std_logic_vector(7 downto 0);
	signal linkerr : out std_logic
); end component;

signal tcbin : std_logic_vector(7 downto 0);
signal linkerr : std_logic;

component tcb_receiver port(
	signal sidat : in std_logic;
	signal tcbin : in std_logic_vector(7 downto 0);
	signal fcnt : in std_logic_vector(6 downto 0);
	signal linked : in std_logic;
	signal run : in std_logic;
	signal clk : in std_logic;
	signal mod_mid : out std_logic_vector(7 downto 0);
	signal triged : out std_logic;
	signal mod_nhit : out std_logic_vector(5 downto 0);
	signal mod_rdat : out std_logic_vector(31 downto 0);
	signal response : out std_logic
); end component;

begin

	u1 : tcb_sync port map(
		adc_trigger => adc_trigger,
		linkerr => linkerr,
		run => run,
		x2clk => x2clk,
		clk => clk,
		sidat => sidat,
		fcnt => fcnt,
		linked => linked_reg
	);
	
	u2 : tcb_deserializer port map(
		sidat => sidat,
		fcnt => fcnt,
		linked => linked_reg,
		clk => clk,
		tcbin => tcbin,
		linkerr => linkerr
	);
	
	u3 : tcb_receiver port map(
		sidat => sidat,
		tcbin => tcbin,
		fcnt => fcnt,
		linked => linked_reg,
		run => run,
		clk => clk,
		mod_mid => mod_mid,
		triged => triged,
		mod_nhit => mod_nhit,
		mod_rdat => mod_rdat,
		response => response
	);

	linked <= linked_reg;

end Behavioral;

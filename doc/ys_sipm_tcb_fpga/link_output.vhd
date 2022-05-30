library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity link_output is port(
	signal tcb_cdat : in std_logic_vector(7 downto 0);
	signal tcb_com : in std_logic;
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(47 downto 0);
	signal tcb_mid : in std_logic_vector(7 downto 0);
	signal tcb_addr : in std_logic_vector(13 downto 0);
	signal tcb_wdat : in std_logic_vector(31 downto 0);
	signal tcb_write : in std_logic;
	signal tcb_read : in std_logic;
	signal run_number : in std_logic_vector(15 downto 0);
	signal trig_type : in std_logic_vector(1 downto 0);
	signal tcb_trig : in std_logic;
	signal run : in std_logic;
	signal reset : in std_logic;
	signal clk : in std_logic;
	signal p_tcb_timerp : out std_logic_vector(39 downto 0);
	signal p_tcb_timern : out std_logic_vector(39 downto 0);
	signal p_tcb_triggerp : out std_logic_vector(39 downto 0);
	signal p_tcb_triggern : out std_logic_vector(39 downto 0)
); end link_output;

architecture Behavioral of link_output is

component link_output_timer port(
	signal tcb_cdat : in std_logic_vector(7 downto 0);
	signal tcb_com : in std_logic;
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(47 downto 0);
	signal clk : in std_logic;
	signal p_tcb_timerp : out std_logic_vector(39 downto 0);
	signal p_tcb_timern : out std_logic_vector(39 downto 0)
); end component;

component link_output_trigger port(
	signal tcb_mid : in std_logic_vector(7 downto 0);
	signal tcb_addr : in std_logic_vector(13 downto 0);
	signal tcb_wdat : in std_logic_vector(31 downto 0);
	signal tcb_write : in std_logic;
	signal tcb_read : in std_logic;
	signal run_number : in std_logic_vector(15 downto 0);
	signal trig_type : in std_logic_vector(1 downto 0);
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(47 downto 0);
	signal tcb_trig : in std_logic;
	signal run : in std_logic;
	signal reset : in std_logic;
	signal clk : in std_logic;
	signal p_tcb_triggerp : out std_logic_vector(39 downto 0);
	signal p_tcb_triggern : out std_logic_vector(39 downto 0)
); end component;

begin

	u1 : link_output_timer port map(
		tcb_cdat => tcb_cdat,
		tcb_com => tcb_com,
		tcb_ftime => tcb_ftime,
		tcb_ctime => tcb_ctime,
		clk => clk,
		p_tcb_timerp => p_tcb_timerp,
		p_tcb_timern => p_tcb_timern
	);

	u2 : link_output_trigger port map(
		tcb_mid => tcb_mid,
		tcb_addr => tcb_addr,
		tcb_wdat => tcb_wdat,
		tcb_write => tcb_write,
		tcb_read => tcb_read,
		run_number => run_number,
		trig_type => trig_type,
		tcb_ftime => tcb_ftime,
		tcb_ctime => tcb_ctime,
		tcb_trig => tcb_trig,
		run => run,
		reset => reset,
		clk => clk,
		p_tcb_triggerp => p_tcb_triggerp,
		p_tcb_triggern => p_tcb_triggern
	);

end Behavioral;


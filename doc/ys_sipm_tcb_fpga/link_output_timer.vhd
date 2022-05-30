library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity link_output_timer is port(
	signal tcb_cdat : in std_logic_vector(7 downto 0);
	signal tcb_com : in std_logic;
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(47 downto 0);
	signal clk : in std_logic;
	signal p_tcb_timerp : out std_logic_vector(39 downto 0);
	signal p_tcb_timern : out std_logic_vector(39 downto 0)
); end link_output_timer;

architecture Behavioral of link_output_timer is

component tcb_send_timer port(
	signal tcb_cdat : in std_logic_vector(7 downto 0);
	signal tcb_com : in std_logic;
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(47 downto 0);
	signal clk : in std_logic;
	signal send_com : out std_logic_vector(7 downto 0);
	signal send_data : out std_logic_vector(47 downto 0)
); end component;

signal send_com : std_logic_vector(7 downto 0);
signal send_data : std_logic_vector(47 downto 0);

component tcb_transmitter_timer port(
	signal send_com : in std_logic_vector(7 downto 0);
	signal send_data : in std_logic_vector(47 downto 0);
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal parout_timer : out std_logic_vector(9 downto 0)
); end component;

signal parout_timer : std_logic_vector(9 downto 0);

component tcb_serializer_timer port(
	signal parout_timer : in std_logic_vector(9 downto 0);
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal p_tcb_timerp : out std_logic_vector(39 downto 0);
	signal p_tcb_timern : out std_logic_vector(39 downto 0)
); end component;

begin

	u1 : tcb_send_timer port map(
		tcb_cdat => tcb_cdat,
		tcb_com => tcb_com,
		tcb_ftime => tcb_ftime,
		tcb_ctime => tcb_ctime,
		clk => clk,
		send_com => send_com,
		send_data => send_data
	);

	u2 : tcb_transmitter_timer port map(
		send_com => send_com,
		send_data => send_data,
		tcb_ftime => tcb_ftime,
		clk => clk,
		parout_timer => parout_timer
	);

	u3 : tcb_serializer_timer port map(
		parout_timer => parout_timer,
		tcb_ftime => tcb_ftime,
		clk => clk,
		p_tcb_timerp => p_tcb_timerp,
		p_tcb_timern => p_tcb_timern
	);

end Behavioral;


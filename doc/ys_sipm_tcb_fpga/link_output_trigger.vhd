library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity link_output_trigger is port(
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
); end link_output_trigger;

architecture Behavioral of link_output_trigger is

component tcb_send_trigger port(
	signal tcb_mid : in std_logic_vector(7 downto 0);
	signal tcb_addr : in std_logic_vector(13 downto 0);
	signal tcb_wdat : in std_logic_vector(31 downto 0);
	signal tcb_write : in std_logic;
	signal tcb_read : in std_logic;
	signal trig_type : in std_logic_vector(1 downto 0);
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal tcb_ctime : in std_logic_vector(47 downto 0);
	signal run_number : in std_logic_vector(15 downto 0);
	signal tcb_trig : in std_logic;
	signal run : in std_logic;
	signal reset : in std_logic;
	signal clk : in std_logic;
	signal send_mid : out std_logic_vector(7 downto 0);
	signal send_addr : out std_logic_vector(15 downto 0);
	signal send_data : out std_logic_vector(31 downto 0);
	signal trgdat : out std_logic
); end component;

signal send_mid : std_logic_vector(7 downto 0);
signal send_addr : std_logic_vector(15 downto 0);
signal send_data : std_logic_vector(31 downto 0);
signal trgdat : std_logic;

component tcb_transmitter_trigger port(
	signal send_mid : in std_logic_vector(7 downto 0);
	signal send_addr : in std_logic_vector(15 downto 0);
	signal send_data : in std_logic_vector(31 downto 0);
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal clk : in std_logic;
	signal parout_trg : out std_logic_vector(9 downto 0)
); end component;

signal parout_trg : std_logic_vector(9 downto 0);

component tcb_serializer_trigger port(
	signal parout_trg : in std_logic_vector(9 downto 0);
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal trgdat : in std_logic;
	signal run : in std_logic;
	signal clk : in std_logic;
	signal p_tcb_triggerp : out std_logic_vector(39 downto 0);
	signal p_tcb_triggern : out std_logic_vector(39 downto 0)
); end component;

begin

	u1 : tcb_send_trigger port map(
		tcb_mid => tcb_mid,
		tcb_addr => tcb_addr,
		tcb_wdat => tcb_wdat,
		tcb_write => tcb_write,
		tcb_read => tcb_read,
		trig_type => trig_type,
		tcb_ftime => tcb_ftime,
		tcb_ctime => tcb_ctime,
		run_number => run_number,
		tcb_trig => tcb_trig,
		run => run,
		reset => reset,
		clk => clk,
		send_mid => send_mid,
		send_addr => send_addr,
		send_data => send_data,
		trgdat => trgdat
	);

	u2 : tcb_transmitter_trigger port map(
		send_mid => send_mid,
		send_addr => send_addr,
		send_data => send_data,
		tcb_ftime => tcb_ftime,
		clk => clk,
		parout_trg => parout_trg
	);

	u3 : tcb_serializer_trigger port map(
		parout_trg => parout_trg,
		tcb_ftime => tcb_ftime,
		trgdat => trgdat,
		run => run,
		clk => clk,
		p_tcb_triggerp => p_tcb_triggerp,
		p_tcb_triggern => p_tcb_triggern
	);

end Behavioral;


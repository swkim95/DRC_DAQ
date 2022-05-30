library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity usb_interface is port(
	signal p_usb_d : inout std_logic_vector(31 downto 0);
	signal p_usb_rflag : in std_logic_vector(1 downto 0);
	signal p_usb_wflag : in std_logic;
	signal p_usb_on : in std_logic;
	signal usb_rdata : in std_logic_vector(31 downto 0);
	signal clk : in std_logic;
	signal usb_mid : out std_logic_vector(7 downto 0);
	signal usb_addr : out std_logic_vector(13 downto 0);
	signal usb_wdata : out std_logic_vector(31 downto 0);
	signal usb_write : out std_logic;
	signal usb_read : out std_logic;
	signal usb_ra : out std_logic_vector(5 downto 0);
	signal p_usb_a : out std_logic_vector(1 downto 0);
	signal p_usb_cs : out std_logic;
	signal p_usb_wr : out std_logic;
	signal p_usb_oe : out std_logic;
	signal p_usb_rd : out std_logic;
	signal p_usb_pktend : out std_logic
); end usb_interface;

architecture Behavioral of usb_interface is

component usb_control is port(
	signal p_usb_rflag : in std_logic_vector(1 downto 0);
	signal p_usb_wflag : in std_logic;
	signal p_usb_on : in std_logic;
	signal mod_wait : in std_logic;
	signal usb_bufn : in std_logic;
	signal usb_clrbn : in std_logic;
	signal usb_eudmp : in std_logic;
	signal usb_rend : in std_logic;
	signal clk : in std_logic;
	signal usb_sucom : out std_logic;
	signal usb_sudmp : out std_logic;
	signal p_usb_a : out std_logic_vector(1 downto 0)
); end component;

signal usb_sucom : std_logic;
signal usb_sudmp : std_logic;

component read_ep6 port(
	signal usb_icd : in std_logic_vector(31 downto 0);
	signal usb_sucom : in std_logic;
	signal clk : in std_logic;
	signal usb_mid : out std_logic_vector(7 downto 0);
	signal usb_addr : out std_logic_vector(13 downto 0);
	signal usb_wdata : out std_logic_vector(31 downto 0);
	signal usb_write : out std_logic;
	signal usb_read : out std_logic;
	signal usb_raddr : out std_logic_vector(5 downto 0);
	signal usb_rucnt : out std_logic_vector(29 downto 0);
	signal usb_clrbn : out std_logic;
	signal mod_wait : out std_logic;
	signal p_usb_cs : out std_logic;
	signal p_usb_oe : out std_logic;
	signal p_usb_rd : out std_logic
); end component;

signal usb_raddr : std_logic_vector(5 downto 0);
signal usb_rucnt : std_logic_vector(29 downto 0);
signal usb_clrbn : std_logic;
signal mod_wait : std_logic;

component write_ep2 port(
	signal p_usb_d : inout std_logic_vector(31 downto 0);
	signal usb_rdata : in std_logic_vector(31 downto 0);
	signal usb_raddr : in std_logic_vector(5 downto 0);
	signal usb_rucnt : in std_logic_vector(29 downto 0);
	signal usb_sucom : in std_logic;
	signal usb_sudmp : in std_logic;
	signal clk : in std_logic;
	signal usb_icd : out std_logic_vector(31 downto 0);
	signal usb_ra : out std_logic_vector(5 downto 0);
	signal usb_bufn : out std_logic;
	signal usb_eudmp : out std_logic;
	signal usb_rend : out std_logic;
	signal p_usb_wr : out std_logic;
	signal p_usb_pktend : out std_logic
); end component;

signal usb_icd : std_logic_vector(31 downto 0);
signal usb_bufn : std_logic;
signal usb_eudmp : std_logic;
signal usb_rend : std_logic;

begin

	u1 : usb_control port map(
		p_usb_rflag => p_usb_rflag,
		p_usb_wflag => p_usb_wflag,
		p_usb_on => p_usb_on,
		mod_wait => mod_wait,
		usb_bufn => usb_bufn,
		usb_clrbn => usb_clrbn,
		usb_eudmp => usb_eudmp,
		usb_rend => usb_rend,
		clk => clk,
		usb_sucom => usb_sucom,
		usb_sudmp => usb_sudmp,
		p_usb_a => p_usb_a
	);

	u2 : read_ep6 port map(
		usb_icd => usb_icd,
		usb_sucom => usb_sucom,
		clk => clk,
		usb_mid => usb_mid,
		usb_addr => usb_addr,
		usb_wdata => usb_wdata,
		usb_write => usb_write,
		usb_read => usb_read,
		usb_raddr => usb_raddr,
		usb_rucnt => usb_rucnt,
		usb_clrbn => usb_clrbn,
		mod_wait => mod_wait,
		p_usb_cs => p_usb_cs,
		p_usb_oe => p_usb_oe,
		p_usb_rd => p_usb_rd
	);
	
	u3 : write_ep2 port map(
		p_usb_d => p_usb_d,
		usb_rdata => usb_rdata,
		usb_raddr => usb_raddr,
		usb_rucnt => usb_rucnt,
		usb_sucom => usb_sucom,
		usb_sudmp => usb_sudmp,
		clk => clk,
		usb_icd => usb_icd,
		usb_ra => usb_ra,
		usb_bufn => usb_bufn,
		usb_eudmp => usb_eudmp,
		usb_rend => usb_rend,
		p_usb_wr => p_usb_wr,
		p_usb_pktend => p_usb_pktend
	);

end Behavioral;


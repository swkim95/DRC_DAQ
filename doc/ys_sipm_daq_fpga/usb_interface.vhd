library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity usb_interface is port(
	signal p_usb_d : inout std_logic_vector(31 downto 0);
	signal p_usb_rflag : in std_logic_vector(1 downto 0);
	signal p_usb_wflag : in std_logic;
	signal p_usb_on : in std_logic;
	signal data_fifo_empty : in std_logic;
	signal data_fifo_rdata : in std_logic_vector(31 downto 0);
	signal data_size : in std_logic_vector(12 downto 0);
	signal reset : in std_logic;
	signal clk : in std_logic;
	signal data_fifo_raddr : out std_logic_vector(12 downto 0);
	signal sub_data_fifo_cnt : out std_logic;
	signal latch_data_size : out std_logic;
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
	signal usb_rmux : in std_logic;
	signal data_fifo_empty : in std_logic;
	signal usb_bufn : in std_logic;
	signal usb_clrbn : in std_logic;
	signal usb_eudmp : in std_logic;
	signal usb_rend : in std_logic;
	signal clk : in std_logic;
	signal usb_sucom : out std_logic;
	signal usb_sudmp : out std_logic;
	signal usb_reset : out std_logic;
	signal p_usb_a : out std_logic_vector(1 downto 0)
); end component;

signal usb_sucom : std_logic;
signal usb_sudmp : std_logic;
signal usb_reset : std_logic;

component read_ep6 port(
	signal usb_icd : in std_logic_vector(31 downto 0);
	signal usb_sucom : in std_logic;
	signal clk : in std_logic;
	signal usb_addr : out std_logic_vector(12 downto 0);
	signal usb_rucnt : out std_logic_vector(29 downto 0);
	signal latch_data_size : out std_logic;
	signal usb_clrbn : out std_logic;
	signal p_usb_cs : out std_logic;
	signal p_usb_oe : out std_logic;
	signal p_usb_rd : out std_logic
); end component;

signal usb_addr : std_logic_vector(12 downto 0);
signal usb_rucnt : std_logic_vector(29 downto 0);
signal usb_clrbn : std_logic;

component write_ep2 port(
	signal p_usb_d : inout std_logic_vector(31 downto 0);
	signal usb_ocd : in std_logic_vector(31 downto 0);
	signal usb_addr : in std_logic_vector(12 downto 0);
	signal usb_rucnt : in std_logic_vector(29 downto 0);
	signal usb_sucom : in std_logic;
	signal usb_sudmp : in std_logic;
	signal reset : in std_logic;
	signal usb_reset : in std_logic;
	signal clk : in std_logic;
	signal usb_icd : out std_logic_vector(31 downto 0);
	signal data_fifo_raddr : out std_logic_vector(12 downto 0);
	signal usb_rmux : out std_logic;
	signal usb_bufn : out std_logic;
	signal usb_eudmp : out std_logic;
	signal usb_rend : out std_logic;
	signal sub_data_fifo_cnt : out std_logic;
	signal p_usb_wr : out std_logic;
	signal p_usb_pktend : out std_logic
); end component;

signal usb_icd : std_logic_vector(31 downto 0);
signal usb_rmux : std_logic;
signal usb_bufn : std_logic;
signal usb_eudmp : std_logic;
signal usb_rend : std_logic;

component usb_data_readout port(
	signal data_fifo_rdata : in std_logic_vector(31 downto 0);
	signal data_size : in std_logic_vector(12 downto 0);
	signal usb_rmux : in std_logic;
	signal clk : in std_logic;
	signal usb_ocd : out std_logic_vector(31 downto 0)
); end component;

signal usb_ocd : std_logic_vector(31 downto 0);

begin

	u1 : usb_control port map(
		p_usb_rflag => p_usb_rflag,
		p_usb_wflag => p_usb_wflag,
		p_usb_on => p_usb_on,
		usb_rmux => usb_rmux,
		data_fifo_empty => data_fifo_empty,
		usb_bufn => usb_bufn,
		usb_clrbn => usb_clrbn,
		usb_eudmp => usb_eudmp,
		usb_rend => usb_rend,
		clk => clk,
		usb_sucom => usb_sucom,
		usb_sudmp => usb_sudmp,
		usb_reset => usb_reset,
		p_usb_a => p_usb_a
	);

	u2 : read_ep6 port map(
		usb_icd => usb_icd,
		usb_sucom => usb_sucom,
		clk => clk,
		usb_addr => usb_addr,
		usb_rucnt => usb_rucnt,
		latch_data_size => latch_data_size,
		usb_clrbn => usb_clrbn,
		p_usb_cs => p_usb_cs,
		p_usb_oe => p_usb_oe,
		p_usb_rd => p_usb_rd
	);

	u3 : write_ep2 port map(
		p_usb_d => p_usb_d,
		usb_ocd => usb_ocd,
		usb_addr => usb_addr,
		usb_rucnt => usb_rucnt,
		usb_sucom => usb_sucom,
		usb_sudmp => usb_sudmp,
		reset => reset,
		usb_reset => usb_reset,
		clk => clk,
		usb_icd => usb_icd,
		data_fifo_raddr => data_fifo_raddr,
		usb_rmux => usb_rmux,
		usb_bufn => usb_bufn,
		usb_eudmp => usb_eudmp,
		usb_rend => usb_rend,
		sub_data_fifo_cnt => sub_data_fifo_cnt,
		p_usb_wr => p_usb_wr,
		p_usb_pktend => p_usb_pktend
	);

	u4 : usb_data_readout port map(
		data_fifo_rdata => data_fifo_rdata,
		data_size => data_size,
		usb_rmux => usb_rmux,
		clk => clk,
		usb_ocd => usb_ocd
	);

end Behavioral;


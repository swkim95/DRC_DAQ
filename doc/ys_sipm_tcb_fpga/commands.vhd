library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity commands is port(
	signal usb_mid : in std_logic_vector(7 downto 0);
	signal usb_addr : in std_logic_vector(13 downto 0);
	signal usb_wdata : in std_logic_vector(31 downto 0);
	signal usb_write : in std_logic;
	signal usb_read : in std_logic;
	signal clk : in std_logic;
	signal tcb_cdat : out std_logic_vector(7 downto 0);
	signal tcb_com : out std_logic;
	signal tcb_mid : out std_logic_vector(7 downto 0);
	signal tcb_addr : out std_logic_vector(13 downto 0);
	signal tcb_wdat : out std_logic_vector(31 downto 0);
	signal tcb_write : out std_logic;
	signal tcb_read : out std_logic;
	signal reset_timer : out std_logic;
	signal reset : out std_logic;
	signal run : out std_logic;
	signal cw : out std_logic_vector(3 downto 0);
	signal run_number : out std_logic_vector(15 downto 0);
	signal rtrig : out std_logic;
	signal ptrig_interval : out std_logic_vector(15 downto 0);
	signal clr_ptrig : out std_logic;
	signal trig_enable : out std_logic_vector(3 downto 0);
	signal thr : out std_logic_vector(10 downto 0);
	signal trig_dly : out std_logic_vector(3 downto 0)
); end commands;

architecture Behavioral of commands is

signal tcb_cdat_reg : std_logic_vector(7 downto 0);
signal tcb_com_reg : std_logic;
signal tcb_mid_reg : std_logic_vector(7 downto 0);
signal tcb_addr_reg : std_logic_vector(13 downto 0);
signal tcb_wdat_reg : std_logic_vector(31 downto 0);
signal tcb_write_reg : std_logic;
signal tcb_read_reg : std_logic;
signal reset_timer_reg : std_logic;
signal reset_reg : std_logic;
signal run_reg : std_logic := '0';
signal cw_reg : std_logic_vector(3 downto 0) := "0011";
signal run_number_reg : std_logic_vector(15 downto 0);
signal rtrig_reg : std_logic;
signal ptrig_interval_reg : std_logic_vector(15 downto 0) := (others => '0');
signal clr_ptrig_reg : std_logic;
signal trig_enable_reg : std_logic_vector(3 downto 0) := "1111";
signal thr_reg : std_logic_vector(10 downto 0) := "00000000001";
signal trig_dly_reg : std_logic_vector(3 downto 0) := "0000";

signal sel_mod : std_logic;
signal sel_tcb : std_logic;
signal en_mod : std_logic; 
signal en_mod_wr : std_logic; 
signal en_mod_rd : std_logic; 
signal addr_reset : std_logic;
signal addr_cw : std_logic;
signal addr_run_number : std_logic;
signal addr_rtrig : std_logic;
signal addr_ptrig_interval : std_logic;
signal addr_trig_enable : std_logic;
signal addr_thr : std_logic;
signal addr_trig_dly : std_logic;

signal wen_cw : std_logic;
signal wen_run_number : std_logic;
signal wen_ptrig_interval : std_logic;
signal wen_trig_enable : std_logic;
signal wen_thr : std_logic;
signal wen_trig_dly : std_logic;

signal start : std_logic;
signal stop : std_logic;

begin

	process (clk) begin
	if (clk'event and clk = '1') then

		sel_mod <= usb_mid(0) or usb_mid(1) or usb_mid(2) or usb_mid(3)
		        or usb_mid(4) or usb_mid(5) or usb_mid(6) or usb_mid(7);
				 
		sel_tcb <= (not usb_mid(0)) and (not usb_mid(1)) and (not usb_mid(2)) and (not usb_mid(3))
		       and (not usb_mid(4)) and (not usb_mid(5)) and (not usb_mid(6)) and (not usb_mid(7));

		en_mod <= sel_mod and (usb_write or usb_read);
		en_mod_wr <= sel_mod and usb_write;
		en_mod_rd <= sel_mod and usb_read;

		tcb_write_reg <= en_mod_wr;
		tcb_read_reg <= en_mod_rd;
		
		if (en_mod = '1') then
			tcb_mid_reg <= usb_mid;
			tcb_addr_reg <= usb_addr;
		end if;
		
		if (en_mod_wr = '1') then
			tcb_wdat_reg <= usb_wdata;
		end if;
		
		addr_reset <= (not usb_addr(5)) and (not usb_addr(4)) and (not usb_addr(3))
		          and (not usb_addr(2)) and (not usb_addr(1)) and (not usb_addr(0));

		addr_cw <= usb_addr(5) and (not usb_addr(4)) and usb_addr(3)
		       and (not usb_addr(2)) and usb_addr(1) and usb_addr(0);

		addr_run_number <= usb_addr(5) and (not usb_addr(4)) and usb_addr(3)
		               and usb_addr(2) and (not usb_addr(1)) and (not usb_addr(0));

		addr_rtrig <= usb_addr(5) and (not usb_addr(4)) and usb_addr(3)
		          and usb_addr(2) and (not usb_addr(1)) and usb_addr(0);

		addr_ptrig_interval <= usb_addr(5) and (not usb_addr(4)) and usb_addr(3)
		                   and usb_addr(2) and usb_addr(1) and (not usb_addr(0));

		addr_trig_enable <= usb_addr(5) and (not usb_addr(4)) and usb_addr(3)
		                and usb_addr(2) and usb_addr(1) and usb_addr(0);

		addr_thr <= usb_addr(5) and usb_addr(4) and (not usb_addr(3))
		        and (not usb_addr(2)) and (not usb_addr(1)) and (not usb_addr(0));

		addr_trig_dly <= usb_addr(5) and usb_addr(4) and (not usb_addr(3))
		             and (not usb_addr(2)) and (not usb_addr(1)) and usb_addr(0);

		for i in 0 to 6 loop
			tcb_cdat_reg(i) <= sel_tcb and addr_reset and usb_wdata(i);
		end loop;
		tcb_cdat_reg(7) <= sel_tcb and addr_reset;
		tcb_com_reg <= usb_write and sel_tcb and addr_reset;

		reset_timer_reg <= usb_write and sel_tcb and addr_reset and usb_wdata(0);
		reset_reg <= usb_write and sel_tcb and addr_reset and usb_wdata(1);
		start <= usb_write and sel_tcb and addr_reset and usb_wdata(2);
		stop <= usb_write and sel_tcb and addr_reset and usb_wdata(3);
		wen_cw <= usb_write and sel_tcb and addr_cw;
		wen_run_number <= usb_write and sel_tcb and addr_run_number;
		rtrig_reg <= usb_write and sel_tcb and addr_rtrig;
		wen_ptrig_interval <= usb_write and sel_tcb and addr_ptrig_interval;
		wen_trig_enable <= usb_write and sel_tcb and addr_trig_enable;
		wen_thr <= usb_write and sel_tcb and addr_thr;
		wen_trig_dly <= usb_write and sel_tcb and addr_trig_dly;

		if (stop = '1') then
			run_reg <= '0';
		elsif (start = '1') then
			run_reg <= '1';
		end if;

		if (wen_cw = '1') then
			cw_reg <= usb_wdata(3 downto 0);
		end if;
		
		if (wen_run_number = '1') then
			run_number_reg <= usb_wdata(15 downto 0);
		end if;
		
		if (wen_ptrig_interval = '1') then
			ptrig_interval_reg <= usb_wdata(15 downto 0);
		end if;
		clr_ptrig_reg <= wen_ptrig_interval or reset_timer_reg;

		if (wen_trig_enable = '1') then
			trig_enable_reg <= usb_wdata(3 downto 0);
		end if;
		
		if (wen_thr = '1') then
			thr_reg <= usb_wdata(10 downto 0);
		end if;

		if (wen_trig_dly = '1') then
			trig_dly_reg <= usb_wdata(3 downto 0);
		end if;

	end if;
	end process;	

	tcb_cdat <= tcb_cdat_reg;
	tcb_com <= tcb_com_reg;
	tcb_mid <= tcb_mid_reg;
	tcb_addr <= tcb_addr_reg;
	tcb_wdat <= tcb_wdat_reg;
	tcb_write <= tcb_write_reg;
	tcb_read <= tcb_read_reg;
	reset_timer <= reset_timer_reg;
	reset <= reset_reg;
	run <= run_reg;
	cw <= cw_reg;
	run_number <= run_number_reg;
	rtrig <= rtrig_reg;
	ptrig_interval <= ptrig_interval_reg;
	clr_ptrig <= clr_ptrig_reg;
	trig_enable <= trig_enable_reg;
	thr <= thr_reg;
	trig_dly <= trig_dly_reg;

end Behavioral;



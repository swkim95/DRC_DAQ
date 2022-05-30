library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity trigger_send is port(
	signal trig_enable : in std_logic_vector(3 downto 0);
	signal trig_dly : in std_logic_vector(3 downto 0);
	signal strig : in std_logic;
	signal etrig : in std_logic;
	signal ptrig : in std_logic;
	signal rtrig : in std_logic;
	signal run : in std_logic;
	signal clk : in std_logic;
	signal trig_type : out std_logic_vector(1 downto 0);
	signal tcb_trig : out std_logic
); end trigger_send;

architecture Behavioral of trigger_send is

signal trig_type_reg : std_logic_vector(1 downto 0);
signal tcb_trig_reg : std_logic;
signal dstrig : std_logic;
signal detrig : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		trig_type_reg(0) <= ptrig or detrig;
		trig_type_reg(1) <= rtrig or detrig;

		tcb_trig_reg <= ((dstrig and trig_enable(0)) 
		              or (ptrig and trig_enable(1)) 
						  or (rtrig and trig_enable(2)) 
						  or (detrig and trig_enable(3))) and run;

	end if;
	end process;
	
	srl16e_dstrig : srl16e
	generic map (init => X"0000")
	port map (
		d => strig,
		a3 => trig_dly(3),
		a2 => trig_dly(2),
		a1 => trig_dly(1),
		a0 => trig_dly(0),
		ce => '1',
		clk => clk,
		q => dstrig
	);
	
	srl16e_detrig : srl16e
	generic map (init => X"0000")
	port map (
		d => etrig,
		a3 => trig_dly(3),
		a2 => trig_dly(2),
		a1 => trig_dly(1),
		a0 => trig_dly(0),
		ce => '1',
		clk => clk,
		q => detrig
	);

	trig_type <= trig_type_reg;
	tcb_trig <= tcb_trig_reg;

end Behavioral;


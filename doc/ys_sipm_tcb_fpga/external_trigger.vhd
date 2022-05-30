library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity external_trigger is port(
	signal p_ext_trigger_in_nim : in std_logic;
	signal p_ext_trigger_in_ttl : in std_logic;
	signal cw : in std_logic_vector(3 downto 0);
	signal tcb_trig : in std_logic;
	signal clk : in std_logic;
	signal etrig : out std_logic;
	signal p_ext_trigger_out : out std_logic
); end external_trigger;

architecture Behavioral of external_trigger is

signal etrig_reg : std_logic;
signal ext_trigger_out : std_logic;

signal iext_trigger_in_nim : std_logic;
signal iext_trigger_in_ttl : std_logic;
signal ext_trigger_in_nim : std_logic;
signal ext_trigger_in_ttl : std_logic;
signal dext_trigger_in_nim : std_logic;
signal dext_trigger_in_ttl : std_logic;
signal d2ext_trigger_in_nim : std_logic;
signal d2ext_trigger_in_ttl : std_logic;

signal cen : std_logic := '0';
signal cnt : std_logic_vector(3 downto 0);
signal clr : std_logic;

attribute iob : string;
attribute iob of ext_trigger_in_nim : signal is "true";
attribute iob of ext_trigger_in_ttl : signal is "true";
attribute iob of ext_trigger_out : signal is "true";

begin

	ibuf_ext_trigger_in_nim : ibuf port map(i => p_ext_trigger_in_nim, o => iext_trigger_in_nim);
	ibuf_ext_trigger_in_ttl : ibuf port map(i => p_ext_trigger_in_ttl, o => iext_trigger_in_ttl);

	process(clk) begin
	if (clk'event and clk = '1') then
	
		ext_trigger_in_nim <= iext_trigger_in_nim;
		dext_trigger_in_nim <= ext_trigger_in_nim;
		d2ext_trigger_in_nim <= dext_trigger_in_nim;

		ext_trigger_in_ttl <= iext_trigger_in_ttl;
		dext_trigger_in_ttl <= ext_trigger_in_ttl;
		d2ext_trigger_in_ttl <= dext_trigger_in_ttl;

		etrig_reg <= ((not dext_trigger_in_nim) and d2ext_trigger_in_nim) 
		           or (dext_trigger_in_ttl and (not d2ext_trigger_in_ttl));
		
		if (clr = '1') then
			cen <= '0';
		elsif (tcb_trig = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		if (cnt = cw) then
			clr <= cen;
		else
			clr <= '0';
		end if;
		
		ext_trigger_out <= not cen;
		
	end if;
	end process;
	
	etrig <= etrig_reg;

	obuf_ext_trigger_out : obuf port map(i => ext_trigger_out, o => p_ext_trigger_out);

end Behavioral;


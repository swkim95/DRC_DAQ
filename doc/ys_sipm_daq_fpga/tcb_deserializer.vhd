library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity tcb_deserializer is port(
	signal sidat : in std_logic_vector(1 downto 0);
	signal fcnt : in std_logic_vector(6 downto 0);
	signal linkok : in std_logic;
	signal clk : in std_logic;
	signal tcbin_timer : out std_logic_vector(7 downto 0);
	signal tcbin_trig : out std_logic_vector(7 downto 0);
	signal linkerr : out std_logic
); end tcb_deserializer;

architecture Behavioral of tcb_deserializer is

component decoder_10b8b port(
	signal pardat : in std_logic_vector(9 downto 0);
	signal linkok : in std_logic;
	signal clk : in std_logic;
	signal sdin : out std_logic_vector(7 downto 0);
	signal charisk : out std_logic;
	signal dispplus : out std_logic;
	signal dispminus : out std_logic;
	signal notintable : out std_logic
); end component;

type pardat_array is array(1 downto 0) of std_logic_vector(9 downto 0);

signal tcbin_timer_reg : std_logic_vector(7 downto 0);
signal tcbin_trig_reg : std_logic_vector(7 downto 0);
signal linkerr_reg : std_logic;

signal pardat_timer : std_logic_vector(9 downto 0);
signal pardat_trig : std_logic_vector(9 downto 0);
signal igetdat : std_logic;
signal getdat : std_logic;
signal chkerr : std_logic;
signal selk : std_logic;
signal sdin_timer : std_logic_vector(7 downto 0);
signal sdin_trig : std_logic_vector(7 downto 0);
signal charisk : std_logic;
signal dispplus : std_logic;
signal dispminus : std_logic;
signal notintable : std_logic;
signal pcharisk : std_logic;
signal pdispplus : std_logic := '0';
signal pdispminus : std_logic := '0';
signal pnotintable : std_logic := '0';
signal olddispp : std_logic := '0';
signal olddispm : std_logic := '0';
signal deterr : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		if (linkok = '1') then
			pardat_timer <= sidat(0) & pardat_timer(9 downto 1);
			pardat_trig <= sidat(1) & pardat_trig(9 downto 1);
		end if;

		getdat <= igetdat and (not fcnt(0));
		
		if (linkok = '0') then
			tcbin_timer_reg <= (others => '0');
			tcbin_trig_reg <= (others => '0');
			pcharisk <= '0';
			pdispplus <= '0';
			pdispminus <= '0';
			pnotintable <= '0';
			olddispp <= '0';
			olddispm <= '0';
		elsif (getdat = '1') then
			tcbin_timer_reg <= sdin_timer;
			tcbin_trig_reg <= sdin_trig;
			pcharisk <= charisk;
			pdispplus <= dispplus;
			pdispminus <= dispminus;
			pnotintable <= notintable;
			olddispp <= pdispplus;
			olddispm <= pdispminus;
		end if;

		chkerr <= getdat;
		
		selk <= (not fcnt(6)) and (not fcnt(5)) and (not fcnt(4));
		
		if (linkok = '0') then
			linkerr_reg <= '0';
		elsif (chkerr = '1') then
			linkerr_reg <= pnotintable or (selk and (not pcharisk)) or ((not selk) and pcharisk)
						   or (olddispp and pdispplus) or (olddispm and pdispminus);
		end if;
		
	end if;
	end process;

	u1 : decoder_10b8b port map(
		pardat => pardat_timer,
		linkok => linkok,
		clk => clk,
		sdin => sdin_timer,
		charisk => charisk,
		dispplus => dispplus,
		dispminus => dispminus,
		notintable => notintable
	);

	u2 : decoder_10b8b port map(
		pardat => pardat_trig,
		linkok => linkok,
		clk => clk,
		sdin => sdin_trig,
		charisk => open,
		dispplus => open,
		dispminus => open,
		notintable => open
	);

	lut6_getdat : LUT6
	generic map(INIT => X"0000010842108420")
	port map(
		I5 => fcnt(6),
		I4 => fcnt(5),
		I3 => fcnt(4),
		I2 => fcnt(3),
		I1 => fcnt(2),
		I0 => fcnt(1),
		O => igetdat
	);

	tcbin_timer <= tcbin_timer_reg;
	tcbin_trig <= tcbin_trig_reg;
	linkerr <= linkerr_reg;

end Behavioral;

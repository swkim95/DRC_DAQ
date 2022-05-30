library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity tcb_deserializer is port(
	signal sidat : in std_logic;
	signal fcnt : in std_logic_vector(6 downto 0);
	signal linked : in std_logic;
	signal clk : in std_logic;
	signal tcbin : out std_logic_vector(7 downto 0);
	signal linkerr : out std_logic
); end tcb_deserializer;

architecture Behavioral of tcb_deserializer is

component decoder_10b8b port(
	signal pardat : in std_logic_vector(9 downto 0);
	signal linked : in std_logic;
	signal clk : in std_logic;
	signal sdin : out std_logic_vector(7 downto 0);
	signal charisk : out std_logic;
	signal dispplus : out std_logic;
	signal dispminus : out std_logic;
	signal notintable : out std_logic
); end component;

signal tcbin_reg : std_logic_vector(7 downto 0);
signal linkerr_reg : std_logic;

signal pardat : std_logic_vector(9 downto 0);
signal igetdat : std_logic;
signal getdat : std_logic;
signal chkerr : std_logic;
signal selk : std_logic;
signal sdin : std_logic_vector(7 downto 0);
signal charisk : std_logic;
signal dispplus : std_logic;
signal dispminus : std_logic;
signal notintable : std_logic;
signal pcharisk : std_logic;
signal pdispplus : std_logic := '0';
signal pdispminus : std_logic := '0';
signal pnotintable : std_logic;
signal olddispp : std_logic := '0';
signal olddispm : std_logic := '0';

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		if (linked = '1') then
			pardat <= sidat & pardat(9 downto 1);
		end if;

		getdat <= igetdat and (not fcnt(0));

		if (linked = '0') then
			tcbin_reg <= (others => '0');
			pcharisk <= '0';
			pdispplus <= '0';
			pdispminus <= '0';
			pnotintable <= '0';
			olddispp <= '0';
			olddispm <= '0';
		elsif (getdat = '1') then
			tcbin_reg <= sdin;
			pcharisk <= charisk;
			pdispplus <= dispplus;
			pdispminus <= dispminus;
			pnotintable <= notintable;
			olddispp <= pdispplus;
			olddispm <= pdispminus;
		end if;

		chkerr <= getdat;
		
		selk <= (not fcnt(6)) and (not fcnt(5)) and (not fcnt(4));
		
		if (linked = '0') then
			linkerr_reg <= '0';
		elsif (chkerr = '1') then
			linkerr_reg <= pnotintable or (selk and (not pcharisk)) or ((not selk) and pcharisk)
						   or (olddispp and pdispplus) or (olddispm and pdispminus);
		end if;

	end if;
	end process;

	u1 : decoder_10b8b port map(
		pardat => pardat,
		linked => linked,
		clk => clk,
		sdin => sdin,
		charisk => charisk,
		dispplus => dispplus,
		dispminus => dispminus,
		notintable => notintable
	);

	lut6_getdat : LUT6
	generic map(INIT => X"0000210842108420")
	port map(
		I5 => fcnt(6),
		I4 => fcnt(5),
		I3 => fcnt(4),
		I2 => fcnt(3),
		I1 => fcnt(2),
		I0 => fcnt(1),
		O => igetdat
	);

	tcbin <= tcbin_reg;
	linkerr <= linkerr_reg;

end Behavioral;


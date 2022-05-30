library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity get_mid is port(
	signal tcb_ftime : in std_logic_vector(6 downto 0);
	signal mod_mid : in mod_mid_array;
	signal usb_mid : in std_logic_vector(7 downto 0);
	signal clk : in std_logic;
	signal mid_addr : out std_logic_vector(5 downto 0)
); end get_mid;

architecture Behavioral of get_mid is

type wa_array is array(7 downto 0) of std_logic_vector(39 downto 0);

signal sget : std_logic;
signal cen : std_logic;
signal cnt : std_logic_vector(5 downto 0);
signal clr : std_logic;
signal wa : wa_array;
signal dcen : std_logic;
signal dwa : std_logic_vector(7 downto 0);
signal mwd : std_logic_vector(15 downto 0);
signal mrd : std_logic_vector(15 downto 0);
signal mwa : std_logic_vector(13 downto 0);
signal mra : std_logic_vector(13 downto 0);
signal mwe : std_logic_vector(3 downto 0);

begin

	process(clk) begin
	if (clk'event and clk = '1') then
	
		sget <= tcb_ftime(6) and tcb_ftime(5) and tcb_ftime(4)
		    and tcb_ftime(3) and tcb_ftime(2) and (not tcb_ftime(1)) and (not tcb_ftime(0));
			 
		if (clr = '1') then
			cen <= '0';
		elsif (sget = '1') then
			cen <= '1';
		end if;
		dcen <= cen;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(5) and (not cnt(4)) and (not cnt(3))
		   and cnt(2) and cnt(1) and cnt(0);
			
		if (sget = '1') then
			wa(0) <= mod_mid(39)(0) & mod_mid(38)(0) & mod_mid(37)(0) & mod_mid(36)(0) & mod_mid(35)(0)
                & mod_mid(34)(0) & mod_mid(33)(0) & mod_mid(32)(0) & mod_mid(31)(0) & mod_mid(30)(0)
                & mod_mid(29)(0) & mod_mid(28)(0) & mod_mid(27)(0) & mod_mid(26)(0) & mod_mid(25)(0)
                & mod_mid(24)(0) & mod_mid(23)(0) & mod_mid(22)(0) & mod_mid(21)(0) & mod_mid(20)(0)
                & mod_mid(19)(0) & mod_mid(18)(0) & mod_mid(17)(0) & mod_mid(16)(0) & mod_mid(15)(0)
                & mod_mid(14)(0) & mod_mid(13)(0) & mod_mid(12)(0) & mod_mid(11)(0) & mod_mid(10)(0)
                & mod_mid(9)(0) & mod_mid(8)(0) & mod_mid(7)(0) & mod_mid(6)(0) & mod_mid(5)(0)
                & mod_mid(4)(0) & mod_mid(3)(0) & mod_mid(2)(0) & mod_mid(1)(0) & mod_mid(0)(0);
         wa(1) <= mod_mid(39)(1) & mod_mid(38)(1) & mod_mid(37)(1) & mod_mid(36)(1) & mod_mid(35)(1)
                & mod_mid(34)(1) & mod_mid(33)(1) & mod_mid(32)(1) & mod_mid(31)(1) & mod_mid(30)(1)
                & mod_mid(29)(1) & mod_mid(28)(1) & mod_mid(27)(1) & mod_mid(26)(1) & mod_mid(25)(1)
                & mod_mid(24)(1) & mod_mid(23)(1) & mod_mid(22)(1) & mod_mid(21)(1) & mod_mid(20)(1)
                & mod_mid(19)(1) & mod_mid(18)(1) & mod_mid(17)(1) & mod_mid(16)(1) & mod_mid(15)(1)
                & mod_mid(14)(1) & mod_mid(13)(1) & mod_mid(12)(1) & mod_mid(11)(1) & mod_mid(10)(1)
                & mod_mid(9)(1) & mod_mid(8)(1) & mod_mid(7)(1) & mod_mid(6)(1) & mod_mid(5)(1)
                & mod_mid(4)(1) & mod_mid(3)(1) & mod_mid(2)(1) & mod_mid(1)(1) & mod_mid(0)(1);
         wa(2) <= mod_mid(39)(2) & mod_mid(38)(2) & mod_mid(37)(2) & mod_mid(36)(2) & mod_mid(35)(2)
                & mod_mid(34)(2) & mod_mid(33)(2) & mod_mid(32)(2) & mod_mid(31)(2) & mod_mid(30)(2)
                & mod_mid(29)(2) & mod_mid(28)(2) & mod_mid(27)(2) & mod_mid(26)(2) & mod_mid(25)(2)
                & mod_mid(24)(2) & mod_mid(23)(2) & mod_mid(22)(2) & mod_mid(21)(2) & mod_mid(20)(2)
                & mod_mid(19)(2) & mod_mid(18)(2) & mod_mid(17)(2) & mod_mid(16)(2) & mod_mid(15)(2)
                & mod_mid(14)(2) & mod_mid(13)(2) & mod_mid(12)(2) & mod_mid(11)(2) & mod_mid(10)(2)
                & mod_mid(9)(2) & mod_mid(8)(2) & mod_mid(7)(2) & mod_mid(6)(2) & mod_mid(5)(2)
                & mod_mid(4)(2) & mod_mid(3)(2) & mod_mid(2)(2) & mod_mid(1)(2) & mod_mid(0)(2);
         wa(3) <= mod_mid(39)(3) & mod_mid(38)(3) & mod_mid(37)(3) & mod_mid(36)(3) & mod_mid(35)(3)
                & mod_mid(34)(3) & mod_mid(33)(3) & mod_mid(32)(3) & mod_mid(31)(3) & mod_mid(30)(3)
                & mod_mid(29)(3) & mod_mid(28)(3) & mod_mid(27)(3) & mod_mid(26)(3) & mod_mid(25)(3)
                & mod_mid(24)(3) & mod_mid(23)(3) & mod_mid(22)(3) & mod_mid(21)(3) & mod_mid(20)(3)
                & mod_mid(19)(3) & mod_mid(18)(3) & mod_mid(17)(3) & mod_mid(16)(3) & mod_mid(15)(3)
                & mod_mid(14)(3) & mod_mid(13)(3) & mod_mid(12)(3) & mod_mid(11)(3) & mod_mid(10)(3)
                & mod_mid(9)(3) & mod_mid(8)(3) & mod_mid(7)(3) & mod_mid(6)(3) & mod_mid(5)(3)
                & mod_mid(4)(3) & mod_mid(3)(3) & mod_mid(2)(3) & mod_mid(1)(3) & mod_mid(0)(3);
         wa(4) <= mod_mid(39)(4) & mod_mid(38)(4) & mod_mid(37)(4) & mod_mid(36)(4) & mod_mid(35)(4)
                & mod_mid(34)(4) & mod_mid(33)(4) & mod_mid(32)(4) & mod_mid(31)(4) & mod_mid(30)(4)
                & mod_mid(29)(4) & mod_mid(28)(4) & mod_mid(27)(4) & mod_mid(26)(4) & mod_mid(25)(4)
                & mod_mid(24)(4) & mod_mid(23)(4) & mod_mid(22)(4) & mod_mid(21)(4) & mod_mid(20)(4)
                & mod_mid(19)(4) & mod_mid(18)(4) & mod_mid(17)(4) & mod_mid(16)(4) & mod_mid(15)(4)
                & mod_mid(14)(4) & mod_mid(13)(4) & mod_mid(12)(4) & mod_mid(11)(4) & mod_mid(10)(4)
                & mod_mid(9)(4) & mod_mid(8)(4) & mod_mid(7)(4) & mod_mid(6)(4) & mod_mid(5)(4)
                & mod_mid(4)(4) & mod_mid(3)(4) & mod_mid(2)(4) & mod_mid(1)(4) & mod_mid(0)(4);
         wa(5) <= mod_mid(39)(5) & mod_mid(38)(5) & mod_mid(37)(5) & mod_mid(36)(5) & mod_mid(35)(5)
                & mod_mid(34)(5) & mod_mid(33)(5) & mod_mid(32)(5) & mod_mid(31)(5) & mod_mid(30)(5)
                & mod_mid(29)(5) & mod_mid(28)(5) & mod_mid(27)(5) & mod_mid(26)(5) & mod_mid(25)(5)
                & mod_mid(24)(5) & mod_mid(23)(5) & mod_mid(22)(5) & mod_mid(21)(5) & mod_mid(20)(5)
                & mod_mid(19)(5) & mod_mid(18)(5) & mod_mid(17)(5) & mod_mid(16)(5) & mod_mid(15)(5)
                & mod_mid(14)(5) & mod_mid(13)(5) & mod_mid(12)(5) & mod_mid(11)(5) & mod_mid(10)(5)
                & mod_mid(9)(5) & mod_mid(8)(5) & mod_mid(7)(5) & mod_mid(6)(5) & mod_mid(5)(5)
                & mod_mid(4)(5) & mod_mid(3)(5) & mod_mid(2)(5) & mod_mid(1)(5) & mod_mid(0)(5);
         wa(6) <= mod_mid(39)(6) & mod_mid(38)(6) & mod_mid(37)(6) & mod_mid(36)(6) & mod_mid(35)(6)
                & mod_mid(34)(6) & mod_mid(33)(6) & mod_mid(32)(6) & mod_mid(31)(6) & mod_mid(30)(6)
                & mod_mid(29)(6) & mod_mid(28)(6) & mod_mid(27)(6) & mod_mid(26)(6) & mod_mid(25)(6)
                & mod_mid(24)(6) & mod_mid(23)(6) & mod_mid(22)(6) & mod_mid(21)(6) & mod_mid(20)(6)
                & mod_mid(19)(6) & mod_mid(18)(6) & mod_mid(17)(6) & mod_mid(16)(6) & mod_mid(15)(6)
                & mod_mid(14)(6) & mod_mid(13)(6) & mod_mid(12)(6) & mod_mid(11)(6) & mod_mid(10)(6)
                & mod_mid(9)(6) & mod_mid(8)(6) & mod_mid(7)(6) & mod_mid(6)(6) & mod_mid(5)(6)
                & mod_mid(4)(6) & mod_mid(3)(6) & mod_mid(2)(6) & mod_mid(1)(6) & mod_mid(0)(6);
         wa(7) <= mod_mid(39)(7) & mod_mid(38)(7) & mod_mid(37)(7) & mod_mid(36)(7) & mod_mid(35)(7)
                & mod_mid(34)(7) & mod_mid(33)(7) & mod_mid(32)(7) & mod_mid(31)(7) & mod_mid(30)(7)
                & mod_mid(29)(7) & mod_mid(28)(7) & mod_mid(27)(7) & mod_mid(26)(7) & mod_mid(25)(7)
                & mod_mid(24)(7) & mod_mid(23)(7) & mod_mid(22)(7) & mod_mid(21)(7) & mod_mid(20)(7)
                & mod_mid(19)(7) & mod_mid(18)(7) & mod_mid(17)(7) & mod_mid(16)(7) & mod_mid(15)(7)
                & mod_mid(14)(7) & mod_mid(13)(7) & mod_mid(12)(7) & mod_mid(11)(7) & mod_mid(10)(7)
                & mod_mid(9)(7) & mod_mid(8)(7) & mod_mid(7)(7) & mod_mid(6)(7) & mod_mid(5)(7)
                & mod_mid(4)(7) & mod_mid(3)(7) & mod_mid(2)(7) & mod_mid(1)(7) & mod_mid(0)(7);
		elsif (cen = '1') then
			wa(0) <= '0' & wa(0)(39 downto 1);
			wa(1) <= '0' & wa(1)(39 downto 1);
			wa(2) <= '0' & wa(2)(39 downto 1);
			wa(3) <= '0' & wa(3)(39 downto 1);
			wa(4) <= '0' & wa(4)(39 downto 1);
			wa(5) <= '0' & wa(5)(39 downto 1);
			wa(6) <= '0' & wa(6)(39 downto 1);
			wa(7) <= '0' & wa(7)(39 downto 1);
		end if;
		dwa <= wa(7)(0) & wa(6)(0) & wa(5)(0) & wa(4)(0)
           & wa(3)(0) & wa(2)(0) & wa(1)(0) & wa(0)(0);
	
	end if;
	end process;
	
	mwd <= "0000000000" & cnt(5 downto 0);
	mwa <= "000" & dwa(7 downto 0) & "000";
	mra <= "000" & usb_mid(7 downto 0) & "000";
	mwe <= (others => dcen);
	
	RAMB18E1_rd : RAMB18E1
	generic map (
		DOA_REG => 1,
		DOB_REG => 1,
		RAM_MODE => "TDP",
		READ_WIDTH_A => 9,
		READ_WIDTH_B => 9,
		WRITE_WIDTH_A => 9,
		WRITE_WIDTH_B => 9,
		SIM_DEVICE => "7SERIES"
	)
	port map (
		ADDRARDADDR => mra,
		DIADI => "1111111111111111",
		DIPADIP => "11",
		WEA => "00",
		ENARDEN => '1',
		REGCEAREGCE => '1',
		RSTRAMARSTRAM => '0',
		CLKARDCLK => clk,
		DOADO => mrd,
		DOPADOP => open,
		ADDRBWRADDR => mwa, 
		DIBDI => mwd,
		DIPBDIP => "11",
		WEBWE => mwe,
		ENBWREN => '1',
		REGCEB => '1',
		RSTREGARSTREG => '0',
		RSTRAMB => '0',
		RSTREGB => '0',
		CLKBWRCLK => clk,
		DOBDO => open,
		DOPBDOP => open
	);

	mid_addr <= mrd(5 downto 0);

end Behavioral;


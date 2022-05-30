library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity tcb_sync is port(
	signal p_tcb_timerp : in std_logic;
	signal p_tcb_timern : in std_logic;
	signal p_tcb_trigp : in std_logic;
	signal p_tcb_trign : in std_logic;
	signal link_enable : in std_logic;
	signal linkerr : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal sidat : out std_logic_vector(1 downto 0);
	signal fcnt : out std_logic_vector(6 downto 0);
	signal linkok : out std_logic
); end tcb_sync;

architecture Behavioral of tcb_sync is

type acnt_array is array (3 downto 0) of std_logic_vector(9 downto 0);

signal ntcb_timer : std_logic;
signal tcb_timer : std_logic;
signal tcb_trig : std_logic;
signal sidat_reg : std_logic_vector(1 downto 0);
signal fcnt_reg : std_logic_vector(6 downto 0);
signal linkok_reg : std_logic;

signal ad_timer : std_logic_vector(1 downto 0);
signal ad_trig : std_logic_vector(1 downto 0);
signal bd_timer : std_logic_vector(1 downto 0);
signal bd_trig : std_logic_vector(1 downto 0);
signal cd_timer : std_logic_vector(3 downto 0);
signal cd_trig : std_logic_vector(3 downto 0);
signal iacen : std_logic_vector(3 downto 0);
signal acen : std_logic_vector(3 downto 0);
signal atimer : std_logic_vector(9 downto 0);
signal aclr : std_logic;
signal acnt : acnt_array;
signal lacnt : acnt_array;
signal acomp : std_logic_vector(5 downto 0);
signal mux : std_logic_vector(1 downto 0);
signal isidat : std_logic_vector(1 downto 0);
signal dsidat : std_logic_vector(1 downto 0);
signal comp : std_logic_vector(8 downto 0);
signal match : std_logic;
signal timer : std_logic_vector(6 downto 0);
signal enmat : std_logic;
signal clr : std_logic;
signal cen : std_logic;
signal cnt : std_logic_vector(9 downto 0);
signal ensync : std_logic;
signal densync : std_logic_vector(5 downto 1);
signal fclr : std_logic;

begin

	ibufds_tcb_timer : ibufds port map(i => p_tcb_timern, ib => p_tcb_timerp, o => ntcb_timer);
	ibufds_tcb_trig : ibufds port map(i => p_tcb_trigp, ib => p_tcb_trign, o => tcb_trig);

	tcb_timer <= not ntcb_timer;

	iddr_tcb_timer : IDDR
	generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map (
		D => tcb_timer,
		C => x2clk,
		CE => '1',
		R => '0',
		S => '0',
		Q1 => ad_timer(1),
		Q2 => ad_timer(0)
	);

	iddr_tcb_trig : IDDR
	generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map (
		D => tcb_trig,
		C => x2clk,
		CE => '1',
		R => '0',
		S => '0',
		Q1 => ad_trig(1),
		Q2 => ad_trig(0)
	);

	process(clk) begin
	if (clk'event and clk = '0') then
		
		bd_timer <= ad_timer;
		bd_trig <= ad_trig;
	
	end if;
	end process;
	
	process(clk) begin
	if (clk'event and clk = '1') then
	
		cd_timer <= ad_timer & bd_timer;
		cd_trig <= ad_trig & bd_trig;
	
		acen <= iacen;
		
		if (aclr = '1') then
			atimer <= (others => '0');
		else
			atimer <= atimer + 1;
		end if;
		
		aclr <= atimer(9) and atimer(8) and atimer(7) and atimer(6) and atimer(5)
		    and atimer(4) and atimer(3) and atimer(2) and (not atimer(1)) and atimer(0);
			 
		if (aclr = '1') then
			acnt(0) <= (others => '0');
		elsif (acen(0) = '1') then
			acnt(0) <= acnt(0) + 1;
		end if;
		
		if (aclr = '1') then
			acnt(1) <= (others => '0');
		elsif (acen(1) = '1') then
			acnt(1) <= acnt(1) + 1;
		end if;
		
		if (aclr = '1') then
			acnt(2) <= (others => '0');
		elsif (acen(2) = '1') then
			acnt(2) <= acnt(2) + 1;
		end if;
		
		if (aclr = '1') then
			acnt(3) <= (others => '0');
		elsif (acen(3) = '1') then
			acnt(3) <= acnt(3) + 1;
		end if;
		
		if (aclr = '1') then
			lacnt <= acnt;
		end if;
		
		if (lacnt(0) >= lacnt(1)) then
			acomp(0) <= '1';
		else
			acomp(0) <= '0';
		end if;
		
		if (lacnt(0) >= lacnt(2)) then
			acomp(1) <= '1';
		else
			acomp(1) <= '0';
		end if;
		
		if (lacnt(0) >= lacnt(3)) then
			acomp(2) <= '1';
		else
			acomp(2) <= '0';
		end if;
		
		if (lacnt(1) >= lacnt(2)) then
			acomp(3) <= '1';
		else
			acomp(3) <= '0';
		end if;
		
		if (lacnt(1) >= lacnt(3)) then
			acomp(4) <= '1';
		else
			acomp(4) <= '0';
		end if;
		
		if (lacnt(2) >= lacnt(3)) then
			acomp(5) <= '1';
		else
			acomp(5) <= '0';
		end if;
		
		mux(0) <= ((not acomp(0)) and acomp(3) and acomp(4))
		       or ((not acomp(2)) and (not acomp(4)) and (not acomp(5)));
		mux(1) <= ((not acomp(1)) and (not acomp(3)) and acomp(5))
		       or ((not acomp(2)) and (not acomp(4)) and (not acomp(5)));

		sidat_reg <= isidat;
		dsidat <= sidat_reg;
		
		comp <= comp(7 downto 0) & (sidat_reg(0) xnor dsidat(0));
		
		match <= comp(8) and (not comp(7)) and comp(6)
		     and comp(5) and comp(4) and comp(3)
		     and (not comp(2)) and comp(1) and (not comp(0));
		
		if (match = '1') then
			timer <= (others => '0');
		else
			timer <= timer + 1;
		end if;
		
		enmat <= timer(6) and (not timer(5)) and timer(4) and timer(3)
		     and (not timer(2)) and (not timer(1)) and (not timer(0));
		
		clr <= (enmat and (not match)) or linkerr or (not link_enable);

		cen <= enmat and match;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		ensync <= (not linkok_reg) and cen and cnt(9) and cnt(8)
		      and cnt(7) and cnt(6) and cnt(5) and (not cnt(4))
		      and (not cnt(3)) and cnt(2) and cnt(1) and cnt(0);

		if (clr = '1') then
			linkok_reg <= '0';
		elsif (densync(5) = '1') then
			linkok_reg <= '1';
		end if;

		if (linkok_reg = '0') then
			fcnt_reg <= (others => '0');
		elsif (fclr = '1') then
			fcnt_reg <= (others => '0');
		elsif (linkok_reg = '1') then
			fcnt_reg <= fcnt_reg + 1;
		end if;

		fclr <= fcnt_reg(6) and (not fcnt_reg(5)) and fcnt_reg(4) and fcnt_reg(3)
		     and (not fcnt_reg(2)) and (not fcnt_reg(1)) and (not fcnt_reg(0));
			  
	end if;
	end process;

	lut4_acen0 : LUT4
	generic map(INIT => X"9009")
	port map(
		I3 => cd_timer(3),
		I2 => cd_timer(2),
		I1 => cd_timer(1),
		I0 => cd_timer(0),
		O => iacen(0)
	);

	lut4_acen1 : LUT4
	generic map(INIT => X"8181")
	port map(
		I3 => cd_timer(3),
		I2 => cd_timer(2),
		I1 => cd_timer(1),
		I0 => cd_timer(0),
		O => iacen(1)
	);

	lut4_acen2 : LUT4
	generic map(INIT => X"8001")
	port map(
		I3 => cd_timer(3),
		I2 => cd_timer(2),
		I1 => cd_timer(1),
		I0 => cd_timer(0),
		O => iacen(2)
	);

	lut4_acen3 : LUT4
	generic map(INIT => X"C003")
	port map(
		I3 => cd_timer(3),
		I2 => cd_timer(2),
		I1 => cd_timer(1),
		I0 => cd_timer(0),
		O => iacen(3)
	);
	
	isidat <= cd_trig(2) & cd_timer(2) when mux = "11"
	     else cd_trig(1) & cd_timer(1) when mux = "10"
	     else cd_trig(0) & cd_timer(0) when mux = "01"
	     else cd_trig(3) & cd_timer(3);
	
	srl16e_densync1 : srl16e
	generic map (init => X"0000")
	port map (
		d => ensync,
		a3 => '1',
		a2 => '1',
		a1 => '1',
		a0 => '1',
		ce => '1',
		clk => clk,
		q => densync(1)
	);

	srl16e_densync2 : srl16e
	generic map (init => X"0000")
	port map (
		d => densync(1),
		a3 => '1',
		a2 => '1',
		a1 => '1',
		a0 => '1',
		ce => '1',
		clk => clk,
		q => densync(2)
	);

	srl16e_densync3 : srl16e
	generic map (init => X"0000")
	port map (
		d => densync(2),
		a3 => '1',
		a2 => '1',
		a1 => '1',
		a0 => '1',
		ce => '1',
		clk => clk,
		q => densync(3)
	);

	srl16e_densync4 : srl16e
	generic map (init => X"0000")
	port map (
		d => densync(3),
		a3 => '1',
		a2 => '1',
		a1 => '1',
		a0 => '1',
		ce => '1',
		clk => clk,
		q => densync(4)
	);

	srl16e_densync5 : srl16e
	generic map (init => X"0000")
	port map (
		d => densync(4),
		a3 => '0',
		a2 => '0',
		a1 => '0',
		a0 => '1',
		ce => '1',
		clk => clk,
		q => densync(5)
	);

	sidat <= sidat_reg;
	fcnt <= fcnt_reg;
	linkok <= linkok_reg;

end Behavioral;



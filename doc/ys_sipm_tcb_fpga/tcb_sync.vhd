library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_tcb_fpga_type.all;

entity tcb_sync is port(
	signal adc_trigger : in std_logic;
	signal linkerr : in std_logic;
	signal run : in std_logic;
	signal x2clk : in std_logic;
	signal clk : in std_logic;
	signal sidat : out std_logic;
	signal fcnt : out std_logic_vector(6 downto 0);
	signal linked : out std_logic
); end tcb_sync;

architecture Behavioral of tcb_sync is

type acnt_array is array (3 downto 0) of std_logic_vector(9 downto 0);

signal sidat_reg : std_logic;
signal fcnt_reg : std_logic_vector(6 downto 0);
signal linked_reg : std_logic;

signal nclk : std_logic;
signal ad : std_logic_vector(1 downto 0);
signal bd : std_logic_vector(1 downto 0);
signal cd : std_logic_vector(3 downto 0);
signal iacen : std_logic_vector(3 downto 0);
signal acen : std_logic_vector(3 downto 0);
signal atimer : std_logic_vector(9 downto 0);
signal aclr : std_logic;
signal acnt : acnt_array;
signal lacnt : acnt_array;
signal acomp : std_logic_vector(5 downto 0);
signal mux : std_logic_vector(1 downto 0);
signal isidat : std_logic;
signal dsidat : std_logic;
signal comp : std_logic_vector(8 downto 0);
signal match : std_logic;
signal timer : std_logic_vector(6 downto 0);
signal enmat : std_logic;
signal clr : std_logic;
signal cen : std_logic;
signal cnt : std_logic_vector(9 downto 0);
signal ensync : std_logic;
signal densync : std_logic_vector(7 downto 1);
signal fclr : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '0') then
		
		bd <= ad;
	
	end if;
	end process;
	
	process(clk) begin
	if (clk'event and clk = '1') then
	
		cd(0) <= bd(0);
		cd(1) <= bd(1);
		cd(2) <= ad(0);
		cd(3) <= ad(1);
		
		acen <= iacen;
		
		if (aclr = '1') then
			atimer <= (others => '0');
		elsif (run = '0') then
			atimer <= atimer + 1;
		end if;
		
		aclr <= (not run) and atimer(9) and atimer(8) and atimer(7) and atimer(6) and atimer(5)
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
		
		comp <= comp(7 downto 0) & (sidat_reg xnor dsidat);
		
		match <= comp(8) and (not comp(7)) and comp(6)
		     and comp(5) and comp(4) and comp(3)
		     and (not comp(2)) and comp(1) and (not comp(0));
		
		if (match = '1') then
			timer <= (others => '0');
		elsif (run = '0') then
			timer <= timer + 1;
		end if;
		
		enmat <= (not run) and timer(6) and (not timer(5)) and timer(4) 
		     and timer(3) and (not timer(2)) and (not timer(1)) and (not timer(0));
		
		clr <= (enmat and (not match)) or linkerr;

		cen <= enmat and match;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		ensync <= (not linked_reg) and cen and cnt(9) and cnt(8)
		      and cnt(7) and cnt(6) and cnt(5) and (not cnt(4))
		      and (not cnt(3)) and cnt(2) and cnt(1) and cnt(0);

		if (clr = '1') then
			linked_reg <= '0';
		elsif (densync(7) = '1') then
			linked_reg <= '1';
		end if;

		if (linked_reg = '0') then
			fcnt_reg <= (others => '0');
		elsif (fclr = '1') then
			fcnt_reg <= (others => '0');
		elsif (linked_reg = '1') then
			fcnt_reg <= fcnt_reg + 1;
		end if;

		fclr <= fcnt_reg(6) and (not fcnt_reg(5)) and fcnt_reg(4) and fcnt_reg(3)
		     and (not fcnt_reg(2)) and (not fcnt_reg(1)) and (not fcnt_reg(0));

	end if;
	end process;

	iddr_ad : IDDR
	generic map (DDR_CLK_EDGE => "SAME_EDGE")
	port map (
		D => adc_trigger,
		C => x2clk,
		CE => '1',
		R => '0',
		S => '0',
		Q1 => ad(1),
		Q2 => ad(0)
	);

	lut4_acen0 : LUT4
	generic map(INIT => X"9009")
	port map(
		I3 => cd(3),
		I2 => cd(2),
		I1 => cd(1),
		I0 => cd(0),
		O => iacen(0)
	);

	lut4_acen1 : LUT4
	generic map(INIT => X"8181")
	port map(
		I3 => cd(3),
		I2 => cd(2),
		I1 => cd(1),
		I0 => cd(0),
		O => iacen(1)
	);

	lut4_acen2 : LUT4
	generic map(INIT => X"8001")
	port map(
		I3 => cd(3),
		I2 => cd(2),
		I1 => cd(1),
		I0 => cd(0),
		O => iacen(2)
	);

	lut4_acen3 : LUT4
	generic map(INIT => X"C003")
	port map(
		I3 => cd(3),
		I2 => cd(2),
		I1 => cd(1),
		I0 => cd(0),
		O => iacen(3)
	);
	
	isidat <= cd(2) when mux = "11"
	     else cd(1) when mux = "10"
	     else cd(0) when mux = "01"
	     else cd(3);
	
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
		a3 => '1',
		a2 => '1',
		a1 => '1',
		a0 => '1',
		ce => '1',
		clk => clk,
		q => densync(5)
	);

	srl16e_densync6 : srl16e
	generic map (init => X"0000")
	port map (
		d => densync(5),
		a3 => '1',
		a2 => '1',
		a1 => '1',
		a0 => '1',
		ce => '1',
		clk => clk,
		q => densync(6)
	);

	srl16e_densync7 : srl16e
	generic map (init => X"0000")
	port map (
		d => densync(6),
		a3 => '1',
		a2 => '1',
		a1 => '1',
		a0 => '0',
		ce => '1',
		clk => clk,
		q => densync(7)
	);

	sidat <= sidat_reg;
	fcnt <= fcnt_reg;
	linked <= linked_reg;

end Behavioral;


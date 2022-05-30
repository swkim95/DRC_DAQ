library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity temperature_monitor is port(
	signal p_temp_sda : inout std_logic;
	signal latch_temp : in std_logic;
	signal clk : in std_logic;
	signal temp_data : out std_logic_vector(11 downto 0);
	signal p_temp_scl : out std_logic
); end temperature_monitor;

architecture Behavioral of temperature_monitor is

signal temp_scl : std_logic;
signal temp_sda_out : std_logic;
signal itemp_sda_in : std_logic;
signal temp_sda_in : std_logic;
signal temp_data_reg : std_logic_vector(11 downto 0);
signal temp_pdat : std_logic_vector(11 downto 0);
signal read_cnt : std_logic_vector(26 downto 0) := (others => '0');
signal start_read : std_logic;
signal cen : std_logic;
signal cnt : std_logic_vector(14 downto 0);
signal clr : std_logic;
signal iptemp_sda_out : std_logic;
signal ptemp_sda_out : std_logic;
signal iptemp_scl : std_logic;
signal ptemp_scl : std_logic;
signal en_shift : std_logic;
signal shift : std_logic;
signal sdat : std_logic_vector(11 downto 0);

attribute iob : string;
attribute iob of temp_scl : signal is "true";
attribute iob of temp_sda_out : signal is "true";
attribute iob of temp_sda_in : signal is "true";

begin

	ibuf_temp_sda : ibuf port map(i => p_temp_sda, o => itemp_sda_in);

	process(clk) begin
	if (clk'event and clk = '1') then
	
		if (start_read = '1') then
			read_cnt <= (others => '0');
		else
			read_cnt <= read_cnt + 1;
		end if;
		
		start_read <= read_cnt(26) and read_cnt(25) and read_cnt(24)
		          and (not read_cnt(23)) and read_cnt(22) and read_cnt(21) and read_cnt(20)
					 and (not read_cnt(19)) and (not read_cnt(18)) and read_cnt(17) and read_cnt(16)
					 and (not read_cnt(15)) and read_cnt(14) and (not read_cnt(13)) and read_cnt(12)
					 and read_cnt(11) and (not read_cnt(10)) and (not read_cnt(9)) and read_cnt(8)
					 and (not read_cnt(7)) and (not read_cnt(6)) and read_cnt(5) and read_cnt(4)
					 and read_cnt(3) and read_cnt(2) and read_cnt(1) and (not read_cnt(0));
		
		if (clr = '1') then
			cen <= '0';
		elsif (start_read = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(14) and cnt(13) and (not cnt(12)) and (not cnt(11))
		   and (not cnt(10)) and cnt(9) and (not cnt(8)) and cnt(7) and cnt(6) 
			and cnt(5) and cnt(4) and cnt(3) and cnt(2) and cnt(1) and (not cnt(0));
		
		ptemp_scl <= iptemp_scl;
		temp_scl <= ptemp_scl;
		
		ptemp_sda_out <= iptemp_sda_out;
		temp_sda_out <= ptemp_sda_out;

		shift <= en_shift and cnt(8) and cnt(7) and cnt(6) and cnt(5) 
		     and cnt(4) and cnt(3) and cnt(2) and cnt(1) and cnt(0);

		temp_sda_in <= itemp_sda_in;
		
		if (shift = '1') then
			sdat <= sdat(10 downto 0) & temp_sda_in;
		end if;
	
		if (clr = '1') then
			temp_pdat <= sdat;
		end if;
	
		if (latch_temp = '1') then
			temp_data_reg <= temp_pdat;
		end if;
		
	end if;
	end process;

	rom128x1_ptemp_scl : ROM128X1
	generic map (INIT => X"FFFFFFFEAAAAAAAAAAAAABD555555555")
	port map (
		A0 => cnt(8),
		A1 => cnt(9),
		A2 => cnt(10),
		A3 => cnt(11),
		A4 => cnt(12),
		A5 => cnt(13),
		A6 => cnt(14),
		O => iptemp_scl
	);

	rom256x1_ptemp_sda_out : ROM256X1
	generic map (INIT => X"FFFFFFFFFFFFFFE1FFFFFFFFE1FFFFFFFFFE001E01E787800000007800078079")
	port map (
		A0 => cnt(7),
		A1 => cnt(8),
		A2 => cnt(9),
		A3 => cnt(10),
		A4 => cnt(11),
		A5 => cnt(12),
		A6 => cnt(13),
		A7 => cnt(14),
		O => iptemp_sda_out
	);

	lut6_en_shift : LUT6
	generic map (INIT => X"000007BFC0000000")
	port map (
		I0 => cnt(9),
		I1 => cnt(10),
		I2 => cnt(11),
		I3 => cnt(12),
		I4 => cnt(13),
		I5 => cnt(14),
		O => en_shift
	);
	
	temp_data <= temp_data_reg;

	obuft_temp_sda : obuft port map(i => '0', t => temp_sda_out, o => p_temp_sda);
	obuf_temp_temp_scl : obuf port map(i => temp_scl, o => p_temp_scl);

end Behavioral;


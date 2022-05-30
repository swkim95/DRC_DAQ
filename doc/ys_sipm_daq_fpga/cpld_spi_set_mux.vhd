library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.ys_sipm_daq_fpga_type.all;

entity cpld_spi_set_mux is port(
	signal hv_data : in hv_data_array;
	signal hv_write : in std_logic_vector(3 downto 0);
	signal thr_data : in thr_data_array;
	signal thr_write : in std_logic_vector(31 downto 0);
	signal dac_ofs_write : in std_logic;
	signal clk : in std_logic;
	signal hv_dac_data : out std_logic_vector(7 downto 0);
	signal hv_dac_write : out std_logic;
	signal thr_dac_data : out std_logic_vector(11 downto 0);
	signal thr_dac_ch : out std_logic_vector(2 downto 0);
	signal thr_dac_write : out std_logic;
	signal drs_dac_write : out std_logic;
	signal mux_sck : out std_logic;
	signal mux_sdi : out std_logic
); end cpld_spi_set_mux;

architecture Behavioral of cpld_spi_set_mux is

signal hv_dac_data_reg : std_logic_vector(7 downto 0);
signal hv_dac_write_reg : std_logic;
signal thr_dac_data_reg : std_logic_vector(11 downto 0);
signal thr_dac_ch_reg : std_logic_vector(2 downto 0);
signal thr_dac_write_reg : std_logic;
signal drs_dac_write_reg : std_logic;
signal mux_sck_reg : std_logic;

signal iload : std_logic;
signal load : std_logic;
signal dac_mux : std_logic_vector(3 downto 0);
signal hv_data_mux : std_logic_vector(1 downto 0);
signal thr_data_mux : std_logic_vector(4 downto 0);
signal ihv_dac_data : std_logic_vector(7 downto 0);
signal ithr_dac_data : std_logic_vector(11 downto 0);
signal cen : std_logic;
signal cnt : std_logic_vector(5 downto 0);
signal clr : std_logic;
signal dclr : std_logic;
signal shift : std_logic;
signal sdat : std_logic_vector(3 downto 0);
signal imux_sck : std_logic;

begin

	process(clk) begin
	if (clk'event and clk = '1') then

		load <= iload;
		
		if (iload = '1') then
			dac_mux(0) <= hv_write(1) or hv_write(3)
	                 or thr_write(8) or thr_write(9) or thr_write(10) or thr_write(11)
	                 or thr_write(12) or thr_write(13) or thr_write(14) or thr_write(15)
	                 or thr_write(24) or thr_write(25) or thr_write(26) or thr_write(27)
	                 or thr_write(28) or thr_write(29) or thr_write(30) or thr_write(31);

			dac_mux(1) <= hv_write(2) or hv_write(3)
	                 or thr_write(16) or thr_write(17) or thr_write(18) or thr_write(19)
	                 or thr_write(20) or thr_write(21) or thr_write(22) or thr_write(23)
	                 or thr_write(24) or thr_write(25) or thr_write(26) or thr_write(27)
	                 or thr_write(28) or thr_write(29) or thr_write(30) or thr_write(31);

			dac_mux(2) <= dac_ofs_write;

			dac_mux(3) <= thr_write(0) or thr_write(1) or thr_write(2) or thr_write(3)
	                 or thr_write(4) or thr_write(5) or thr_write(6) or thr_write(7)
	                 or thr_write(8) or thr_write(9) or thr_write(10) or thr_write(11)
	                 or thr_write(12) or thr_write(13) or thr_write(14) or thr_write(15)
	                 or thr_write(16) or thr_write(17) or thr_write(18) or thr_write(19)
	                 or thr_write(20) or thr_write(21) or thr_write(22) or thr_write(23)
	                 or thr_write(24) or thr_write(25) or thr_write(26) or thr_write(27)
	                 or thr_write(28) or thr_write(29) or thr_write(30) or thr_write(31)
			           or dac_ofs_write;

			hv_data_mux(0) <= hv_write(1) or hv_write(3);

			hv_data_mux(1) <= hv_write(2) or hv_write(3);

			thr_data_mux(0) <= thr_write(1) or thr_write(5) or thr_write(5) or thr_write(7)
	                      or thr_write(9) or thr_write(11) or thr_write(13) or thr_write(15)
	                      or thr_write(17) or thr_write(19) or thr_write(21) or thr_write(23)
	                      or thr_write(25) or thr_write(27) or thr_write(29) or thr_write(31);

			thr_data_mux(1) <= thr_write(2) or thr_write(3) or thr_write(6) or thr_write(7)
	                      or thr_write(10) or thr_write(11) or thr_write(14) or thr_write(15)
	                      or thr_write(18) or thr_write(19) or thr_write(22) or thr_write(23)
	                      or thr_write(26) or thr_write(27) or thr_write(30) or thr_write(31);

			thr_data_mux(2) <= thr_write(4) or thr_write(5) or thr_write(6) or thr_write(7)
	                      or thr_write(12) or thr_write(13) or thr_write(14) or thr_write(15)
	                      or thr_write(20) or thr_write(21) or thr_write(22) or thr_write(23)
	                      or thr_write(28) or thr_write(29) or thr_write(30) or thr_write(31);

			thr_data_mux(3) <= thr_write(8) or thr_write(0) or thr_write(10) or thr_write(11)
	                      or thr_write(12) or thr_write(13) or thr_write(14) or thr_write(15)
	                      or thr_write(24) or thr_write(25) or thr_write(26) or thr_write(27)
	                      or thr_write(28) or thr_write(29) or thr_write(30) or thr_write(31);

			thr_data_mux(4) <= thr_write(16) or thr_write(17) or thr_write(18) or thr_write(19)
	                      or thr_write(20) or thr_write(21) or thr_write(22) or thr_write(23)
	                      or thr_write(24) or thr_write(25) or thr_write(26) or thr_write(27)
	                      or thr_write(28) or thr_write(29) or thr_write(30) or thr_write(31);

			thr_dac_ch_reg(0) <= thr_write(1) or thr_write(3) or thr_write(4) or thr_write(6)
	                        or thr_write(9) or thr_write(11) or thr_write(12) or thr_write(14)
	                        or thr_write(17) or thr_write(19) or thr_write(20) or thr_write(22)
	                        or thr_write(25) or thr_write(27) or thr_write(28) or thr_write(30);

			thr_dac_ch_reg(1) <= thr_write(2) or thr_write(3) or thr_write(4) or thr_write(5)
	                        or thr_write(10) or thr_write(11) or thr_write(12) or thr_write(13)
	                        or thr_write(18) or thr_write(19) or thr_write(20) or thr_write(21)
	                        or thr_write(26) or thr_write(27) or thr_write(28) or thr_write(29);

			thr_dac_ch_reg(2) <= thr_write(4) or thr_write(5) or thr_write(6) or thr_write(7)
	                        or thr_write(12) or thr_write(13) or thr_write(14) or thr_write(15)
	                        or thr_write(20) or thr_write(21) or thr_write(22) or thr_write(23)
	                        or thr_write(28) or thr_write(29) or thr_write(30) or thr_write(31);
		end if;

		hv_dac_data_reg <= ihv_dac_data;
		thr_dac_data_reg <= ithr_dac_data;
		
		if (clr = '1') then
			cen <= '0';
		elsif (load = '1') then
			cen <= '1';
		end if;
		
		if (clr = '1') then
			cnt <= (others => '0');
		elsif (cen = '1') then
			cnt <= cnt + 1;
		end if;
		
		clr <= cnt(5) and cnt(4) and cnt(3) and cnt(2) and cnt(1) and (not cnt(0));
		
		shift <= cnt(3) and cnt(2) and cnt(1) and (not cnt(0));
		
		if (load = '1') then
			sdat <= dac_mux;
		elsif (shift = '1') then
			sdat <= sdat(2 downto 0) & '0';
		end if;
		
		mux_sck_reg <= imux_sck;

		hv_dac_write_reg <= dclr and (not dac_mux(3));
		thr_dac_write_reg <= dclr and dac_mux(3) and (not dac_mux(2));
		drs_dac_write_reg <= dclr and dac_mux(3) and dac_mux(2);

	end if;
	end process;
	
	iload <= hv_write(0) or hv_write(1) or hv_write(2) or hv_write(3)
	      or thr_write(0) or thr_write(1) or thr_write(2) or thr_write(3)
	      or thr_write(4) or thr_write(5) or thr_write(6) or thr_write(7)
	      or thr_write(8) or thr_write(9) or thr_write(10) or thr_write(11)
	      or thr_write(12) or thr_write(13) or thr_write(14) or thr_write(15)
	      or thr_write(16) or thr_write(17) or thr_write(18) or thr_write(19)
	      or thr_write(20) or thr_write(21) or thr_write(22) or thr_write(23)
	      or thr_write(24) or thr_write(25) or thr_write(26) or thr_write(27)
	      or thr_write(28) or thr_write(29) or thr_write(30) or thr_write(31)
			or dac_ofs_write;

	ihv_dac_data <= hv_data(0) when hv_data_mux = "00"
	           else hv_data(1) when hv_data_mux = "01"
	           else hv_data(2) when hv_data_mux = "10"
	           else hv_data(3);
				  
	ithr_dac_data <= thr_data(0) when thr_data_mux = "00000"
	            else thr_data(1) when thr_data_mux = "00001"
	            else thr_data(2) when thr_data_mux = "00010"
	            else thr_data(3) when thr_data_mux = "00011"
	            else thr_data(4) when thr_data_mux = "00100"
	            else thr_data(5) when thr_data_mux = "00101"
	            else thr_data(6) when thr_data_mux = "00110"
	            else thr_data(7) when thr_data_mux = "00111"
	            else thr_data(8) when thr_data_mux = "01000"
	            else thr_data(9) when thr_data_mux = "01001"
	            else thr_data(10) when thr_data_mux = "01010"
	            else thr_data(11) when thr_data_mux = "01011"
	            else thr_data(12) when thr_data_mux = "01100"
	            else thr_data(13) when thr_data_mux = "01101"
	            else thr_data(14) when thr_data_mux = "01110"
	            else thr_data(15) when thr_data_mux = "01111"
	            else thr_data(16) when thr_data_mux = "10000"
	            else thr_data(17) when thr_data_mux = "10001"
	            else thr_data(18) when thr_data_mux = "10010"
	            else thr_data(19) when thr_data_mux = "10011"
	            else thr_data(20) when thr_data_mux = "10100"
	            else thr_data(21) when thr_data_mux = "10101"
	            else thr_data(22) when thr_data_mux = "10110"
	            else thr_data(23) when thr_data_mux = "10111"
	            else thr_data(24) when thr_data_mux = "11000"
	            else thr_data(25) when thr_data_mux = "11001"
	            else thr_data(26) when thr_data_mux = "11010"
	            else thr_data(27) when thr_data_mux = "11011"
	            else thr_data(28) when thr_data_mux = "11100"
	            else thr_data(29) when thr_data_mux = "11101"
	            else thr_data(30) when thr_data_mux = "11110"
	            else thr_data(31);

	srl16e_dclr : srl16e
	generic map(init => x"0000")
	port map(
		d => clr,
		a0 => '1',
		a1 => '1',
		a2 => '1',
		a3 => '1',
		ce => '1',
		clk => clk,
		q => dclr
	);

	lut4_mux_sck : LUT4
	generic map(init => x"07F8")
	port map(
		i0 => cnt(0),
		i1 => cnt(1),
		i2 => cnt(2),
		i3 => cnt(3),
		o => imux_sck
	);

	hv_dac_data <= hv_dac_data_reg;
	hv_dac_write <= hv_dac_write_reg;
	thr_dac_data <= thr_dac_data_reg;
	thr_dac_ch <= thr_dac_ch_reg;
	thr_dac_write <= thr_dac_write_reg;
	drs_dac_write <= drs_dac_write_reg;
	mux_sck <= mux_sck_reg;
	mux_sdi <= sdat(3);

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity clock is port(
	signal p_mgt_def : in std_logic;
	signal p_mgt_loss : in std_logic;
	signal p_mgt_txdis_l : in std_logic;
	signal p_clk : in std_logic;
	signal clk : out std_logic;
	signal p_mgt_def_l : out std_logic;
	signal p_mgt_loss_l : out std_logic;
	signal p_mgt_txdis : out std_logic
); end clock;

architecture Behavioral of clock is

signal mgt_def : std_logic;
signal mgt_loss : std_logic;
signal mgt_txdis : std_logic;

begin

	ibuf_mgt_def : ibuf port map(i => p_mgt_def, o => mgt_def);
	ibuf_mgt_loss : ibuf port map(i => p_mgt_loss, o => mgt_loss);
	ibuf_mgt_txdis : ibuf port map(i => p_mgt_txdis_l, o => mgt_txdis);

	bufg_clk : bufg port map(i => p_clk, o => clk);

	obuf_mgt_def : obuf port map(i => mgt_def, o => p_mgt_def_l);
	obuf_mgt_loss : obuf port map(i => mgt_loss, o => p_mgt_loss_l);
	obuf_mgt_txdis : obuf port map(i => mgt_txdis, o => p_mgt_txdis);

end Behavioral;


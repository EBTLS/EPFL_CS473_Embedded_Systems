library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_clk_divider is
end entity;

architecture tb of tb_clk_divider is
    component clk_divider is
        generic (
            divider : integer := 5000);
        port(
            clk        : in std_logic;
            nReset      : in std_logic;
            clk_en     : out std_logic -- 1 hz
        );
    end component;

    signal clk : std_logic;
    signal nReset : std_logic;
    signal clk_en : std_logic;

begin
    dut: clk_divider generic map(5) port map(clk, nReset, clk_en);
    clk_gen: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    stimuli: process
    begin
        nReset <= '0';
        wait for 20 ns;
        nReset <= '1';
        wait for 10000 ns;
    end process;

end tb;


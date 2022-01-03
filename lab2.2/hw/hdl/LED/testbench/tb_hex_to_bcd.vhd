library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_hex_to_bcd is
end entity;

architecture tb of tb_hex_to_bcd is
    component hex_to_bcd is
        port(
            hex : in std_logic_vector(5 downto 0);
            bcd_high : out std_logic_vector(3 downto 0);
            bcd_low  : out std_logic_vector(3 downto 0)
        );
    end component;

    signal hex : std_logic_vector(5 downto 0);
    signal bcd_high : std_logic_vector(3 downto 0);
    signal bcd_low : std_logic_vector(3 downto 0);

begin
    dut: hex_to_bcd port map(hex, bcd_high, bcd_low);
    stimuli:process
    begin
        hex <= "111000";
        wait for 5 ns;
        hex <= "010111";
        wait for 5 ns;
    end process;

end tb;

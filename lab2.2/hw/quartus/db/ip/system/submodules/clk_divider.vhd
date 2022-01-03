library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_divider is
    generic (
        divider : integer := 5000);
    port(
        clk        : in std_logic;
        nReset      : in std_logic;
        clk_en     : out std_logic -- 1 hz
    );
end entity;

architecture behavioral of clk_divider is

    signal cnt_reg : integer range 0 to divider-1 := 0;

begin
        process(clk, nReset)
            variable temp_en : std_logic := '0';
        begin
            if(nReset = '0')then
                cnt_reg <= 0;
                temp_en := '0';
                elsif rising_edge(clk) then
                    if cnt_reg = divider-1 then
                        temp_en := '1';
                        cnt_reg <= 0;
                    else
                        cnt_reg <= cnt_reg + 1;
                        temp_en := '0';
                    end if;
            end if;
            clk_en <= temp_en;
        end process;
end behavioral;



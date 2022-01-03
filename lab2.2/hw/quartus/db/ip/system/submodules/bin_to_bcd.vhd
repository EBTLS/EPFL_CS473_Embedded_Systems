library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_to_bcd is
    port(
        bin : in std_logic_vector(5 downto 0);
        bcd_high : out std_logic_vector(3 downto 0);
        bcd_low  : out std_logic_vector(3 downto 0)
    );
end entity;

architecture behavioral of bin_to_bcd is
    --signal bcd_cnt : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(bin)
        variable var_bin : std_logic_vector(5 downto 0);
        variable bcd_cnt    : std_logic_vector(7 downto 0);
    begin
        bcd_cnt := (others => '0');
        var_bin := bin(5 downto 0);

        for i in var_bin'range loop
            if(bcd_cnt(7 downto 4) > "0100") then
                bcd_cnt(7 downto 4) := std_logic_vector(unsigned( bcd_cnt(7 downto 4) ) + 3);
            end if;
            if(bcd_cnt(3 downto 0) > "0100") then
                bcd_cnt(3 downto 0) := std_logic_vector(unsigned( bcd_cnt(3 downto 0) ) + 3);
            end if;
            bcd_cnt(7 downto 0) := bcd_cnt(6 downto 0) & var_bin(5);
            var_bin := var_bin(4 downto 0) & '0';
        end loop;
            bcd_high <= std_logic_vector(bcd_cnt(7 downto 4));
            bcd_low <= std_logic_vector(bcd_cnt(3 downto 0));
        end process;


end behavioral;
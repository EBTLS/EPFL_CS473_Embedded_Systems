library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decode_seg is
    port(
        bcd     :   in   std_logic_vector(3 downto 0);
        SelSeg  :   out  std_logic_vector(7 downto 0)
        
    );
end entity;

architecture behavioral of decode_seg is
begin
    process(bcd)
    begin
        case (bcd(3 downto 0)) is
            when "0000" => SelSeg <= "00111111";
            when "0001" => SelSeg <= "00000110";
            when "0010" => SelSeg <= "01011011";
            when "0011" => SelSeg <= "01001111";
            when "0100" => SelSeg <= "01100110";
            when "0101" => SelSeg <= "01101101";
            when "0110" => SelSeg <= "01111101";
            when "0111" => SelSeg <= "00000111";
            when "1000" => SelSeg <= "01111111";
            when "1001" => SelSeg <= "01101111";
            when others => SelSeg <= "00000000";       
        end case;
    end process;



end behavioral;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_control is
    port(
        clk             :   in      std_logic;
        nReset          :   in      std_logic;
        clk_en          :   in      std_logic;

        bcd_hr_high     :   in      std_logic_vector(3 downto 0);
        bcd_hr_low      :   in      std_logic_vector(3 downto 0);
        bcd_min_high    :   in      std_logic_vector(3 downto 0);
        bcd_min_low     :   in      std_logic_vector(3 downto 0);
        bcd_sec_high    :   in      std_logic_vector(3 downto 0);
        bcd_sec_low     :   in      std_logic_vector(3 downto 0);

        SelSeg          :   out     std_logic_vector(7 downto 0);
        nSelDig         :   out     std_logic_vector(5 downto 0);
        Reset_Led       :   out     std_logic
    );
end entity;

architecture behavioral of display_control is
    component decode_seg is
        port(
            bcd     :   in   std_logic_vector(3 downto 0);
            SelSeg  :   out  std_logic_vector(7 downto 0)
            
        );
    end component;

    signal bcd   : std_logic_vector(3 downto 0);
    signal cnt_digit  : std_logic_vector(2 downto 0) := (others => '0');
    signal switch_flag : std_logic_vector(3 downto 0) := (others => '0');

begin
    switch_digit: process(clk, nReset, switch_flag, cnt_digit)
    begin
        if nReset = '0' then
            cnt_digit <= (others => '0');
            switch_flag <= (others => '0');
        elsif rising_edge(clk) then
            if clk_en = '1' then
                if switch_flag = "1001" then
                    switch_flag <= (others => '0');
                    if cnt_digit = "101" then
                        cnt_digit <= (others => '0');
                    else
                        cnt_digit <= std_logic_vector(unsigned(cnt_digit) + 1);
                    end if;          
                else
                    switch_flag <= std_logic_vector(unsigned(switch_flag) + 1);
                end if;
            end if;
        end if;
    end process;

    display: process(clk, nReset)
    begin
        if nReset = '0' then
            Reset_Led <= '1';
            nSelDig <= (others => '1');
            bcd <= (others => '1');
        elsif rising_edge(clk) then
            if clk_en = '1' then
                if switch_flag = "1001" then
                    Reset_Led <= '1';
                else
                    case cnt_digit is
                        when "000" =>
                            Reset_Led <= '0';
                            nSelDig <= "111110";
                            bcd <= bcd_sec_low;
                        when "001" =>
                            Reset_Led <= '0';
                            nSelDig <= "111101";
                            bcd <= bcd_sec_high;
                        when "010" =>
                            Reset_Led <= '0';
                            nSelDig <= "111011";
                            bcd <= bcd_min_low;
                        when "011" =>
                            Reset_Led <= '0';
                            nSelDig <= "110111";
                            bcd <= bcd_min_high;
                        when "100" =>
                            Reset_Led <= '0';
                            nSelDig <= "101111";
                            bcd <= bcd_hr_low;
                        when "101" =>
                            Reset_Led <= '0';
                            nSelDig <= "011111";
                            bcd <= bcd_hr_high;
                        when others =>
                            Reset_Led <= '1';
                            nSelDig <= (others => '1');
                            bcd <= (others => '1');
                    end case;
                end if;
            end if;
        end if;
    end process;

    bcd_decode: decode_seg port map ( bcd, SelSeg);



end behavioral;

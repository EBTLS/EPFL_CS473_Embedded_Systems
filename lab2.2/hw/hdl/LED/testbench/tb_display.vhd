library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_display is
end entity;

architecture bv of tb_display is

    component display_control is
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
    end component;

    signal clk             :         std_logic;
    signal nReset          :         std_logic;
    signal clk_en          :         std_logic;

    signal bcd_hr_high     :         std_logic_vector(3 downto 0);
    signal bcd_hr_low      :         std_logic_vector(3 downto 0);
    signal bcd_min_high    :         std_logic_vector(3 downto 0);
    signal bcd_min_low     :         std_logic_vector(3 downto 0);
    signal bcd_sec_high    :         std_logic_vector(3 downto 0);
    signal bcd_sec_low     :         std_logic_vector(3 downto 0);

    signal SelSeg          :        std_logic_vector(7 downto 0);
    signal nSelDig         :        std_logic_vector(5 downto 0);
    signal Reset_Led       :        std_logic;

begin
    dut: display_control 
        port map(
            clk             => clk,
            nReset          => nReset,
            clk_en          => clk_en,

            bcd_hr_high     => bcd_hr_high,
            bcd_hr_low      => bcd_hr_low,
            bcd_min_high    => bcd_min_high,
            bcd_min_low     => bcd_min_low,
            bcd_sec_high    => bcd_sec_high,
            bcd_sec_low     => bcd_sec_low,

            SelSeg          => SelSeg,
            nSelDig         => nSelDig,
            Reset_Led       => Reset_Led
        );

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
        clk_en <= '1';

        --bcd_hr_high     <= "0001";
        --bcd_hr_low      <= "0111";
        --bcd_min_high    <= "0011";
        --bcd_min_low     <= "0010";
        --bcd_sec_high    <= "0100";
        --bcd_sec_low     <= "1000";

        bcd_hr_high     <= "0000";
        bcd_hr_low      <= "0000";
        bcd_min_high    <= "0000";
        bcd_min_low     <= "0000";
        bcd_sec_high    <= "0000";
        bcd_sec_low     <= "0000";
        --wait for 10 ns;

        --for i in 1 to 20 loop
         --   bcd_sec_low <= std_logic_vector(unsigned(bcd_sec_low) + 1);
        --    wait for 10 ns;
        --end loop;
        wait;
    end process;

end bv;




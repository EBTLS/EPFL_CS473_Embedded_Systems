library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_cnt_ctrl is
end entity;

architecture tb of tb_cnt_ctrl is
    component counter_control is
        port(
            clk             :       in      std_logic;
            nReset          :       in      std_logic;
            clk_en          :       in      std_logic; -- driven by clock divider
    
            count_en        :       in      std_logic; -- determine to start/stop counting
    
            set_value       :       in      std_logic;
            hr_in           :       in      std_logic_vector(5 downto 0);
            min_in          :       in      std_logic_vector(5 downto 0);
            sec_in          :       in      std_logic_vector(5 downto 0);
    
            bcd_hr_high     :   out      std_logic_vector(3 downto 0);
            bcd_hr_low      :   out      std_logic_vector(3 downto 0);
            bcd_min_high    :   out      std_logic_vector(3 downto 0);
            bcd_min_low     :   out      std_logic_vector(3 downto 0);
            bcd_sec_high    :   out      std_logic_vector(3 downto 0);
            bcd_sec_low     :   out      std_logic_vector(3 downto 0)
        );
    end component;


    signal clk : std_logic;
    signal nReset          :             std_logic;
    signal clk_en          :             std_logic; -- driven by clock divider
    
    signal count_en        :             std_logic; -- determine to start/stop counting
    
    signal        set_value       :             std_logic;
    signal        hr_in           :             std_logic_vector(5 downto 0);
    signal        min_in          :             std_logic_vector(5 downto 0);
    signal        sec_in          :             std_logic_vector(5 downto 0);
    
    signal        bcd_hr_high     :         std_logic_vector(3 downto 0);
    signal        bcd_hr_low      :         std_logic_vector(3 downto 0);
    signal        bcd_min_high    :         std_logic_vector(3 downto 0);
    signal        bcd_min_low     :         std_logic_vector(3 downto 0);
    signal        bcd_sec_high    :         std_logic_vector(3 downto 0);
    signal        bcd_sec_low     :         std_logic_vector(3 downto 0);

begin
    dut: counter_control port map(clk, nReset, clk_en, count_en, set_value, hr_in, min_in, sec_in, bcd_hr_high, bcd_hr_low, bcd_min_high, bcd_min_low, bcd_sec_high, bcd_sec_low);
    clk_gen: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    clk_en_gen: process
    begin
        clk_en <= '0';
        wait for 50 ns;
        clk_en <= '1';
        wait for 50 ns;
    end process;

    stimuli: process
    begin
        nReset <= '0';
        count_en <= '0';
        set_value <= '0';
        wait for 20 ns;

        nReset <= '1';
        --wait for 15 ns;


        count_en <= '1';
        wait for 600 ns;

        --count_en <= '0';

        set_value <= '1';
        hr_in <= "000010";
        min_in <= "010010";
        sec_in <= "011011";
        wait for 60 ns;
        --count_en <= '1';

        set_value <= '0';
        wait for 1000 ns;

        count_en <= '0';
        wait;

    end process;

end tb;


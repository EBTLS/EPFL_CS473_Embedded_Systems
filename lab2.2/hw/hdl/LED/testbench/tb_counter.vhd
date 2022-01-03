library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_cnt is
end entity;

architecture behavioral of tb_cnt is

    component counter_24 is
        port(
            clk         : in std_logic;
            nReset      : in std_logic;
            count_en    : in std_logic;
            cnt         : out std_logic_vector(5 downto 0)
        );
    end component;

    component counter_60 is
        port(
            clk         : in std_logic;
            nReset      : in std_logic;
            count_en    : in std_logic;
            control_in  : in std_logic;
            cnt_in      : in std_logic_vector(5 downto 0);
    
            cnt         : out std_logic_vector(5 downto 0);
            cnt_flag    : out std_logic
        );
    end component;

    signal clk : std_logic;
    signal nReset : std_logic;
    signal count_en : std_logic;
    signal cnt_60: std_logic_vector(5 downto 0);
    signal cnt_24 : std_logic_vector(5 downto 0);
    signal cnt_flag : std_logic;
    signal control_in : std_logic;
    signal cnt_in : std_logic_vector(5 downto 0);

begin
    dut_1: counter_24 port map(clk, nReset, count_en, cnt_24);
    dut: counter_60 port map(clk, nReset, count_en, control_in, cnt_in, cnt_60, cnt_flag);

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
        count_en <= '0';
        control_in <= '0';
        wait for 20 ns;
        nReset <= '1';

        --count_en <= '1';
        

        control_in <= '1';
        cnt_in <= "010111";
        wait for 10 ns;
        control_in <= '0';
        count_en <= '1';
        wait;

        --count_en <= '1';
        --wait;
        
    end process ;

end behavioral;


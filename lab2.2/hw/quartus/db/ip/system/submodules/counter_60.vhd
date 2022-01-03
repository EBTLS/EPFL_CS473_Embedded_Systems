library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity counter_60 is
    port(
        clk         : in std_logic;
        nReset      : in std_logic;
        count_en    : in std_logic;
        control_in  : in std_logic;
        cnt_in      : in std_logic_vector(5 downto 0);

        cnt         : out std_logic_vector(5 downto 0);
        cnt_flag    : out std_logic
    );
end entity;

architecture behavioral of counter_60 is
begin
    process(clk, nReset)
        variable var_cnt : std_logic_vector(5 downto 0) := (others => '0');
    begin
        if nReset = '0' then
            cnt <= (others => '0');
            var_cnt := (others => '0');
            cnt_flag <= '0';
            
        elsif rising_edge(clk) then
            if control_in = '1' then
                var_cnt := cnt_in;
            elsif var_cnt = "111011" then
                var_cnt := (others => '0');
                cnt_flag <= '1';
                elsif count_en = '1' then
                    var_cnt := var_cnt + "000001";
                    cnt_flag <= '0';               
            end if;
            cnt <= var_cnt;
        end if;
        
    end process;
end behavioral;


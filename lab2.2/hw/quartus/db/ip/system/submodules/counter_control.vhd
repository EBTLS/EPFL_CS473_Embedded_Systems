library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_control is
    port(
        clk             :       in      std_logic;
        nReset          :       in      std_logic;
        clk_en          :       in      std_logic; -- driven by clock divider

        count_en        :       in      std_logic; -- determine to start/stop counting

        set_value       :       in      std_logic;

        hr_in           :       in      std_logic_vector(5 downto 0);
        min_in          :       in      std_logic_vector(5 downto 0);
        sec_in          :       in      std_logic_vector(5 downto 0);

        threshold_hr_in  :       in      std_logic_vector(5 downto 0);
        threshold_min_in :       in      std_logic_vector(5 downto 0);
        threshold_sec_in :       in      std_logic_vector(5 downto 0);


        bcd_hr_high     :   out      std_logic_vector(3 downto 0);
        bcd_hr_low      :   out      std_logic_vector(3 downto 0);
        bcd_min_high    :   out      std_logic_vector(3 downto 0);
        bcd_min_low     :   out      std_logic_vector(3 downto 0);
        bcd_sec_high    :   out      std_logic_vector(3 downto 0);
        bcd_sec_low     :   out      std_logic_vector(3 downto 0)
    );
end entity;

architecture behavioral of counter_control is
    component bin_to_bcd is
        port(
            bin : in std_logic_vector(5 downto 0);
            bcd_high : out std_logic_vector(3 downto 0);
            bcd_low  : out std_logic_vector(3 downto 0)
        );
    end component;

    type state_type is (INIT, COUNT, SET, STOP);
    signal state, next_state : state_type;

    
    signal cnt_sec    :   std_logic_vector(5 downto 0) := (others => '0');
    signal cnt_min    :   std_logic_vector(5 downto 0) := (others => '0');
    signal cnt_hr     :   std_logic_vector(5 downto 0) := (others => '0');

    

begin
    current_state: process(clk, nReset, clk_en)
    begin
        if(nReset = '0')then
            state <= INIT;
            elsif(rising_edge(clk)) then
                if(clk_en = '1') then
                    state <= next_state;
                end if;
        end if;
    end process;

    state_change: process(state, count_en, set_value)
    begin
        next_state <= INIT;

        case state is

            when INIT => 

                if set_value = '1' then
                    next_state <= SET;
                elsif count_en = '0' then
                    next_state <= INIT;
                else
                    next_state <= COUNT;            
                end if;
            
            when COUNT =>
                
                
                --if set_value = '1' then
                --    next_state <= SET;   
               -- elsif count_en = '0' then
                if count_en = '0' then
                    next_state <= INIT;
                else
                    next_state <= COUNT;             
                end if;
            
            when SET =>
                
                if count_en = '0' then
                    next_state <= INIT;
                else
                    next_state <= COUNT;
                end if;
            

            when others =>
                next_state <= INIT;
            
        end case;
    end process;
                

    counter_logic: process(clk, nReset, clk_en, state, sec_in, min_in, hr_in)
        variable flag : std_logic := '0';
    begin
        if nReset = '0' then
            cnt_sec <= (others => '0');
            cnt_min <= (others => '0');
            cnt_hr  <= (others => '0');
            --flag_stop <= '0';

        elsif rising_edge(clk) then
            if clk_en = '1' then
                case state is

                    when INIT =>
                        cnt_sec <= (others => '0');
                        cnt_min <= (others => '0');
                        cnt_hr  <= (others => '0');
                        --flag_stop <= '0';

                    when COUNT =>
                    flag := '0';
                    if cnt_sec = threshold_sec_in then 
                        if cnt_min = threshold_min_in then
                            if cnt_hr = threshold_hr_in then
                                cnt_sec <= cnt_sec;
                                cnt_min <= cnt_min;
                                cnt_hr  <= cnt_hr;   
                                flag := '1';         
                            end if;
                        end if;
                    end if;

                    if flag = '0' then
                        if cnt_sec = "111011" then
                            if cnt_min = "111011" then
                                if cnt_hr = "010111" then 
                                    cnt_hr <= (others => '0');
                                else
                                    cnt_hr <= std_logic_vector(unsigned(cnt_hr) + 1);
                                end if;
                                    cnt_min <= (others => '0');               
                            else
                                cnt_min <= std_logic_vector(unsigned(cnt_min) + 1);
                            end if;
                            cnt_sec <= (others => '0');
                        else
                            cnt_sec <= std_logic_vector(unsigned(cnt_sec) + 1);
                        end if;
                    end if;
                        
                    when SET =>
                        cnt_sec <= sec_in;
                        cnt_min <= min_in;
                        cnt_hr  <= hr_in;

                    when others =>
                        cnt_sec <= (others => '0');
                        cnt_min <= (others => '0');
                        cnt_hr  <= (others => '0');
                end case;
            end if;
        end if;
    end process;
                        



                

    
    sec_bcd:    bin_to_bcd port map(cnt_sec, bcd_sec_high, bcd_sec_low);

    
    min_bcd:    bin_to_bcd port map(cnt_min, bcd_min_high, bcd_min_low);


    hr_bcd:     bin_to_bcd port map(cnt_hr, bcd_hr_high, bcd_hr_low);

end behavioral;

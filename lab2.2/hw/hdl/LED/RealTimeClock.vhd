library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RealTimeClock is
    port(
        clk         : in  std_logic;
        nReset      : in  std_logic;

        -- Internal Interface (i.e. Avalon Slave)
        address     : in std_logic_vector(2 downto 0);
        write       : in std_logic;
        read        : in std_logic;
        writedata   : in std_logic_vector(7 downto 0);
        readdata    : out std_logic_vector(7 downto 0);

        -- select which of the 6 displays are to be enabled
        nSelDig     : out std_logic_vector(5 downto 0);

        -- select the elements (7 in total) available in each display
        SelSeg      : out std_logic_vector(7 downto 0); 

        Reset_Led   : out std_logic
    );
end entity;

architecture behavioral of RealTimeClock is
    component clk_divider is
        generic (
            divider : integer := 5000);
        port(
            clk        : in std_logic;
            nReset      : in std_logic;
            clk_en     : out std_logic -- 1 hz
        );
    end component;

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
    end component;

    signal iRegCount       :         std_logic_vector(7 downto 0);
    signal iRegSet         :         std_logic_vector(7 downto 0);


    signal iRegSecond      :         std_logic_vector(7 downto 0);
    signal iRegMinute      :         std_logic_vector(7 downto 0);
    signal iRegHour        :         std_logic_vector(7 downto 0);
    signal iRegThreshSec   :         std_logic_vector(7 downto 0);
    signal iRegThreshMin   :         std_logic_vector(7 downto 0);
    signal iRegThreshHour  :         std_logic_vector(7 downto 0);

    signal clk_1hz_en      :         std_logic;
    signal clk_1khz_en     :         std_logic;
    signal bcd_hr_high     :         std_logic_vector(3 downto 0);
    signal bcd_hr_low      :         std_logic_vector(3 downto 0);
    signal bcd_min_high    :         std_logic_vector(3 downto 0);
    signal bcd_min_low     :         std_logic_vector(3 downto 0);
    signal bcd_sec_high    :         std_logic_vector(3 downto 0);
    signal bcd_sec_low     :         std_logic_vector(3 downto 0);


begin
    clk_1hz: clk_divider 
        generic map(50000000) 
        port map(
            clk => clk,
            nReset => nReset,
            clk_en => clk_1hz_en
        );

    clk_1khz: clk_divider 
    generic map(5000) 
    port map(
        clk => clk,
        nReset => nReset,
        clk_en => clk_1khz_en
    );

    counter: counter_control port map
        (
            clk             => clk,
            nReset          => nReset,
            clk_en          => clk_1hz_en,

            count_en        => iRegCount(0), -- determine to start/stop counting  
            set_value       => iRegSet(0),

            
            hr_in           => iRegHour(5 downto 0),
            min_in          => iRegMinute(5 downto 0),
            sec_in          => iRegSecond(5 downto 0),

            threshold_hr_in  => iRegThreshHour(5 downto 0),
            threshold_min_in => iRegThreshMin(5 downto 0),
            threshold_sec_in => iRegThreshSec(5 downto 0),

    
            bcd_hr_high     => bcd_hr_high,
            bcd_hr_low      => bcd_hr_low,
            bcd_min_high    => bcd_min_high,
            bcd_min_low     => bcd_min_low,
            bcd_sec_high    => bcd_sec_high,
            bcd_sec_low     => bcd_sec_low
        );

    display: display_control port map
        (
            clk           => clk,
            nReset        => nReset,
            clk_en        => clk_1khz_en,
    
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
                        
    -- Avalon slave write to registers
    avalon_write: process(clk, nReset)
    begin
        if nReset = '0' then
            iRegCount  <= (others => '0');
            iRegSet    <= (others => '0');
            iRegHour   <= (others => '0');
            iRegMinute <= (others => '0');
            iRegSecond <= (others => '0');
            iRegThreshHour <= (others => '0');
            iRegThreshMin <= (others => '0');
            iRegThreshSec <= (others => '0');
            
        elsif rising_edge(clk) then
            if write = '1' then
                case address is
                    when "000" =>
                        iRegCount  <= writedata;
            
                    when "001" =>
                        iRegSet    <= writedata;
                        
                    when "010" =>
                
                        iRegSecond <= writedata;
                    when "011" =>
                        
                        iRegMinute <= writedata;
                    when "100" =>
                        
                        iRegHour   <= writedata;
                    when "101" =>
                        
                        iRegThreshSec <= writedata;
                    when "110" =>
                        iRegThreshMin <= writedata;
                    when "111" =>
                        iRegThreshHour <= writedata;
                        
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    avalon_read: process(clk)
    begin
        if rising_edge(clk) then
            readdata <= (others => '0');
            if read = '1' then
                case address is
                    when "000" =>
                        
                        readdata <= iRegCount;
                    when "001" =>
                        
                        readdata <= iRegSet;
                    --when "010" =>
                        --readdata <= iRegSecond;
                    --when "011" =>
                        --readdata <= iRegMinute;
                    --when "100" =>
                        --readdata <= iRegHour;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

end behavioral;
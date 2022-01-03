library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_rtc is
end entity;

architecture tb of tb_rtc is
    component RealTimeClock is
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
    end component;

    signal       clk         :   std_logic;
    signal       nReset      :   std_logic;
  
    signal       address     :  std_logic_vector(2 downto 0);
    signal       write       :  std_logic;
    signal       read        :  std_logic;
    signal       writedata   :  std_logic_vector(7 downto 0);
    signal       readdata    :  std_logic_vector(7 downto 0);
    signal       nSelDig     :  std_logic_vector(5 downto 0);
    signal       SelSeg      :  std_logic_vector(7 downto 0); 
    signal       Reset_Led   :  std_logic;

begin
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
        wait for 10 ns;

        nReset <= '1';
        write <= '1';
        address <= "000";
        writedata <= (others => '0');
        wait for 10 ns;

        address <= "010";
        writedata <= "00100001";
        wait for 10 ns;
        address <= "011";
        writedata <= "00001011";
        wait for 10 ns;
        address <= "100";
        writedata <= "00000010";
        wait for 10 ns;

        address <= "001";
        writedata <= "00000001";
        wait for 10 ns;

        address <= "000";
        writedata <= "00000001";
        wait for 10 ns;

        address <= "001";
        writedata <= "00000000";
        wait for 10 ns;

        address <= "101";
        writedata <= "00100110";
        wait for 10 ns;
        address <= "110";
        writedata <= "00001011";
        wait for 10 ns;
        address <= "111";
        writedata <= "00000010";
        wait for 10 ns;

        

        --address <= "000";
        --writedata <= "00000001";
        --address <= "010";
        --writedata <= "00100001";
        --wait for 10 ns;
       -- address <= "011";
       -- writedata <= "00001011";
        --wait for 10 ns;
        --address <= "100";
        --writedata <= "00000010";
        --wait for 10 ns;
        --address <= "001";
        --writedata <= (others => '0');
        --wait for 10*100 ns;
        wait for 50000000*5 ns;
        writedata <= "00000000";
        wait for 50 ns;
    end process;

    dut: RealTimeClock 
        port map(
            clk       => clk,  
            nReset    => nReset,  
    
           
            address   => address, 
            write     => write,
            read      => read,
            writedata   => writedata,
            readdata    => readdata,
    
            
            nSelDig     => nSelDig,
    
            
            SelSeg     => SelSeg,
    
            Reset_Led   => Reset_Led
        );

end tb;

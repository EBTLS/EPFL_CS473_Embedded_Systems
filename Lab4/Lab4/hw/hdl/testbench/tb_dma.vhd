library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity tb_dma is
end entity;

architecture behavioral of tb_dma is
    component dma is
        port(
            clk    : in std_logic;
            nrst : in std_logic;
    
            -- Avalon Slave Interface
            AS_BurstAddr : in std_logic_vector(31 downto 0);
            AS_BurstLength: in std_logic_vector(8 downto 0);
            AS_DMA_en : in std_logic;
    
            -- Avalon Master Interface
            AM_addr : out std_logic_vector(31 downto 0);
            AM_BurstCount : out std_logic_vector(8 downto 0); -- 320 pixels maximum
            AM_write : out std_logic;
            AM_writedata : out std_logic_vector(31 downto 0);
            AM_waitrequest: in std_logic;
    
            -- FIFO interface
            size : in std_logic_vector(8 downto 0);
            data : in std_logic_vector(31 downto 0);
            DataAck : out std_logic
    
        );
    end component;

    signal clk :  std_logic;
    signal nrst : std_logic;

    signal AS_BurstAddr : std_logic_vector(31 downto 0);
    signal AS_BurstLength: std_logic_vector(8 downto 0);
    signal AS_DMA_en : std_logic;

    signal AM_addr : std_logic_vector(31 downto 0);
    signal AM_BurstCount : std_logic_vector(8 downto 0); -- 320 pixels maximum
    signal AM_write : std_logic;
    signal AM_writedata : std_logic_vector(31 downto 0);
    signal AM_waitrequest: std_logic;

    signal size : std_logic_vector(8 downto 0);
    signal data : std_logic_vector(31 downto 0);
    signal DataAck : std_logic;

begin
    dut: dma port map
        (
            clk   => clk,
            nrst => nrst,
    
            -- Avalon Slave Interface
            AS_BurstAddr => AS_BurstAddr,
            AS_BurstLength => AS_BurstLength,
            AS_DMA_en => AS_DMA_en,
    
            -- Avalon Master Interface
            AM_addr => AM_addr,
            AM_BurstCount => AM_BurstCount,
            AM_write => AM_write,
            AM_writedata => AM_writedata,
            AM_waitrequest => AM_waitrequest,
    
            -- FIFO interface
            size => size,
            data => data,
            DataAck => DataAck
        );

    clk_gen: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    -- FIFO simulation
    fifo: process(nrst, clk)
    begin
        if nrst = '0' then
            size <= AS_BurstLength;
            data <= (others => '0');
        elsif rising_edge(clk) then
            if DataAck = '1' then
                size <= std_logic_vector(unsigned(size) - 1);
                data <= std_logic_vector(unsigned(data) + 1);
            end if;
        end if;
    end process;

    stimuli: process
    begin
        nrst <= '1';
        AS_DMA_en <= '0';
        AS_BurstAddr <= X"00000010";
        AS_BurstLength <= std_logic_vector(to_unsigned(10, 9));
        AM_waitrequest <= '0';
        --data <= (others => '1');
        wait for 20 ns;

        nrst <= '0';
        wait for 10 ns;

        nrst <= '1';

        AS_DMA_en <= '1';
        wait for 100 ns;
        AM_waitrequest <= '1';
        wait for 10 ns;

        AS_DMA_en <= '0';
        wait for 20 ns;

        AS_DMA_en <= '1';
        AS_BurstAddr <= X"00000020";
        AS_BurstLength <= std_logic_vector(to_unsigned(10, 9));
        AM_waitrequest <= '0';
        wait;
        

        

        --wait for 200 ns;
        
        wait;
        --AM_waitrequest <= '1';
        --wait;

    end process;
end behavioral;

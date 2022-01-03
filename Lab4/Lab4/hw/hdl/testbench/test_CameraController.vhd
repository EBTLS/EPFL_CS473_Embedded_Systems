Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;

Use work.cmos_sensor_output_generator_constants.All;

Entity TestCameraController Is
End TestCameraController;

Architecture test_camera_controller Of TestCameraController Is

    component cmos_sensor_output_generator is
        generic(
            PIX_DEPTH  : positive;
            MAX_WIDTH  : positive;
            MAX_HEIGHT : positive
        );
        port(
            clk         : in  std_logic;
            reset       : in  std_logic;

            -- Avalon-MM slave
            addr        : in  std_logic_vector(2 downto 0);
            read        : in  std_logic;
            write       : in  std_logic;
            rddata      : out std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 downto 0);
            wrdata      : in  std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 downto 0);

            frame_valid : out std_logic;
            line_valid  : out std_logic;
            data        : out std_logic_vector(PIX_DEPTH - 1 downto 0)
        );
    end component;

    -- 10 MHz -> 100 ns period. Duty cycle = 1/2.
    Constant CLK_PERIOD : Time := 100 ns;
    Constant CLK_HIGH_PERIOD : Time := 50 ns;
    Constant CLK_LOW_PERIOD : Time := 50 ns;

    Signal clk : Std_logic;
    Signal reset : Std_logic;

    Signal sim_finished : Boolean := false;

    -- cmos_sensor_output_generator --------------------------------------------
    Constant PIX_DEPTH : Positive := 8;
    Constant MAX_WIDTH : Positive := 1920;
    Constant MAX_HEIGHT : Positive := 1080;
    Constant FRAME_WIDTH : Positive := 5;
    Constant FRAME_HEIGHT : Positive := 4;
    Constant FRAME_FRAME_BLANK : Positive := 1;
    Constant FRAME_LINE_BLANK : Natural := 1;
    Constant LINE_LINE_BLANK : Positive := 1;
    Constant LINE_FRAME_BLANK : Natural := 1;

    Signal nrst: std_logic;
    Signal addr : Std_logic_vector(2 Downto 0);
    Signal read : Std_logic;
    Signal write : Std_logic;
    Signal rddata : Std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 Downto 0);
    Signal wrdata : Std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 Downto 0);
    Signal frame_valid : Std_logic;
    Signal line_valid : Std_logic;
    Signal data : Std_logic_vector(PIX_DEPTH - 1 Downto 0);

    -- camera controller
    Signal Pclk : Std_logic := '0';
    Signal start : Std_logic := '0';
    Signal Mclk : Std_logic := '0';
    Signal rst : Std_logic := '0';

    Signal enable_mux : Std_logic := '0';

    Signal ack_master : Std_logic := '0';
    Signal read_fifo : Std_logic := '0';
    Signal empty_fifo : Std_logic := '0';
    Signal data_pixel : Std_logic_vector(31 Downto 0);
    Signal data_size : Std_logic_vector(2 Downto 0);

Begin
    clk_generation : Process
    Begin
        clk <= '1';
        Wait For CLK_HIGH_PERIOD;
        clk <= '0';
        Wait For CLK_LOW_PERIOD;
    End Process clk_generation;

    cmos_sensor_output_generator_inst : cmos_sensor_output_generator
        Generic Map(
            PIX_DEPTH => PIX_DEPTH,
            MAX_WIDTH => MAX_WIDTH,
            MAX_HEIGHT => MAX_HEIGHT)
        Port Map(
            clk => clk,
            reset => reset,
            addr => addr,
            read => read,
            write => write,
            rddata => rddata,
            wrdata => wrdata,
            frame_valid => frame_valid,
            line_valid => line_valid,
            data => data);

    camera_controller : Entity work.CameraController
        Port Map(
            Pclk => clk,
            start => start,
            Mclk => Mclk,
            rst => rst,
            enable_mux => enable_mux,
            fvalid => frame_valid,
            lvalid => line_valid,
            data_in => data,
            ack_master => ack_master,
            read_fifo => read_fifo,
            empty_fifo => empty_fifo,
            data_pixel => data_pixel,
            data_size => data_size
        );

    dma: entity work.dma 
        port map(
            clk    => clk,
            reset  => rst,
    
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
            size : in std_logic_vector(8 downto 0); -- 1024 words in FIFO
            data : in std_logic_vector(31 downto 0);
            DataAck : out std_logic
    
        );

    camera_slave: Entity work.AvalonSlaveCamera
        Port map (
            clk => clk,
            rst => rst,
    
            address =>
            write : In Std_logic;
            read : In Std_logic;
            writedata : In Std_logic_vector(31 Downto 0);
            readdata : Out Std_logic_vector(31 Downto 0);
    
            start_camera_controller_out : Out Std_logic;
            start_dma_out : Out Std_logic;
            dma_len_out : Out Std_logic_vector(8 Downto 0);
            dma_dest_out : Out Std_logic_vector(31 Downto 0)
    
        );
   

   sim : process
        procedure async_reset is
        begin
            wait until rising_edge(clk);
            wait for CLK_PERIOD / 4;
            reset <= '1';

            wait for CLK_PERIOD / 2;
            reset <= '0';
        end procedure async_reset;

        procedure write_register(constant ofst : in std_logic_vector;
                                 constant val  : in natural) is
        begin
            wait until falling_edge(clk);
            addr   <= ofst;
            write  <= '1';
            wrdata <= std_logic_vector(to_unsigned(val, wrdata'length));

            wait until falling_edge(clk);
            addr   <= (others => '0');
            write  <= '0';
            wrdata <= (others => '0');
        end procedure write_register;

        procedure write_register(constant ofst : in std_logic_vector;
                                 constant val  : in std_logic_vector) is
        begin
            wait until falling_edge(clk);
            addr   <= ofst;
            write  <= '1';
            wrdata <= std_logic_vector(resize(unsigned(val), wrdata'length));

            wait until falling_edge(clk);
            addr   <= (others => '0');
            write  <= '0';
            wrdata <= (others => '0');
        end procedure write_register;

        procedure read_register(constant ofst : in std_logic_vector) is
        begin
            wait until falling_edge(clk);
            addr <= ofst;
            read <= '1';

            wait until falling_edge(clk);
            addr <= (others => '0');
            read <= '0';
        end procedure read_register;

        procedure check_idle is
        begin
            read_register(CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_OFST);
            assert rddata = CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_IDLE report "Error: unit should be idle, but is busy" severity error;
        end procedure check_idle;

        procedure check_busy is
        begin
            read_register(CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_OFST);
            assert rddata = CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_BUSY report "Error: unit should be busy, but is idle" severity error;
        end procedure check_busy;

        procedure wait_clock_cycles(constant count : in positive) is
        begin
            wait for count * CLK_PERIOD;
        end procedure wait_clock_cycles;
    begin
        async_reset;

        start<='1';
        wait for CLK_PERIOD;
        enable_mux<='1';
        wait for CLK_PERIOD;

        -- configure
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_OFST, FRAME_WIDTH);
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_OFST, FRAME_HEIGHT);
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_OFST, FRAME_FRAME_BLANK);
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_OFST, FRAME_LINE_BLANK);
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_OFST, LINE_LINE_BLANK);
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_OFST, LINE_FRAME_BLANK);

        -- start generator
        write_register(CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_OFST, CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_START);
        check_busy;

        wait until falling_edge(frame_valid);
        wait until falling_edge(clk);

        sim_finished <= true;

        Wait For CLK_PERIOD * 5;
        ack_master<='1';
        wait;
    end process sim;
End Architecture test_camera_controller;
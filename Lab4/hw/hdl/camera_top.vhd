Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;
Use ieee.std_logic_unsigned.All;

Entity camera_top Is
    Port (
        Pclk : In Std_logic;
        clk : In Std_logic;
        Mclk : Out Std_logic;
        nrst : In Std_logic;

        -- signal for MUX   
        fvalid : In Std_logic;
        lvalid : In Std_logic;
        data_in : In Std_logic_vector(11 Downto 0);

        -- Avalon Master Interface
        AM_addr : Out Std_logic_vector(31 Downto 0);
        AM_BurstCount : Out Std_logic_vector(8 Downto 0); -- 320 pixels maximum
        AM_write : Out Std_logic;
        AM_writedata : Out Std_logic_vector(31 Downto 0);
        AM_waitrequest : In Std_logic;

        -- Avalon Slave Interface
        address : In Std_logic_vector(2 Downto 0);
        write : In Std_logic;
        read : In Std_logic;
        writedata : In Std_logic_vector(31 Downto 0);
        readdata : Out Std_logic_vector(31 Downto 0);
        camera_trigger_out : Out Std_logic
    );
End Entity;

Architecture behavioral Of camera_top Is
    Component dma Is
        Generic (
            BurstLength : Integer Range 1 To 320
        );
        Port (
            clk : In Std_logic;
            nrst : In Std_logic;

            -- Avalon Slave Interface
            AS_BurstAddr_in : In Std_logic_vector(31 Downto 0);
            AS_PixelNum_in : In Std_logic_vector(31 Downto 0);
            AS_DMA_enable_in : In Std_logic;

            -- Avalon Master Interface
            AM_addr_out : Out Std_logic_vector(31 Downto 0);
            AM_BurstCount_out : Out Std_logic_vector(8 Downto 0); -- 320 pixels maximum
            AM_write_out : Out Std_logic;
            AM_writedata_out : Out Std_logic_vector(31 Downto 0);
            AM_waitrequest_in : In Std_logic;

            -- flag to indicate one BURST transfer is finished
            task_end_flag_out : Out Std_logic;
            pixel_bursted_out : Out Std_logic_vector(15 Downto 0);

            -- FIFO interface
            size_in : In Std_logic_vector(10 Downto 0); -- 1024 words in FIFO
            data_in : In Std_logic_vector(31 Downto 0);
            fifo_empty_in : In Std_logic;
            DataAck_out : Out Std_logic
        );
    End Component;

    Component CameraController Is
        Port (
            Pclk : In Std_logic;
            start : In Std_logic;
            nrst : In Std_logic;

            -- signal for MUX   
            enable_mux : In Std_logic;
            fvalid : In Std_logic;
            lvalid : In Std_logic;
            data_in : In Std_logic_vector(11 Downto 0);

            -- mux output (for debugging)
            mux_data_out : Out Std_logic_vector(7 Downto 0);
            mux_enable_out : Out Std_logic_vector(3 Downto 0);

            -- Signal for pixel FIFO
            clk : In Std_logic;
            ack_master : In Std_logic;
            empty_fifo_pixel_out : Out Std_logic;
            data_pixel : Out Std_logic_vector(31 Downto 0);
            data_size : Out Std_logic_vector(10 Downto 0)
        );
    End Component;

    Component AvalonSlaveCamera Is
        Port (
        clk : In Std_logic;
        nrst : In Std_logic;

        -- standard avalon slave interface
        address : In Std_logic_vector(2 Downto 0);
        write : In Std_logic;
        read : In Std_logic;
        writedata : In Std_logic_vector(31 Downto 0);
        readdata : Out Std_logic_vector(31 Downto 0);

        -- signal from avalon master dma, indicate the given task is finished
        task_finish_ack : In Std_logic;

        -- signal from camera controller for debugging
        mux_data_in : In Std_logic_vector(7 Downto 0);
        mux_enable_in : In Std_logic_vector(3 Downto 0);
        -- average_and_combine_in : in std_logic_vector (31 downto 0);

        -- signal for setting camera controller
        start_camera_controller_out : Out Std_logic;
        start_dma_out : Out Std_logic;

        -- signal for setting avalon master dma
        dma_len_out : Out Std_logic_vector(31 Downto 0);
        dma_dest_out : Out Std_logic_vector(31 Downto 0);

        -- signal for trigger camera
        camera_trigger_out : Out Std_logic

        );
    End Component;

    -- signal for camera controller
    Signal camera_start : Std_logic;
    Signal enable_mux : Std_logic;
    Signal empty_fifo_pixel_out : Std_logic;
    Signal full_fifo_pixel_out : Std_logic;
    Signal data_size : Std_logic_vector(10 Downto 0);
    Signal data_pixel : Std_logic_vector(31 Downto 0);
    Signal mux_status : Std_logic;
    -- signal for avalon slave
    Signal start_camera_controller_out : Std_logic;
    Signal start_dma_out : Std_logic;
    Signal dma_len_out : Std_logic_vector(31 Downto 0);
    Signal dma_dest_out : Std_logic_vector(31 Downto 0);
    Signal pixel_cnt : Std_logic_vector(15 Downto 0);

    -- signal for dma
    Signal DataAck : Std_logic;
    Signal flag_task_end : Std_logic;

    -- mux output (for debugging)
    Signal mux_data_out : Std_logic_vector(7 Downto 0);
    Signal mux_enable_out : Std_logic_vector(3 Downto 0);

Begin
    camera_ctrl : CameraController
    Port Map(
        Pclk => Pclk,
        start => start_camera_controller_out,
        nrst => nrst,

        -- signal for MUX   
        enable_mux => start_dma_out,
        fvalid => fvalid,
        lvalid => lvalid,
        data_in => data_in,

        -- mux output (for debugging)
        mux_data_out => mux_data_out,
        mux_enable_out => mux_enable_out,

        -- Signal for FIFO
        clk => clk,
        ack_master => DataAck,
        empty_fifo_pixel_out => empty_fifo_pixel_out,
        data_pixel => data_pixel,
        data_size => data_size
    );

    Avalon_master : dma
    Generic Map(
        BurstLength => 3
    )
    Port Map(
        clk => clk,
        nrst => nrst,
        -- Avalon Slave Interface
        AS_BurstAddr_in => dma_dest_out,
        AS_PixelNum_in => dma_len_out,
        AS_DMA_enable_in => start_dma_out,
        -- Avalon Master Interface
        AM_addr_out => AM_addr,
        AM_BurstCount_out => AM_BurstCount, -- 320 pixels maximum
        AM_write_out => AM_write,
        AM_writedata_out => AM_writedata,
        AM_waitrequest_in => AM_waitrequest,
        -- flag to indicate one burst transfer is finished
        task_end_flag_out => flag_task_end,
        pixel_bursted_out => pixel_cnt,

        -- FIFO interface
        size_in => data_size,
        data_in => data_pixel,
        fifo_empty_in => empty_fifo_pixel_out,
        DataAck_out => DataAck
    );
    Avalon_slave : AvalonSlaveCamera
    Port Map(
        clk => clk,
        nrst => nrst,
        -- standard avalon slave interface  
        address => address,
        write => write,
        read => read,
        writedata => writedata,
        readdata => readdata,


        -- signal from avalon master dma, indicate the given task is finished
        task_finish_ack => flag_task_end,


        -- signal from camera controll for debugging
        mux_data_in => mux_data_out,
        mux_enable_in => mux_enable_out,
        -- signal for setting camera controller
        start_camera_controller_out => start_camera_controller_out,
        start_dma_out => start_dma_out,

        -- signal for setting avalon master dma
        dma_len_out => dma_len_out,
        dma_dest_out => dma_dest_out,

        -- signal for trigger camera
        camera_trigger_out => camera_trigger_out
    );

    Mclk <= clk;

End behavioral;
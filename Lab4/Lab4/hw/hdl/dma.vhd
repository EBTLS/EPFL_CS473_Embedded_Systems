Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;
Use ieee.std_logic_unsigned.All;

Entity dma Is
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
End Entity;

Architecture behavioral Of dma Is
    Type state_type Is (IDLE, WAITBURST, BURST, TASKEND);
    Signal current_state, next_state : state_type := IDLE;
    Signal base_addr : Std_logic_vector(31 Downto 0);
    Signal cnt_burst : Natural := 0;
    Signal reg_pixelnum : Natural := 0;
    Signal cnt_pixel : Natural := 0;

Begin

    change_state : Process (clk, nrst)
    Begin
        If nrst = '0' Then
            current_state <= IDLE;
        Elsif rising_edge(clk) Then
            current_state <= next_state;
        End If;
    End Process;

    state_setting : Process (current_state, AS_DMA_enable_in, size_in, cnt_burst, cnt_pixel)
    Begin
        next_state <= IDLE;
        Case current_state Is
            When IDLE =>
                If AS_DMA_enable_in = '1' Then
                    next_state <= WAITBURST;
                Else
                    next_state <= IDLE;
                End If;

            When WAITBURST =>
                If AS_DMA_enable_in = '0' Then
                    next_state <= IDLE;
                Elsif unsigned(size_in) >= BurstLength Then
                    next_state <= BURST;
                Else
                    next_state <= WAITBURST;
                End If;

            When BURST =>
                If cnt_burst = BurstLength Then -- burst finish
                    next_state <= TASKEND;
                Elsif cnt_pixel = reg_pixelnum Then -- task finish
                    next_state <= TASKEND;
                Else
                    next_state <= BURST;
                End If;

            When TASKEND =>
                If cnt_pixel = reg_pixelnum Then -- task finish
                    next_state <= IDLE;
                Else
                    next_state <= WAITBURST;
                End If;
            When Others =>
                next_state <= IDLE;

        End Case;
    End Process;

    -- output process
    output_process : Process (current_state, data_in, base_addr, size_in, AM_waitrequest_in)
        Variable var_burstlen : Std_logic_vector(31 Downto 0) := Std_logic_vector(to_unsigned(BurstLength, 32));
    Begin
        Case current_state Is
            When IDLE =>
                task_end_flag_out <= '0';
                DataAck_out <= '0';
                AM_writedata_out <= (Others => '0');
                AM_addr_out <= (Others => '0');
                AM_write_out <= '0';
                AM_BurstCount_out <= (Others => '0');
            When WAITBURST =>
                task_end_flag_out <= '0';
                DataAck_out <= '0';
                AM_addr_out <= base_addr;
                AM_writedata_out <= data_in;
                AM_BurstCount_out <= Std_logic_vector(to_unsigned(BurstLength + 1, 9));
                If unsigned(size_in) >= BurstLength Then
                    AM_write_out <= '1';
                Else
                    AM_write_out <= '0';
                End If;
            When BURST =>
                If cnt_pixel = reg_pixelnum Then
                    task_end_flag_out <= '1';
                Else
                    task_end_flag_out <= '0';
                End If;
                If (AM_waitrequest_in = '0') Then
                    AM_write_out <= '1';
                    DataAck_out <= '1';
                    AM_BurstCount_out <= Std_logic_vector(to_unsigned(BurstLength + 1, 9));
                    AM_writedata_out <= data_in;
                    AM_addr_out <= base_addr;
                Else
                    AM_write_out <= '0';
                    DataAck_out <= '0';
                    AM_addr_out <= base_addr;
                    AM_writedata_out <= data_in;
                    AM_BurstCount_out <= Std_logic_vector(to_unsigned(BurstLength + 1, 9));
                End If;
            When TASKEND =>
                If cnt_pixel = reg_pixelnum Then
                    task_end_flag_out <= '1';
                Else
                    task_end_flag_out <= '0';
                End If;
                DataAck_out <= '0';
                AM_write_out <= '0';
                AM_addr_out <= base_addr;
                AM_writedata_out <= data_in;
                AM_BurstCount_out <= (Others => '0');
            When Others => Null;
        End Case;
    End Process;

    -- inside register setting process
    cnt_changing : Process (nrst, clk, current_state, AS_DMA_enable_in, AS_PixelNum_in, AS_BurstAddr_in, AM_waitrequest_in)
        Variable var_burstlen : Std_logic_vector(31 Downto 0) := Std_logic_vector(to_unsigned(BurstLength, 32));
    Begin
        If (nrst = '0') Then
            cnt_pixel <= 0;
            cnt_burst <= 0;
            base_addr <= (Others => '0');
            reg_pixelnum <= 0;
        Elsif rising_edge(clk) Then
            Case current_state Is
                When IDLE =>
                    cnt_pixel <= 0;
                    cnt_burst <= 0;
                    If (AS_DMA_enable_in = '1') Then
                        base_addr <= AS_BurstAddr_in;
                        reg_pixelnum <= to_integer(unsigned(AS_PixelNum_in));
                    Else
                        base_addr <= (Others => '0');
                        reg_pixelnum <= 0;
                    End If;
                When WAITBURST =>
                    cnt_burst <= 0;
                    cnt_pixel <= cnt_pixel;
                    base_addr <= base_addr;
                    reg_pixelnum <= reg_pixelnum;
                When BURST =>
                    base_addr <= base_addr;
                    reg_pixelnum <= reg_pixelnum;
                    If (AM_waitrequest_in = '0') Then
                        cnt_burst <= cnt_burst + 1;
                        cnt_pixel <= cnt_pixel + 1;
                    Else
                        cnt_burst <= cnt_burst;
                        cnt_pixel <= cnt_pixel;
                    End If;
                When TASKEND =>
                    base_addr <= base_addr + 4 * (BurstLength + 1);
                When Others => Null;
            End Case;
        End If;
    End Process;

    pixel_bursted_out <= Std_logic_vector(to_unsigned(reg_pixelnum, 16));

End behavioral;
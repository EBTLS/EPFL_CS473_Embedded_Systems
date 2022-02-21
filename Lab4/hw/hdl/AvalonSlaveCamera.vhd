Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;

Entity AvalonSlaveCamera Is
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
End Entity;

Architecture arch_avalon_slave_camera Of AvalonSlaveCamera Is

    Signal start_reg : Std_logic_vector(31 Downto 0) := (Others => '0');
    Signal dma_len_reg : Std_logic_vector(31 Downto 0) := (Others => '0');
    Signal dma_dest_address : Std_logic_vector(31 Downto 0) := (Others => '0');
    Signal clear_task_flag : Std_logic := '0';
    Signal task_finished_flag : Std_logic := '0'; -- read only
    Signal camera_trigger_reg : Std_logic := '0';
    Signal pixel_counter : Std_logic_vector(31 Downto 0) := (Others => '0');

Begin

    avalon_write : Process (clk, nrst)
    Begin
        If nrst = '0' Then
            start_reg <= (Others => '0');
            dma_len_reg <= (Others => '0');
            dma_dest_address <= (Others => '0');
            clear_task_flag <= '0';
        Elsif rising_edge(clk) Then
            -- if task_finished_flag has already been cleaned, goto 0s
            If task_finished_flag = '0' Then
                clear_task_flag <= '0';
            Else
                clear_task_flag <= clear_task_flag;
            End If;
            If write = '1' Then
                Case address Is
                    When "000" =>
                        start_reg <= writedata;
                    When "001" =>
                        dma_len_reg <= writedata;
                    When "010" =>
                        dma_dest_address <= writedata;
                    When "011" =>
                        clear_task_flag <= writedata (0);
                    When "100" => Null;
                    When "101" =>
                        camera_trigger_reg <= writedata (0);
                    When Others => Null;
                End Case;
            Elsif task_finish_ack = '1' Then
                start_reg <= (Others => '0');
                dma_len_reg <= (Others => '0');
                dma_dest_address <= (Others => '0');
                clear_task_flag <= '0';
            End If;
        End If;
    End Process;

    avalon_read : Process (clk, nrst)
    Begin
        If nrst = '0' Then
            readdata <= (Others => '0');
        Elsif rising_edge(clk) Then
            If read = '1' Then
                Case address Is
                    When "000" =>
                        readdata <= start_reg;
                    When "001" =>
                        readdata <= dma_len_reg;
                    When "010" =>
                        readdata <= dma_dest_address;
                    When "011" =>
                        readdata <= (0 => clear_task_flag, Others => '0');
                    When "100" =>
                        readdata <= (0 => task_finished_flag, Others => '0');
                    When "101" =>
                        readdata <= (0 => camera_trigger_reg, Others => '0');
                    When "110" =>
                        readdata <= pixel_counter;
                    When Others => Null;
                End Case;
            End If;
        End If;
    End Process;

    output_setting : Process (nrst, start_reg, dma_len_reg, dma_dest_address, camera_trigger_reg, task_finished_flag)
    Begin

        If nrst = '0' Then

            start_dma_out <= '0';
            start_camera_controller_out <= '0';
            dma_len_out <= (Others => '0');
            dma_dest_out <= (Others => '0');
            camera_trigger_out <= camera_trigger_reg;

        Elsif (task_finished_flag = '1') Then
            start_dma_out <= '0';
            start_camera_controller_out <= '0';
            dma_len_out <= dma_len_reg;
            dma_dest_out <= dma_dest_address;
            camera_trigger_out <= camera_trigger_reg;
        Else
            start_dma_out <= start_reg(4);
            start_camera_controller_out <= start_reg(0);
            dma_len_out <= dma_len_reg;
            dma_dest_out <= dma_dest_address;
            camera_trigger_out <= camera_trigger_reg;
        End If;

        -- Elsif (rising_edge(clk)) Then

        --     If (task_finished_flag = '1') Then
        --         start_dma_out <= '0';
        --         start_camera_controller_out <= '0';
        --         dma_len_out <= (Others => '0');
        --         dma_dest_out <= (Others => '0');
        --         camera_trigger_out <= camera_trigger_reg;
        --     Else
        --         start_dma_out <= start_reg(4);
        --         start_camera_controller_out <= start_reg(0);
        --         dma_len_out <= dma_len_reg;
        --         dma_dest_out <= dma_dest_address;
        --         camera_trigger_out <= camera_trigger_reg;
        --     End If;

    -- End If;

End Process;

task_flag_setting : Process (clk,nrst, clear_task_flag, task_finish_ack)
Begin

    If nrst = '0' Then
        task_finished_flag <= '0';
    Elsif rising_edge(clk) then
        if task_finish_ack = '1' Then
            task_finished_flag <= '1';
        Elsif clear_task_flag = '1' Then
            task_finished_flag <= '0';
        Else
            task_finished_flag <= task_finished_flag;
        end if;
    End If;
End Process;

pixel_counter <= ("00000000000000000000" & mux_data_in & mux_enable_in);

End Architecture;
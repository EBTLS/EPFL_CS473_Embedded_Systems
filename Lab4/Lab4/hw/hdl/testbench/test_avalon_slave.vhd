Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;

Entity test_avalon_slave Is

End Entity;

Architecture test Of test_avalon_slave Is

    Constant CLK_PERIOD : Time := 100 ns;
    Signal clk : Std_logic := '0';
    Signal nrst : Std_logic := '0';

    Signal address : Std_logic_vector(2 Downto 0) := (Others => '0');
    Signal write : Std_logic := '0';
    Signal read : Std_logic := '0';

    Signal writedata : Std_logic_vector(31 Downto 0) := (Others => '0');
    Signal readdata : Std_logic_vector(31 Downto 0) := (Others => '0');

    Signal task_ack_in : Std_logic := '0';

    Signal start_camera_controller_out : Std_logic := '0';
    Signal start_dma_out : Std_logic := '0';
    Signal dma_len_out : Std_logic_vector(31 Downto 0) := (Others => '0');
    Signal dma_dest_out : Std_logic_vector(31 Downto 0) := (Others => '0');

    signal camera_trigger_out : std_logic :='0';

Begin

    avalon_slave_1 : Entity work.AvalonSlaveCamera
        Port Map(
            clk => clk,
            nrst => nrst,
            address => address,
            write => write,
            read => read,
            writedata => writedata,
            readdata => readdata,

            task_ack_in => task_ack_in,
            start_camera_controller_out => start_camera_controller_out,
            start_dma_out => start_dma_out,
            dma_len_out => dma_len_out,
            dma_dest_out => dma_dest_out,
            camera_trigger_out => camera_trigger_out
        );

    clk_generation : Process
    Begin

        If (clk = '1') Then
            clk <= '0';
        Elsif (clk = '0') Then
            clk <= '1';
        End If;

        Wait For CLK_PERIOD/2;

    End Process; -- clk_generation

    simulation : Process
        Procedure async_reset Is
        Begin

            Wait Until rising_edge(CLK);
            Wait For CLK_PERIOD / 4;
            nrst <= '0';
            Wait For CLK_PERIOD / 2;
            nrst <= '1';

        End Procedure async_reset;
    Begin
        async_reset;
        Wait For CLK_PERIOD/4;
        Wait For 1 ns;

        -- test start_reg
        write <= '1';
        address <= "000";
        writedata <= (4 => '1', 0 => '1', Others => '0');
        Wait For CLK_PERIOD;
        -- writedata <= (Others => '0');
        Wait For CLK_PERIOD;
        write <= '0';
        Wait For CLK_PERIOD;

        -- test dma_len_reg
        write <= '1';
        address <= "001";
        writedata <= (8 => '1', Others => '0');
        Wait For CLK_PERIOD;
        -- writedata <= (Others => '0');
        Wait For CLK_PERIOD;
        write <= '0';
        Wait For CLK_PERIOD;

        -- test dma_dst_reg
        write <= '1';
        address <= "010";
        writedata <= (31 => '1', Others => '0');
        Wait For CLK_PERIOD;
        -- writedata <= (Others => '0');
        Wait For CLK_PERIOD;
        write <= '0';
        Wait For CLK_PERIOD;

        -- test ack
        task_ack_in <= '1';
        Wait For 1 ns;
        read <= '1';
        address <= "100";
        Wait For CLK_PERIOD;
        task_ack_in <= '0';
        read <= '0';
        write <= '1';
        address <= "011";
        writedata <= (0 => '1', Others => '0');
        Wait For CLK_PERIOD;
        write <= '0';
        read <= '1';
        address <= "100";
        Wait For CLK_PERIOD;

        -- test toggle
        write <= '1';
        address <= "101";
        writedata <= (0 => '1', Others => '0');
        Wait For CLK_PERIOD;
        write <= '0';
        read <= '1';
        Wait For CLK_PERIOD;

        Wait;

    End Process;

End Architecture;
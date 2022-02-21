Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;
Use ieee.std_logic_unsigned.All;

Entity TestStage1 Is
End TestStage1;
Architecture test_stage_1 Of TestStage1 Is

    Constant CLK_PERIOD : Time := 100 ns;

    Signal clk : Std_logic := '0';
    Signal start : Std_logic := '0';
    Signal enable_mux_in : Std_logic := '0';
    Signal rst : Std_logic := '0';

    -- signal for camera mux module
    Signal data_mux_in : Std_logic_vector(7 Downto 0);
    Signal data_mux_out : Std_logic_vector(7 Downto 0);
    Signal enable_mux_out : Std_logic_vector(3 Downto 0);
    Signal fvalid : Std_logic := '0';
    Signal lvalid : Std_logic := '0';

    -- Signal for fifo for r and g1
    Signal data_r_out : Std_logic_vector(7 Downto 0);
    Signal data_g1_out : Std_logic_vector(7 Downto 0);
    Signal full_r : Std_logic;
    Signal empty_r : Std_logic;
    Signal usedw_r : Std_logic_vector(2 Downto 0);
    Signal full_g1 : Std_logic;
    Signal empty_g1 : Std_logic;
    Signal usedw_g1 : Std_logic_vector(2 Downto 0);
    Signal full : Std_logic;

    -- signal for b and g2 registers
    Signal enable_b_out : Std_logic;
    Signal enable_g2_out : Std_logic;
    Signal data_b_out : Std_logic_vector(7 Downto 0);
    Signal data_g2_out : Std_logic_vector(7 Downto 0);

    -- signal for average and combine module
    Signal readr_ac_out : Std_logic;
    Signal readg1_ac_out : Std_logic;
    Signal wrdata_ac_out : Std_logic_vector(31 Downto 0);
    Signal wrfifo_ac_out : Std_logic;

    -- Signal for fifo for average output
    Signal full_pixel : Std_logic;
    Signal empty_pixel : Std_logic;
    Signal usedw_pixel : Std_logic_vector(2 Downto 0);
    Signal q_pixel : Std_logic_vector(31 Downto 0);
    Signal rdreq_pixel : Std_logic := '0';

Begin

    camera_mux : Entity work.CameraMux
        Port Map(
            clk => clk,
            rst => rst,
            enable_in => enable_mux_in,

            fvalid => fvalid,
            lvalid => lvalid,
            data_in => data_mux_in,

            data_out => data_mux_out,
            enable_out => enable_mux_out
        );

    fifo_g1 : Entity work.FIFO8_8
        Port Map(
            clock => clk,
            aclr => rst,
            data => data_mux_out,
            rdreq => readg1_ac_out,
            wrreq => enable_mux_out(0),
            empty => empty_g1,
            full => full_g1,
            q => data_g1_out,
            usedw => usedw_g1
        );

    fifo_r : Entity work.FIFO8_8
        Port Map(
            clock => clk,
            aclr => rst,
            data => data_mux_out,
            rdreq => readr_ac_out,
            wrreq => enable_mux_out(1),
            empty => empty_r,
            full => full_r,
            q => data_r_out,
            usedw => usedw_r
        );
    pixel_register_b : Entity work.PixelRegister
        Port Map(
            clk => clk,
            enable_in => enable_mux_out(2),
            rst => rst,

            data_in => data_mux_out,
            data_out => data_b_out,
            enable_out => enable_b_out
        );

    pixel_register_g2 : Entity work.PixelRegister
        Port Map(
            clk => clk,
            enable_in => enable_mux_out(3),
            rst => rst,

            data_in => data_mux_out,
            data_out => data_g2_out,
            enable_out => enable_g2_out
        );
    average_and_combinie : Entity work.AverageAndCombine
        Port Map(
            clk => clk,
            start => start,
            enable => enable_b_out,
            rst => rst,

            data_r => data_r_out,
            read_r => readr_ac_out,
            data_g1 => data_g1_out,
            read_g1 => readg1_ac_out,
            data_b => data_b_out,
            data_g2 => data_g2_out,

            wrdata => wrdata_ac_out,
            wrfifo => wrfifo_ac_out
        );

    fifo_pixel : Entity work.FIFO32_8
        Port Map(
            aclr => rst,
            clock => clk,
            data => wrdata_ac_out,
            rdreq => rdreq_pixel,
            wrreq => wrfifo_ac_out,
            empty => empty_pixel,
            full => full_pixel,
            q => q_pixel,
            usedw => usedw_pixel
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
            rst <= '1';
            Wait For CLK_PERIOD / 2;
            rst <= '0';

        End Procedure async_reset;
    Begin

        async_reset;

        Wait For CLK_PERIOD /4;
        start <= '1';
        Wait For CLK_PERIOD;
        enable_mux_in <= '1';
        Wait For CLK_PERIOD;

        -- start transmission
        fvalid <= '1';
        Wait For CLK_PERIOD * 5;

        Wait For CLK_PERIOD /2;

        -- start first line
        lvalid <= '1';
        data_mux_in <= "00000001";
        Wait For CLK_PERIOD;
        data_mux_in <= "00000010";
        Wait For CLK_PERIOD;
        data_mux_in <= "00000010";
        Wait For CLK_PERIOD;
        data_mux_in <= "00000100";
        Wait For CLK_PERIOD;
        lvalid <= '0';
        data_mux_in <= "00000000";

        Wait For CLK_PERIOD;

        -- start the second line
        lvalid <= '1';
        data_mux_in <= "00000100";
        Wait For CLK_PERIOD;
        data_mux_in <= "00000001";
        Wait For CLK_PERIOD;
        data_mux_in <= "00001000";
        Wait For CLK_PERIOD;
        data_mux_in <= "00000010";
        Wait For CLK_PERIOD;
        lvalid <= '0';
        Wait For CLK_PERIOD;
        fvalid <= '0';
        data_mux_in <= "00000000";

        Wait For CLK_PERIOD * 5;

        -- start the second frame
        fvalid <= '1';
        Wait For CLK_PERIOD * 5;
        -- start the first line
        lvalid <= '1';
        data_mux_in <= "00000001";
        Wait For CLK_PERIOD;
        data_mux_in <= "00000010";
        Wait For CLK_PERIOD;
        data_mux_in <= "00000010";
        Wait For CLK_PERIOD;
        data_mux_in <= "00000100";
        Wait For CLK_PERIOD;
        lvalid <= '0';
        data_mux_in <= "00000000";

        Wait For CLK_PERIOD;

        -- start the second line
        lvalid <= '1';
        data_mux_in <= "00000100";
        Wait For CLK_PERIOD;
        data_mux_in <= "00000001";
        Wait For CLK_PERIOD;
        data_mux_in <= "00001000";
        Wait For CLK_PERIOD;
        data_mux_in <= "00000010";
        Wait For CLK_PERIOD;
        lvalid <= '0';
        Wait For CLK_PERIOD;
        fvalid <= '0';
        data_mux_in <= "00000000";

        Wait For CLK_PERIOD * 5;

        rdreq_pixel <= '1';

        Wait;

    End Process; -- simulation
End test_stage_1; -- test_stage_1
Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;
Use ieee.std_logic_unsigned.All;
Entity CameraController Is
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
        -- average_and_combine_out : in std_logic_vector (31 downto 0);

        -- Signal for pixel FIFO
        clk : In Std_logic;
        ack_master : In Std_logic;
        empty_fifo_pixel_out : Out Std_logic;
        data_pixel : Out Std_logic_vector(31 Downto 0);
        data_size : Out Std_logic_vector(10 Downto 0)
    );
End Entity;

Architecture arch_camera_controller Of CameraController Is

    Component CameraMux Is
        Port (
            clk : In Std_logic;
            nrst : In Std_logic;
            enable_in : In Std_logic;

            -- camera inut interfaces
            fvalid : In Std_logic;
            lvalid : In Std_logic;
            data_in : In Std_logic_vector(11 Downto 0);

            -- output interfaces
            data_out : Out Std_logic_vector(7 Downto 0);
            enable_out : Out Std_logic_vector(3 Downto 0)

        );
    End Component;
    Component fifo_single_clk Is
        Port (
            aclr : In Std_logic;
            clock : In Std_logic;
            data : In Std_logic_vector (7 Downto 0);
            rdreq : In Std_logic;
            wrreq : In Std_logic;
            empty : Out Std_logic;
            full : Out Std_logic;
            q : Out Std_logic_vector (7 Downto 0);
            usedw : Out Std_logic_vector (8 Downto 0)
        );
    End Component;

    Component fifo_dual_clk Is
        Port (
            aclr : In Std_logic;
            data : In Std_logic_vector (31 Downto 0);
            rdclk : In Std_logic;
            rdreq : In Std_logic;
            wrclk : In Std_logic;
            wrreq : In Std_logic;
            q : Out Std_logic_vector (31 Downto 0);
            rdempty : Out Std_logic;
            rdusedw : Out Std_logic_vector (10 Downto 0);
            wrfull : Out Std_logic
        );
    End Component;
    -- signal for MUX
    Signal data_mux_out : Std_logic_vector(7 Downto 0);
    Signal enable_mux_out : Std_logic_vector(3 Downto 0);

    --signal for R and G1 FIFO
    Signal data_r_out : Std_logic_vector(7 Downto 0);
    Signal data_g1_out : Std_logic_vector(7 Downto 0);
    Signal full_r_out : Std_logic := '0';
    Signal empty_r_out : Std_logic := '0';
    Signal usedw_r_out : Std_logic_vector(8 Downto 0);
    Signal full_g1_out : Std_logic := '0';
    Signal empty_g1_out : Std_logic := '0';
    Signal usedw_g1_out : Std_logic_vector(8 Downto 0);
    Signal full_r_g1 : Std_logic := '0';

    -- signal for B and G2 Reg  
    Signal enable_b_out : Std_logic := '0';
    Signal data_b_out : Std_logic_vector(7 Downto 0);
    Signal enable_g2_out : Std_logic := '0';
    Signal data_g2_out : Std_logic_vector(7 Downto 0);

    -- signal for average and combine module
    Signal readr_ac_out : Std_logic := '0';
    Signal readg1_ac_out : Std_logic := '0';
    Signal wrdata_ac_out : Std_logic_vector(31 Downto 0);
    Signal wrfifo_ac_out : Std_logic := '0';

    -- Signal for pixel fifo
    Signal full_pixel : Std_logic := '0';
    Signal clear_fifo : Std_logic := '0';
Begin

    -- mux output for debugging
    mux_data_out <= data_mux_out;
    mux_enable_out <= enable_mux_out;
    -- average_and_combine_out <=wrdata_ac_out;

    clear_fifo <= Not nrst;

    camera_mux : CameraMux
    Port Map(
        clk => Pclk,
        nrst => nrst,
        enable_in => enable_mux,
        fvalid => fvalid,
        lvalid => lvalid,
        data_in => data_in,
        data_out => data_mux_out,
        enable_out => enable_mux_out
    );
    fifo_g1 : fifo_single_clk Port Map(
        aclr => clear_fifo,
        clock => Pclk,
        data => data_mux_out,
        rdreq => readg1_ac_out,
        wrreq => enable_mux_out(0),
        empty => empty_g1_out,
        full => full_g1_out,
        q => data_g1_out,
        usedw => usedw_g1_out
    );

    fifo_r : fifo_single_clk Port Map(
        aclr => clear_fifo,
        clock => Pclk,
        data => data_mux_out,
        rdreq => readr_ac_out,
        wrreq => enable_mux_out(1),
        empty => empty_r_out,
        full => full_r_out,
        q => data_r_out,
        usedw => usedw_r_out
    );

    pixel_register_b : Entity work.PixelRegister
        Port Map(
            clk => Pclk,
            enable_in => enable_mux_out(2),
            nrst => nrst,

            data_in => data_mux_out,
            data_out => data_b_out,
            enable_out => enable_b_out
        );

    pixel_register_g2 : Entity work.PixelRegister
        Port Map(
            clk => Pclk,
            enable_in => enable_mux_out(3),
            nrst => nrst,

            data_in => data_mux_out,
            data_out => data_g2_out,
            enable_out => enable_g2_out
        );

    average_and_combine : Entity work.AverageAndCombine
        Port Map(
            clk => Pclk,
            start => start,
            enable => enable_b_out,
            nrst => nrst,

            data_r => data_r_out,
            read_r => readr_ac_out,
            data_g1 => data_g1_out,
            read_g1 => readg1_ac_out,
            data_b => data_b_out,
            data_g2 => data_g2_out,

            wrdata => wrdata_ac_out,
            wrfifo => wrfifo_ac_out,
            full_pixel => full_pixel
        );

    fifo_dual_clk_inst : fifo_dual_clk Port Map(
        aclr => clear_fifo,
        data => wrdata_ac_out,
        rdclk => clk,
        rdreq => ack_master,
        wrclk => Pclk,
        wrreq => wrfifo_ac_out,
        q => data_pixel,
        rdempty => empty_fifo_pixel_out,
        rdusedw => data_size,
        wrfull => full_pixel
    );

End Architecture;
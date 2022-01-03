Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;
Use ieee.std_logic_unsigned.All;

Entity AverageAndCombine Is
    Port (
        clk : In Std_logic;
        start : In Std_logic;
        enable : In Std_logic;
        nrst : In Std_logic;

        data_r : In Std_logic_vector(7 Downto 0);
        read_r : Out Std_logic;
        data_g1 : In Std_logic_vector(7 Downto 0);
        read_g1 : Out Std_logic;
        data_b : In Std_logic_vector(7 Downto 0);
        data_g2 : In Std_logic_vector(7 Downto 0);

        wrdata : Out Std_logic_vector(31 Downto 0);
        wrfifo : Out Std_logic;
        full_pixel : In Std_logic
    );

End AverageAndCombine;
Architecture arch_average_and_combine Of AverageAndCombine Is

    Type states Is (IDLE, WAITDATA, READDATA);

    Signal state_c, state_n : states := IDLE;

    Signal output_data_reg : Std_logic_vector(31 Downto 0) := (Others => '0');
    Signal sum_g_data_reg : Std_logic_vector(8 Downto 0) := (Others => '0');
    Signal data_b_reg : Std_logic_vector(7 Downto 0)  := (Others => '0');
    Signal data_r_reg : Std_logic_vector(7 Downto 0)  := (Others => '0');
    Signal data_g1_reg : Std_logic_vector(7 Downto 0)  := (Others => '0');
    Signal data_g2_reg : Std_logic_vector(7 Downto 0)  := (Others => '0');

Begin

    change_state : Process (clk, nrst)
    Begin

        If nrst = '0' Then
            state_c <= IDLE;
        Elsif rising_edge(clk) Then
            state_c <= state_n;
        End If;

    End Process; -- change_state

    state_setting : Process (state_c, nrst, start, enable)
    Begin

        If nrst = '0' Then

            state_n <= IDLE;

        Else

            Case(state_c) Is

                When IDLE =>

                If start = '1' Then
                    state_n <= WAITDATA;
                Else
                    state_n <= state_c;
                End If;

                When WAITDATA =>

                If enable = '1' Then
                    state_n <= READDATA;
                Elsif start = '0' Then
                    state_n <= IDLE;
                Else
                    state_n <= state_c;
                End If;

                When READDATA =>

                If start = '0' Then
                    state_n <= IDLE;
                Else
                    state_n <= WAITDATA;
                End If;

                When Others => state_n <= IDLE;

            End Case;
        End If;

    End Process; -- state_setting

    output_process : Process (state_c, enable, output_data_reg, full_pixel)

    Begin

        Case(state_c) Is

            When IDLE =>

            read_r <= '0';
            read_g1 <= '0';
            wrfifo <= '0';
            wrdata <= (Others => '0');

            When WAITDATA =>

            If enable = '1' Then
                read_r <= '1';
                read_g1 <= '1';
                wrfifo <= '0';
                -- wrdata <= output_data;
                wrdata <= (Others => '0');
            Else
                read_r <= '0';
                read_g1 <= '0';
                wrfifo <= '0';
                wrdata <= (Others => '0');
            End If;

            When READDATA =>

            If start = '0' Or full_pixel = '1' Then
                read_r <= '0';
                read_g1 <= '0';
                wrfifo <= '0';
                wrdata <= (Others => '0');
            Else
                read_r <= '0';
                read_g1 <= '0';
                wrfifo <= '1';
                wrdata <= output_data_reg;
            End If;

            When Others =>

            read_r <= '0';
            read_g1 <= '0';
            wrfifo <= '0';
            wrdata <= (Others => '0');

        End Case;
    End Process; -- output_process

    data_setting: Process (state_c, enable, data_r, data_g1, data_g2, data_b, full_pixel)
    begin
        Case(state_c) Is

            When IDLE =>

                data_r_reg <= (others=>'0');
                data_g1_reg <= (others=>'0');
                data_g2_reg <= (others=>'0');
                data_b_reg <= (others=>'0');

            When WAITDATA =>

                data_r_reg <= data_r_reg;
                data_g1_reg <= data_g1_reg;
                data_b_reg <= data_b;
                data_g2_reg <= data_g2_reg;

            When READDATA =>

                data_r_reg <= data_r;
                data_g1_reg <= data_g1;
                data_b_reg <= data_b_reg;
                data_g2_reg <= data_g2;

            When Others =>

                data_r_reg <= (others=>'0');
                data_g1_reg <= (others=>'0');
                data_g2_reg <= (others=>'0');
                data_b_reg <= (others=>'0');

        End Case;
    end process;

    sum_g_data_reg <= Std_logic_vector(unsigned("0" & data_g1_reg) + unsigned("0" & data_g2_reg));
    output_data_reg <= "00000000" & data_r_reg & sum_g_data_reg(8 Downto 1) & data_b_reg;


    -- sum_g_data_reg <= Std_logic_vector(unsigned("0" & data_g1) + unsigned("0" & data_g2));
    -- output_data_reg <= "00000000" & data_r & sum_g_data_reg(8 Downto 1) & data_b;

End arch_average_and_combine; -- arch_combine_and_average
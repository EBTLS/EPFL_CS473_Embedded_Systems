Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;

Entity test_AverageAndCombine Is

End test_AverageAndCombine;

Architecture test Of test_AverageAndCombine Is

    Constant CLK_PERIOD : Time := 100 ns;

    Signal clk : Std_logic := '0';
    Signal start : Std_logic := '0';
    Signal enable : Std_logic := '0';
    Signal nrst : Std_logic := '0';

    Signal data_r : Std_logic_vector(7 Downto 0);
    Signal read_r : Std_logic;
    Signal data_g1 : Std_logic_vector(7 Downto 0);
    Signal read_g1 : Std_logic;
    Signal data_b : Std_logic_vector(7 Downto 0);
    Signal data_g2 : Std_logic_vector(7 Downto 0);

    Signal wrdata : Std_logic_vector(31 Downto 0);
    Signal wrfifo : Std_logic;

    Signal full_pixel: std_logic;

Begin

    average_and_combinie : Entity work.AverageAndCombine
        Port Map(
            clk => clk,
            start => start,
            enable => enable,
            nrst => nrst,

            data_r => data_r,
            read_r => read_r,
            data_g1 => data_g1,
            read_g1 => read_g1,
            data_b => data_b,
            data_g2 => data_g2,

            wrdata => wrdata,
            wrfifo => wrfifo,
            full_pixel => full_pixel
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
        data_r <= (Others => '0');
        data_g1 <= (Others => '0');
        data_g2 <= (Others => '0');
        data_b <= (Others => '0');
        Wait For CLK_PERIOD /4;

        start <= '1';
        Wait For CLK_PERIOD;
        Wait For 1 ns;
        -- Wait For CLK_PERIOD/2;

        enable <= '1';
        data_b <= "00000001";
        Wait For CLK_PERIOD;

        data_r<="00000001";
        data_g1<="00000001";
        data_g2 <= "00000001";
        Wait For CLK_PERIOD;

        data_b <= "00000010";
        Wait For CLK_PERIOD;

        data_r<="00000010";
        data_g1<="00000010";
        data_g2 <= "00000010";
        Wait For CLK_PERIOD;

        data_b <= "00000100";
        Wait For CLK_PERIOD;

        data_r<="00000100";
        data_g1<="00000100";
        data_g2 <= "00000100";
        wait for CLK_PERIOD;

        start<='0';
        
        Wait;

    End Process; -- simulation

End test; -- test
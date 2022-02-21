Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;

Entity test_PixelRegister Is
End test_PixelRegister;

Architecture test Of test_PixelRegister Is

    Constant CLK_PERIOD : Time := 100 ns;

    Signal clk : Std_logic := '0';
    Signal enable_in : Std_logic := '0';
    Signal nrst : Std_logic := '0';

    Signal data_in : Std_logic_vector(7 Downto 0);
    Signal data_out : Std_logic_vector(7 Downto 0);

    Signal enable_out : Std_logic;

Begin

    pixel_register : Entity work.PixelRegister
        Port Map(
            clk => clk,
            enable_in => enable_in,
            nrst => nrst,

            data_in => data_in,
            data_out => data_out,
            enable_out => enable_out
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

        data_in <= (Others => '0');

        Wait For CLK_PERIOD/4;

        Wait For CLK_PERIOD/2;

        enable_in <= '1';
        data_in <= "00000001";
        Wait For CLK_PERIOD;
        enable_in <= '0';
        Wait For CLK_PERIOD;

        enable_in <= '1';
        data_in <= "00000010";
        Wait For CLK_PERIOD;
        enable_in <= '0';
        Wait For CLK_PERIOD;

        enable_in <= '1';
        data_in <= "00000100";
        Wait For CLK_PERIOD;
        enable_in <= '0';
        Wait For CLK_PERIOD;

        wait;

    End Process; -- simulation
End test; -- test
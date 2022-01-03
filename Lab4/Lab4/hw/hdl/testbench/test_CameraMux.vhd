Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;

Entity tb_CameraMux Is

End tb_CameraMux;

Architecture arch Of tb_CameraMux Is

    Constant CLK_PERIOD : Time := 100 ns;

    Signal clk : Std_logic := '0';
    Signal nrst : Std_logic := '0';
    Signal enable_in : Std_logic := '0';

    Signal fvalid : Std_logic := '0';
    Signal lvalid : Std_logic := '0';

    Signal data_in : Std_logic_vector(11 Downto 0);
    Signal data_out : Std_logic_vector(7 Downto 0);
    Signal enable_out : Std_logic_vector(3 Downto 0);

Begin

    camera_mux : Entity work.CameraMux
        Port Map(
            clk => clk,
            nrst => nrst,
            enable_in => enable_in,

            fvalid => fvalid,
            lvalid => lvalid,

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

        Wait For CLK_PERIOD /4;

        -- enable mux
        enable_in <= '1';

        -- start transmission
        fvalid <= '1';
        Wait For CLK_PERIOD * 5;

        Wait For CLK_PERIOD /2;

        -- start first line
        lvalid <= '1';
        data_in <= "000000000001";

        Wait For CLK_PERIOD;
        data_in <= "000000000010";

        Wait For CLK_PERIOD;
        data_in <= "000000000001";

        Wait For CLK_PERIOD;
        data_in <= "000000000010";

        Wait For CLK_PERIOD;
        lvalid <= '0';

        -- start the second line
        Wait For CLK_PERIOD;
        lvalid <= '1';
        Wait For CLK_PERIOD;
        data_in <= "000000000010";

        Wait For CLK_PERIOD;
        data_in <= "000000000001";

        Wait For CLK_PERIOD;
        data_in <= "000000000010";

        Wait For CLK_PERIOD;
        lvalid <= '0';

        Wait For CLK_PERIOD;
        fvalid <= '0';

        Wait For CLK_PERIOD * 5;

        -- start the second frame
        fvalid <= '1';

        Wait For CLK_PERIOD * 5;

        -- start the first line
        lvalid <= '1';
        data_in <= "000000000001";
        Wait For CLK_PERIOD;
        data_in <= "000000000010";

        Wait For CLK_PERIOD;
        data_in <= "000000000001";

        Wait For CLK_PERIOD;
        data_in <= "000000000010";

        Wait For CLK_PERIOD;
        lvalid <= '0';

        Wait For CLK_PERIOD;

        -- start the second line
        lvalid <= '1';
        data_in <= "000000000001";

        Wait For CLK_PERIOD;
        data_in <= "000000000010";

        Wait For CLK_PERIOD;
        data_in <= "000000000001";

        Wait For CLK_PERIOD;
        data_in <= "000000000010";

        Wait For CLK_PERIOD;
        lvalid <= '0';

        Wait For CLK_PERIOD;
        fvalid <= '0';

        Wait For CLK_PERIOD;

        Wait;

    End Process; -- simulation

End arch;
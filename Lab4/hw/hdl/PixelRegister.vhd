Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;

Entity PixelRegister Is
    Port (
        clk : In Std_logic;
        enable_in : In Std_logic;
        nrst : In Std_logic;

        data_in : In Std_logic_vector(7 Downto 0);

        data_out : Out Std_logic_vector(7 Downto 0);
        enable_out : Out Std_logic

    );
End PixelRegister;

Architecture arch_pixel_register Of PixelRegister Is

Begin

    -- Process (clk, nrst, enable_in,data_in)
    -- Begin

    --     If nrst = '0' Then

    --         enable_out <= '0';
    --         data_out <= (Others => '0');

    --     Elsif rising_edge(clk) Then

    --         If enable_in = '1' Then

    --             enable_out <= '1';
    --             data_out <= data_in;

    --         else
                
    --             enable_out <= '0';

    --         End If;
    --     End If;

    -- End Process;

    Process (nrst, enable_in,data_in)
    Begin

        If nrst = '0' Then

            enable_out <= '0';
            data_out <= (Others => '0');

        Else

            If enable_in = '1' Then

                enable_out <= '1';
                data_out <= data_in;

            else
                
                enable_out <= '0';

            End If;
        End If;

    End Process;
End arch_pixel_register; -- arch_pixel_register
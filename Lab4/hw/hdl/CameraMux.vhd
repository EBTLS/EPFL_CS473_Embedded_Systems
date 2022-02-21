Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;

Entity CameraMux Is
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
End CameraMux;

Architecture arch_cameramux Of CameraMux Is

  Type states Is (IDLE, WAITDATA, G1, R, G2, B);
  Signal state_current, state_next : states := IDLE;

  Signal cnt_row, cnt_col : Std_logic := '0';

Begin

  change_state : Process (clk, nrst)
  Begin

    If (nrst = '0') Then

      state_current <= IDLE;

    Elsif rising_edge(clk) Then

      state_current <= state_next;

    End If;

  End Process;

  state_setting : Process (nrst, enable_in, fvalid, lvalid, state_current,cnt_row)
  Begin

    If nrst = '0' Then
      state_next <= IDLE;
    Else
      Case state_current Is
        When IDLE =>
          -- cnt_row <= '0';

          If (fvalid = '1') Then
            If enable_in = '1' Then
              state_next <= WAITDATA;
            Else
              state_next <= IDLE;
            End If;
          Else
            state_next <= state_current;
          End If;

        When WAITDATA =>

          -- cnt_row <= cnt_row;

          If enable_in = '0' Then
            state_next <= IDLE;
          Elsif (lvalid = '1') Then
            If cnt_row = '0' Then
              state_next <= G1;
            Elsif cnt_row = '1' Then
              state_next <= B;
            End If;
          Elsif fvalid = '0' Then
            state_next <= IDLE;
          Else
            state_next <= state_current;
          End If;

        When G1 =>

          -- cnt_row <= '1';
          If enable_in = '0' Then
            state_next <= IDLE;
          Elsif (lvalid = '1') Then
            state_next <= R;
          Elsif (lvalid = '0') Then
            state_next <= WAITDATA;
          Elsif fvalid = '0' Then
            state_next <= IDLE;
          Else
            state_next <= state_current;
          End If;

        When R =>

          -- cnt_row <= '1';
          If enable_in = '0' Then
            state_next <= IDLE;
          Elsif (lvalid = '1') Then
            state_next <= G1;
          Elsif (lvalid = '0') Then
            state_next <= WAITDATA;
          Elsif fvalid = '0' Then
            state_next <= IDLE;
          Else
            state_next <= state_current;
          End If;

        When B =>

          -- cnt_row <= '0';
          If enable_in = '0' Then
            state_next <= IDLE;
          Elsif (lvalid = '1') Then
            state_next <= G2;
          Elsif (lvalid = '0') Then
            state_next <= WAITDATA;
          Elsif fvalid = '0' Then
            state_next <= IDLE;
          Else
            state_next <= state_current;
          End If;

        When G2 =>

          -- cnt_row <= '0';
          If enable_in = '0' Then
            state_next <= IDLE;
          Elsif (lvalid = '1') Then
            state_next <= B;
          Elsif (lvalid = '0') Then
            state_next <= WAITDATA;
          Elsif fvalid = '0' Then
            state_next <= IDLE;
          Else
            state_next <= state_current;
          End If;

        When Others => Null;

      End Case;
    End If;

  End Process;

  row_setting : Process (nrst, state_current)
  Begin

    If (nrst = '0') Then
      cnt_row <= '0';
    Else
      Case state_current Is
        When IDLE =>
          cnt_row <= '0';
        When WAITDATA =>
          cnt_row <= cnt_row;
        When G1 =>
          cnt_row <= '1';
        When R =>
          cnt_row <= '1';
        When B =>
          cnt_row <= '0';
        When G2 =>
          cnt_row <= '0';
        When Others => Null;
      End Case;
    End If;
  End Process;

  output_process : Process (state_current, data_in, lvalid, cnt_row)
  Begin

    Case (state_current) Is

      When IDLE =>

        data_out <= (Others => '0');
        enable_out <= "0000";

      When WAITDATA =>
        If (lvalid = '1') Then
          If cnt_row = '0' Then
            data_out <= data_in(11 Downto 4);
            enable_out <= "0001";
          Elsif cnt_row = '1' Then
            data_out <= data_in(11 Downto 4);
            enable_out <= "0100";
          End If;
        Else
          data_out <= (Others => '0');
          enable_out <= "0000";
        End If;

      When G1 =>
        If (lvalid = '1') Then
          data_out <= data_in(11 Downto 4);
          enable_out <= "0010";
        Else
          data_out <= (Others => '0');
          enable_out <= "0000";
        End If;

      When R =>
        If (lvalid = '1') Then
          data_out <= data_in(11 Downto 4);
          enable_out <= "0001";
        Else
          data_out <= (Others => '0');
          enable_out <= "0000";
        End If;

      When B =>
        If (lvalid = '1') Then
          data_out <= data_in(11 Downto 4);
          enable_out <= "1000";
        Else
          data_out <= (Others => '0');
          enable_out <= "0000";
        End If;

      When G2 =>

        If (lvalid = '1') Then
          data_out <= data_in(11 Downto 4);
          enable_out <= "0100";
        Else
          data_out <= (Others => '0');
          enable_out <= "0000";
        End If;

      When Others =>

        data_out <= (Others => '0');
        enable_out <= "0000";

    End Case;
  End Process; -- output_process
End arch_cameramux;
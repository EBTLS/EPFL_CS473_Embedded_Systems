
Library ieee;
Use ieee.std_logic_1164.All;
Use ieee.numeric_std.All;

Use work.cmos_sensor_output_generator_constants.All;

Entity TestCameraTop Is
End TestCameraTop;

Architecture test Of TestCameraTop Is
    Component cmos_sensor_output_generator Is
        Generic (
            PIX_DEPTH : Positive;
            MAX_WIDTH : Positive;
            MAX_HEIGHT : Positive
        );
        Port (
            clk : In Std_logic;
            nreset : In Std_logic;

            -- Avalon-MM slave
            addr : In Std_logic_vector(2 Downto 0);
            read : In Std_logic;
            write : In Std_logic;
            rddata : Out Std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 Downto 0);
            wrdata : In Std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 Downto 0);

            frame_valid : Out Std_logic;
            line_valid : Out Std_logic;
            data : Out Std_logic_vector(PIX_DEPTH - 1 Downto 0)
        );
    End Component;
    -- 10 MHz -> 100 ns period. Duty cycle = 1/2.
    Constant CLK_PERIOD : Time := 100 ns;
    Constant CLK_HIGH_PERIOD : Time := 50 ns;
    Constant CLK_LOW_PERIOD : Time := 50 ns;

    Signal clk : Std_logic;
    Signal reset : Std_logic;

    Signal sim_finished : Boolean := false;

    -- cmos_sensor_output_generator --------------------------------------------
    Constant PIX_DEPTH : Positive := 12;
    Constant MAX_WIDTH : Positive := 1920;
    Constant MAX_HEIGHT : Positive := 1080;
    Constant FRAME_WIDTH : Positive := 64;
    Constant FRAME_HEIGHT : Positive := 4;
    Constant FRAME_FRAME_BLANK : Positive := 1;
    Constant FRAME_LINE_BLANK : Natural := 1;
    Constant LINE_LINE_BLANK : Positive := 1;
    Constant LINE_FRAME_BLANK : Natural := 1;

    Signal addr : Std_logic_vector(2 Downto 0);
    Signal read : Std_logic;
    Signal write : Std_logic;
    Signal rddata : Std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 Downto 0);
    Signal wrdata : Std_logic_vector(CMOS_SENSOR_OUTPUT_GENERATOR_MM_S_DATA_WIDTH - 1 Downto 0);
    Signal frame_valid : Std_logic;
    Signal line_valid : Std_logic;
    Signal data : Std_logic_vector(PIX_DEPTH - 1 Downto 0);

    -- for camera top
    --Signal nrst : Std_logic:='0';
    Signal MCLK : Std_logic;
    Signal AM_addr : Std_logic_vector(31 Downto 0);
    Signal AM_BurstCount : Std_logic_vector(8 Downto 0); -- 320 pixels maximum
    Signal AM_write : Std_logic;
    Signal AM_writedata : Std_logic_vector(31 Downto 0);
    Signal AM_waitrequest : Std_logic;

    Signal address : Std_logic_vector(2 Downto 0);
    Signal write_avalon_slave : Std_logic;
    Signal read_avalon_slave : Std_logic;
    Signal writedata : Std_logic_vector(31 Downto 0);
    Signal readdata : Std_logic_vector(31 Downto 0);
    Signal camera_trigger_out : Std_logic;

Begin
    clk_generation : Process
    Begin
        clk <= '1';
        Wait For CLK_HIGH_PERIOD;
        clk <= '0';
        Wait For CLK_LOW_PERIOD;
    End Process clk_generation;

    cmos_sensor_output_generator_inst : cmos_sensor_output_generator
    Generic Map(
        PIX_DEPTH => PIX_DEPTH,
        MAX_WIDTH => MAX_WIDTH,
        MAX_HEIGHT => MAX_HEIGHT)
    Port Map(
        clk => clk,
        nreset => reset,
        addr => addr,
        read => read,
        write => write,
        rddata => rddata,
        wrdata => wrdata,
        frame_valid => frame_valid,
        line_valid => line_valid,
        data => data);
    camera_top : Entity work.camera_top
        Port Map(
            Pclk => clk,
            clk => clk,
            Mclk => Mclk,
            nrst => reset,

            fvalid => frame_valid,
            lvalid => line_valid,
            data_in => data,

            AM_addr => AM_addr,
            AM_BurstCount => AM_BurstCount,
            AM_write => AM_write,
            AM_writedata => AM_writedata,
            AM_waitrequest => AM_waitrequest,

            address => address,
            write => write_avalon_slave,
            read => read_avalon_slave,
            writedata => writedata,
            readdata => readdata,
            camera_trigger_out => camera_trigger_out
        );
    sim : Process
        Procedure async_reset Is
        Begin
            Wait Until rising_edge(clk);
            Wait For CLK_PERIOD / 4;
            reset <= '0';

            Wait For CLK_PERIOD / 2;
            reset <= '1';
        End Procedure async_reset;

        Procedure write_register(Constant ofst : In Std_logic_vector;
        Constant val : In Natural) Is
    Begin
        Wait Until falling_edge(clk);
        addr <= ofst;
        write <= '1';
        wrdata <= Std_logic_vector(to_unsigned(val, wrdata'length));

        Wait Until falling_edge(clk);
        addr <= (Others => '0');
        write <= '0';
        wrdata <= (Others => '0');
    End Procedure write_register;

    Procedure write_register(Constant ofst : In Std_logic_vector;
    Constant val : In Std_logic_vector) Is
Begin
    Wait Until falling_edge(clk);
    addr <= ofst;
    write <= '1';
    wrdata <= Std_logic_vector(resize(unsigned(val), wrdata'length));

    Wait Until falling_edge(clk);
    addr <= (Others => '0');
    write <= '0';
    wrdata <= (Others => '0');
End Procedure write_register;

Procedure read_register(Constant ofst : In Std_logic_vector) Is
Begin
    Wait Until falling_edge(clk);
    addr <= ofst;
    read <= '1';

    Wait Until falling_edge(clk);
    addr <= (Others => '0');
    read <= '0';
End Procedure read_register;

Procedure check_idle Is
Begin
    read_register(CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_OFST);
    Assert rddata = CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_IDLE Report "Error: unit should be idle, but is busy" Severity error;
End Procedure check_idle;

Procedure check_busy Is
Begin
    read_register(CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_OFST);
    Assert rddata = CMOS_SENSOR_OUTPUT_GENERATOR_STATUS_BUSY Report "Error: unit should be busy, but is idle" Severity error;
End Procedure check_busy;

Procedure wait_clock_cycles(Constant count : In Positive) Is
Begin
    Wait For count * CLK_PERIOD;
End Procedure wait_clock_cycles;
Begin
async_reset;

Wait For CLK_PERIOD/4;
Wait For 1 ns;
-- wait for CLK_PERIOD/2;
-- test dma_len_reg
write_avalon_slave <= '1';
address <= "001";
-- writedata <= (6=>'1', Others => '0');
writedata <= (12=>'1', Others => '0');
Wait For CLK_PERIOD;

-- test dma_dst_reg
write_avalon_slave <= '1';
address <= "010";
writedata <= (Others => '0');
Wait For CLK_PERIOD;

-- test start_reg
write_avalon_slave <= '1';
address <= "000";
writedata <= (4 => '1', 0 => '1', Others => '0');
Wait For CLK_PERIOD;

write_avalon_slave <= '0';
writedata<=(others => '0');

wait for CLK_PERIOD;

-- configure
write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_WIDTH_OFST, FRAME_WIDTH);
write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_HEIGHT_OFST, FRAME_HEIGHT);
write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_FRAME_BLANK_OFST, FRAME_FRAME_BLANK);
write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_FRAME_LINE_BLANK_OFST, FRAME_LINE_BLANK);
write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_LINE_BLANK_OFST, LINE_LINE_BLANK);
write_register(CMOS_SENSOR_OUTPUT_GENERATOR_CONFIG_LINE_FRAME_BLANK_OFST, LINE_FRAME_BLANK);

-- start generator
write_register(CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_OFST, CMOS_SENSOR_OUTPUT_GENERATOR_COMMAND_START);
check_busy;

AM_waitrequest <= '1';

Wait For CLK_PERIOD*10;
AM_waitrequest <= '0';

Wait Until falling_edge(frame_valid);
Wait Until falling_edge(clk);

-- test read finished reg
read_avalon_slave<='1';
address<="100";
wait for CLK_PERIOD;

-- sim_finished <= true;

Wait For CLK_PERIOD * 5;
Wait;
End Process sim;

End Architecture;
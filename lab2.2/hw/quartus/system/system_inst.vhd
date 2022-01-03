	component system is
		port (
			clk_clk                                 : in  std_logic                    := 'X'; -- clk
			realtimeclock_0_conduit_resetled_export : out std_logic;                           -- export
			realtimeclock_0_conduit_seldig_export   : out std_logic_vector(5 downto 0);        -- export
			realtimeclock_0_conduit_selseg_export   : out std_logic_vector(7 downto 0);        -- export
			reset_reset_n                           : in  std_logic                    := 'X'  -- reset_n
		);
	end component system;

	u0 : component system
		port map (
			clk_clk                                 => CONNECTED_TO_clk_clk,                                 --                              clk.clk
			realtimeclock_0_conduit_resetled_export => CONNECTED_TO_realtimeclock_0_conduit_resetled_export, -- realtimeclock_0_conduit_resetled.export
			realtimeclock_0_conduit_seldig_export   => CONNECTED_TO_realtimeclock_0_conduit_seldig_export,   --   realtimeclock_0_conduit_seldig.export
			realtimeclock_0_conduit_selseg_export   => CONNECTED_TO_realtimeclock_0_conduit_selseg_export,   --   realtimeclock_0_conduit_selseg.export
			reset_reset_n                           => CONNECTED_TO_reset_reset_n                            --                            reset.reset_n
		);



module system (
	clk_clk,
	realtimeclock_0_conduit_resetled_export,
	realtimeclock_0_conduit_seldig_export,
	realtimeclock_0_conduit_selseg_export,
	reset_reset_n);	

	input		clk_clk;
	output		realtimeclock_0_conduit_resetled_export;
	output	[5:0]	realtimeclock_0_conduit_seldig_export;
	output	[7:0]	realtimeclock_0_conduit_selseg_export;
	input		reset_reset_n;
endmodule

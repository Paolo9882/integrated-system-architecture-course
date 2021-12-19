module tb_FPmul ();

	wire CLK_i;
	wire RST_n_i;
	wire [31:0] DIN_i;
	wire [31:0] DOUT_i;
	wire END_SIM_i;

   	clk_gen CG(.END_SIM(END_SIM_i),
				.CLK(CLK_i),
				.RST_n(RST_n_i));

	data_maker DM(.CLK(CLK_i),
				.DATA(DIN_i),
				.RST_n(RST_n_i),
				.END_SIM(END_SIM_i));

	FPmul DUT(.clk(CLK_i),
	                  .FP_A(DIN_i),
	                  .FP_B(DIN_i),
	                  .FP_Z(DOUT_i));

	data_save DS(.CLK(CLK_i),
				.RST_n(RST_n_i),
				.DATA(DOUT_i));   

endmodule

		   

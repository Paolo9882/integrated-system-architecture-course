//test-bench for a IIR filter
//data parallelism: 12
//filter order: 2

module tb_iir_2nd_order_lookahead ();

	wire CLK_i;
	wire RST_n_i;
	wire [11:0] DIN_i;
	wire VIN_i;
	wire [11:0] a2_i;
	wire [11:0] a3_i;
	wire [11:0] b0_i;
	wire [11:0] b1_i;
	wire [11:0] b2_i;
	wire [11:0] b3_i;
	wire [11:0] DOUT_i;
	wire VOUT_i;
	wire END_SIM_i;

   	clk_gen CG(.END_SIM(END_SIM_i),
				.CLK(CLK_i),
				.RST_n(RST_n_i));

	data_gen_lookahead DG(.CLK(CLK_i),
				.RST_n(RST_n_i),
				.VOUT(VIN_i),
				.DOUT(DIN_i),
				.a2(a2_i), 
				.a3(a3_i),
				.b0(b0_i),
				.b1(b1_i),
				.b2(b2_i),
				.b3(b3_i),
				.END_SIM(END_SIM_i));

	iir_2nd_order_lookahead DUT(.CLK(CLK_i),
				.RST_n(RST_n_i),
				.DIN(DIN_i),
				.VIN(VIN_i),
				.a2(a2_i), 
				.a3(a3_i),
				.b0(b0_i),
				.b1(b1_i),
				.b2(b2_i),
				.b3(b3_i),
				.DOUT(DOUT_i),
				.VOUT(VOUT_i));

	data_save DS(.CLK(CLK_i),
				.RST_n(RST_n_i),
				.VIN(VOUT_i),
				.DIN(DOUT_i));   

endmodule

		   

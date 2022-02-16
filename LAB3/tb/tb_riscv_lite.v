module tb_riscv_lite ();
    // one bit signals
    wire CLK_i;
    wire RST_n_i;
    wire CS_i, RW_n_i;
    wire FLASHED_DM_i, FLASHED_IM_i;

    // 32 bit signals
    wire [31:0] PC_i, IR_i; // for the instruction memory
    wire [31:0] MAR_i, MDRR_i, MDRW_i; // for the data memory

    // signals for starting (loading instruction memory) and stopping the simulation
    // after the algorithm is over
    reg START_i;
    reg END_SIM_i;

    // start and stop time in ns
    localparam start_time = 3;
    localparam end_time = 1200;

    // clock generator
    clk_gen CG(.END_SIM(END_SIM_i),
               .CLK(CLK_i),
               .RST_n(RST_n_i),
               .FLASHED_IM(FLASHED_IM_i),
               .FLASHED_DM(FLASHED_DM_i));

    // data memory
    data_memory DM(.CLK(CLK_i),
                  .RST_n(RST_n_i),
                  .DUMP_MEM(END_SIM_i),
                  .CS(CS_i),
                  .RW_n(RW_n_i),
                  .MAR(MAR_i),
                  .MDRW(MDRW_i),
                  .MDRR(MDRR_i),
                  .START(START_i),
                  .FLASHED(FLASHED_DM_i));

    // instruction memory
    instruction_memory IM(.CLK(CLK_i),
			  .RST_n(RST_n_i),
			  .START(START_i),
                          .PC(PC_i),
                          .IR(IR_i),
                          .FLASHED(FLASHED_IM_i));

    // the risc-v processor
    riscv_lite DUT(.clk(CLK_i),
                   .rst_n(RST_n_i),
                   .IR(IR_i),
                   .MDRR(MDRR_i),
                   .PC(PC_i),
                   .MAR(MAR_i),
                   .MDRW(MDRW_i),
				   .cs_MDRW(CS_i),
				   .rd_wr_n_MDRW(RW_n_i));

    // this piece of code assigns values to the start and stop signal at the right time
    initial
        begin
            // initialize signals to zero
            START_i <= 0; END_SIM_i <= 0;

            #start_time START_i <= 1; // @start time
            #end_time END_SIM_i <= 1; // @stop time
        end
endmodule

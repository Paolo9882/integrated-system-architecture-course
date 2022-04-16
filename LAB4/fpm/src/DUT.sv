module DUT(dut_if.port_in in_inter, dut_if.port_out out_inter, output enum logic [1:0] {INITIAL,WAIT,SEND} state);
    
	logic [31:0] A_pipe1, A_pipe2, A_pipe3;
	logic [31:0] B_pipe1, B_pipe2, B_pipe3;

    FPmul mult_under_test(.FP_A(in_inter.A),.FP_B(in_inter.B),.clk(in_inter.clk),.FP_Z(out_inter.data));

    always_ff @(posedge in_inter.clk)
    begin
        if(in_inter.rst) begin
            in_inter.ready <= 0;
            out_inter.data <= 'x;
            out_inter.valid <= 0;
            state <= INITIAL;
        end
        else case(state)
                INITIAL: begin
                    in_inter.ready <= 1;
                    state <= WAIT;
                end
                
                WAIT: begin
					A_pipe1 <= in_inter.A;
					A_pipe2 <= A_pipe1;
					A_pipe3 <= A_pipe2;
					B_pipe1 <= in_inter.B;
					B_pipe2 <= B_pipe1;
					B_pipe3 <= B_pipe2;
                    if(in_inter.valid) begin
                        in_inter.ready <= 0;
                        //out_inter.data <= in_inter.A + in_inter.B;
                        $display("fpm: input A = %e, input B = %e, output OUT = %e",$bitstoshortreal(A_pipe3), $bitstoshortreal(B_pipe3), $bitstoshortreal(out_inter.data));
                        $display("fpm: input A = %b, input B = %b, output OUT = %b",A_pipe3,B_pipe3,out_inter.data);
                        out_inter.valid <= 1;
                        state <= SEND;
                    end
                end
                
                SEND: begin
                    if(out_inter.ready) begin
                        out_inter.valid <= 0;
                        in_inter.ready <= 1;
                        state <= WAIT;
                    end
                end
        endcase
    end
endmodule: DUT

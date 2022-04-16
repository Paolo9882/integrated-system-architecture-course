class refmod extends uvm_component;
    `uvm_component_utils(refmod)
    
    packet_in tr_in;
	logic[31:0] tr_inA_pipe1, tr_inA_pipe2, tr_inA_pipe3, tr_inB_pipe1, tr_inB_pipe2, tr_inB_pipe3;
    packet_out tr_out;
	logic[31:0] tr_out_pipe1, tr_out_pipe2;
    uvm_get_port #(packet_in) in;
    uvm_put_port #(packet_out) out;
    
    function new(string name = "refmod", uvm_component parent);
        super.new(name, parent);
        in = new("in", this);
        out = new("out", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr_out = packet_out::type_id::create("tr_out", this);
    endfunction: build_phase
    
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
		//Uninizialited pipe registers
		tr_out_pipe1 = 'x;
		tr_out_pipe2 = 'x;
		tr_inA_pipe1 = 'x;
		tr_inA_pipe2 = 'x;
		tr_inB_pipe1 = 'x;
		tr_inB_pipe2 = 'x;
		tr_inA_pipe3 = 'x;
		tr_inB_pipe3 = 'x;

        forever begin
            in.get(tr_in);

			//Introduction of pipe registers
			tr_out.data = tr_out_pipe2;
			tr_out_pipe2 = tr_out_pipe1;
			tr_inA_pipe3 = tr_inA_pipe2;
			tr_inA_pipe2 = tr_inA_pipe1;
			tr_inA_pipe1 = tr_in.A;
			tr_inB_pipe3 = tr_inB_pipe2;
			tr_inB_pipe2 = tr_inB_pipe1;
			tr_inB_pipe1 = tr_in.B;

			//Computation of the expected output
			tr_out_pipe1 = $shortrealtobits($bitstoshortreal(tr_in.A) * $bitstoshortreal(tr_in.B));

			if (tr_out_pipe1[30:23] == '0 && tr_out_pipe1[22:0] != '0) begin //number too low
				tr_out_pipe1 = '0;
			end
			
			if (tr_out_pipe1[30:23] == '1 && tr_out_pipe1[22:0] != '0) begin //NaN
				tr_out_pipe1[30:0] = 31'b1111111110000000000000000000000;
				tr_out_pipe1[31] = tr_in.A[31] ^ tr_in.B[31];
			end
				
            $display("refmod: input A = %e, input B = %e, output OUT = %e",$bitstoshortreal(tr_inA_pipe3), $bitstoshortreal(tr_inB_pipe3), $bitstoshortreal(tr_out.data));
			$display("refmod: input A = %b, input B = %b, output OUT = %b",tr_inA_pipe3, tr_inB_pipe3, tr_out.data);
            out.put(tr_out);
        end
    endtask: run_phase
endclass: refmod

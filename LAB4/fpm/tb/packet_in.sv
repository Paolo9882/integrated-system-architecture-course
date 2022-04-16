class packet_in extends uvm_sequence_item;
    rand logic[31:0] A;
    rand logic[31:0] B;
		
	//constraint my_range_B { B == 32'b01111111100000000000000000000000; }
	//constraint my_range_A { A == 32'b00000000000000000000000000000000; }

    `uvm_object_utils_begin(packet_in)
        `uvm_field_int(A, UVM_ALL_ON|UVM_HEX)
        `uvm_field_int(B, UVM_ALL_ON|UVM_HEX)
    `uvm_object_utils_end

    function new(string name="packet_in");
        super.new(name);
    endfunction: new
endclass: packet_in

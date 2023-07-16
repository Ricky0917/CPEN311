module trap_edge(
	input logic async_sig, clk, reset,
	output logic trapped_edge
);
logic Q;

always_ff @(posedge async_sig, posedge reset) begin
			if(reset) Q <= 1'b0;
			else Q <= 1'b1;
		end
		
always_ff @(posedge clk, posedge reset) begin
			if(reset) trapped_edge <= 1'b0;
			else trapped_edge <= Q;
		end

endmodule
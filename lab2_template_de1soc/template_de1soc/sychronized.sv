//this module is same with question 7 in assignment 1
module sychronized (input async_sig, input outclk, output out_sync_sig);
	logic DFF, DFF1, DFF2, DFF3;
	assign out_sync_sig = DFF2;
	
	Dflip flip1(.D(1'b1), .clk(async_sig), .reset(DFF3), .Q(DFF));
	Dflip flip2(.D(DFF), .clk(outclk), .reset(1'b0), .Q(DFF1));
	Dflip flip3(.D(DFF1), .clk(outclk), .reset(1'b0), .Q(DFF2));
	Dflip flip4(.D(DFF2), .clk(~outclk), .reset(1'b0), .Q(DFF3));

endmodule

module Dflip(input logic D, input logic clk, input logic reset, output logic Q);
	always_ff @(posedge clk, posedge reset) begin
        if (reset)    Q <= 1'b0;
        else        Q <= D;
    end
endmodule
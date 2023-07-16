module clock_divider(input logic inclk, input logic [31:0] div_clk, output logic outclk);
							
	logic [31:0] count;
	
	always_ff @(posedge inclk) begin

		if(count < div_clk - 1'b1)
			count <= count + 1'b1;
		else 
			count <= 32'b0;
	end
	
	always_ff @(posedge inclk) begin

		if(count == div_clk - 1'b1)
			outclk <= outclk +1'b1;
		else
			outclk <= outclk;
	end							
							
endmodule
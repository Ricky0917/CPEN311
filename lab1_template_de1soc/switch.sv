module switch(input logic [3:1] switch, output logic [31:0] divition);
	
	parameter Do = 32'd47801; //523
	parameter re = 32'd42589; //587
	parameter mi = 32'd37936; //659
	parameter fa = 32'd35816; //698
	parameter so = 32'd31928; //783
	parameter la = 32'd28409; //880
	parameter si = 32'd25329; //987
	parameter do1 = 32'd23901; //1046 //this is the frequency for every notes, 25_000_000 / frequency
	
	//logic [31:0] freq;
	
	always_comb               //
		casez(switch)
			3'b000: divition = Do;
			3'b001: divition = re;
			3'b010: divition = mi;
			3'b011: divition = fa;
			3'b100: divition = so;
			3'b101: divition = la;
			3'b110: divition = si;
			3'b111: divition = do1;
			default divition = Do;
		endcase
		
		
	//assign divition <= 32'd25_000_000/freq;
	/*	
	always_ff @(posedge clk, posedge reset) begin //calculate divition ratio in here
		if(reset == 1) 
			divition <= 32'd25_000_000;
		else 
			divition <= 32'd25_000_000/freq; 
	end
   */

endmodule


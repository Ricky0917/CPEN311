//a)
module QS7( input logic async_sig, input logic outclk, output logic out_sync_sig);

	logic DFF, DFF1, DFF2, DFF3;
	logic VCC, GND;
	assign VCC = 1;
	assign GND = 0;
	assign out_sync_sig = DFF2;
	
	always_ff @(posedge async_sig, posedge DFF3)
		if (DFF3) DFF <= 0;
		else      DFF <= VCC;
		
	always_ff@ (posedge outclk, posedge GND)
		if (GND) DFF1 <= 0;
		else      DFF1 <= DFF;
		
	always_ff@ (posedge outclk, posedge GND)
		if (GND) DFF2 <= 0;
		else      DFF2 <= DFF1;
		
	always_ff@ (posedge ~outclk, posedge GND)
		if (GND) DFF3 <= 0;
		else      DFF3 <= DFF2;
		
endmodule
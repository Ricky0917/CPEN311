//===================********TASK 1********======================
//  THIS MODULE INCREMENTS COUNT AND ASSIGNS COUNT TO ADDRESS AND DATA
//  AND ENABLES WRITE TO RAM. BASIC GLITCH FREE STATE MACHINE. 
//  COMPLETES 1 ITERATION IN 3 CYCLES, AND INCREMENTS COUNTER EVERY 3 CYCLES.
//  IDLES WHEN COUNT IS 255.
//===========================================================

module init_fsm(
input clock,
input start,
output [7:0] address,
output [7:0] data,
output finish,
output write_enable,
input reset
);
 
//=========TASK 1 STATES========================
parameter s_wait_start	= 4'b1000;
parameter s_wait 			= 4'b0000;
parameter write 			= 4'b0001;
parameter s_increment	= 4'b0010;
parameter finish_init	= 4'b0100;
//==============================================

//============Declaring Logic for function============
logic increment;

reg [3:0] state;
reg [7:0] var_i = 0;

assign data = var_i;
assign address = var_i;

assign write_enable = state[0];
assign increment = state[1];
assign finish = state[2];

//====================================================================
// s_wait ------- > s_write --------> s_increment---|
//		^---------------------------------------------|
//=====================================================================
always_ff @(posedge clock) begin
	case(state)
		s_wait_start:		if(start) 
									state <= s_wait;
								else 
									state <= s_wait_start;
								
		s_wait:				state <= write;
		
		write:				state <= s_increment;
		
		s_increment:		if (var_i == 255) 
									state <= finish_init;
								else 					
									state <= s_wait;
								
		finish_init:		state <= s_wait_start; // INF LOOP
		
		default: 			state <= s_wait_start;

	endcase
end
//=======================================
// COUNTER WITH ENABLE FROM STATE MACHINE
//=======================================
always_ff @(posedge clock) begin
	if(reset)
		var_i <= 0;
	if(increment) 
		var_i <= var_i + 1'b1;
	else 
		var_i <= var_i;
end

endmodule
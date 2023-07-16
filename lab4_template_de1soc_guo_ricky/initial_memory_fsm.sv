// initialize s array. You will build this in Task 1
//for i = 0 to 255 {s[i] = i;} 
module initialize_memory(
						input clock,start,reset,
						output [7:0] address,
						output [7:0] data,
						output finish, write_enable
);
//5 STATES========================
		logic [3:0] state;
		parameter s_start			= 4'b1000;
		parameter s_wait 			= 4'b0000;		
		parameter s_write 		= 4'b0001;
		parameter s_increment	= 4'b0010;//in the increament state, the i will add 1 until 255
		parameter s_finish	   = 4'b0100;


//make a flag to mark the increament state============
		logic increment;
		assign increment = state[1];				

//output finish & write_enable==============		
		assign write_enable = state[0];
		assign finish = state[2];
		
//make a i & let s[i] = i=========
		logic [7:0] var_i = 0;		
		assign data = var_i;
		assign address = var_i;

		// 
always_ff @(posedge clock) begin
	case(state)
		s_start:	begin
			if(start) state <= s_wait;
			else state <= s_start;
		end						
		s_wait:	state <= s_write;
		
		s_write:	state <= s_increment;
		
		s_increment: begin 
			if (var_i == 255) state <= s_finish;
			else 	state <= s_wait;
		end						
		s_finish: state <= s_start; 
		
		default: state <= s_start;

	endcase
end

// COUNTER increase
always_ff @(posedge clock) begin

	if(reset)//if reset, the i will to 0
		var_i <= 0;
	if(increment) 
		var_i <= var_i + 1'b1;
	else 
		var_i <= var_i;
		
end

endmodule

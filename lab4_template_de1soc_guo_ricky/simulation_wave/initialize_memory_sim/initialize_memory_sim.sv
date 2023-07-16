//for i = 0 to 255 {s[i] = i;}
//in this module, 
module initialize_memory_sim(
			input clk, start,reset,
			output [7:0] address,
			output [7:0] data,
			output finish, write_enable
);

logic [4:0]state;
//5 states
parameter start_s =      5'b00001;
parameter wait_s  =      5'b00010;
parameter write_s =      5'b00100;
parameter increament_s = 5'b01100;//in the increament state, the i will add 1 until 255
parameter finish_s =     5'b10000;

//output finish & write_enable
assign finish = state[4];
assign write_enable = state[2];

//make a flag to mark the increament state
logic add_flag;
assign add_flag = state[3];

//make a i & let s[i] = i
logic [7:0] i;		
assign data = i;
assign address = i;

//state machine
always_ff @(posedge clk) begin
	case(state)
		start_s:	begin
				if(start) state <= wait_s;
				else state <= start_s;
		end
		
		wait_s: state <= write_s;
		
		write_s:	state <= increament_s;
		
		increament_s: begin
			if (i == 255) state <= finish_s;
			else state <= wait_s;
		end
		
		finish_s: state <= start_s; 
		
		default: state <= start_s;

	endcase
end

//
always_ff @(posedge clk) begin

	if(reset)//if reset, the i will to 0
		i <= 1'b0;
	else if(add_flag) 
		i <= i + 1'b1;
	else 
		i <= i;
		
end

endmodule
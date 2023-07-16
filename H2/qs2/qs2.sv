//Question 2-code, Ruiqi Zang 24075277
module qs2 (state, odd, even, terminal, pause, restart, clk, rst, goto_third, Out1, Out2);
	input logic pause, restart, clk, rst, goto_third;
	output logic [10:0] state;
	output logic odd, even, terminal;
	output logic [2:0] Out1, Out2;		
	                           // 1098 7 654 321 0
	parameter [10:0] FIRST  = 	12'b000_0_011_010_0;
	parameter [10:0] SECOND =  12'b001_0_101_100_1;
	parameter [10:0] THIRD  = 	12'b010_0_010_111_0;
	parameter [10:0] FOURTH = 	12'b011_0_110_011_1;
	parameter [10:0] FIFTH  = 	12'b100_1_101_010_0;
	
	assign even = state[0];
	assign odd  = ~state[0];
	assign Out2 = state[3:1];
	assign Out1 = state[6:4];
	assign terminal = state[7];
	
	always_ff @(posedge clk or posedge rst) begin
		if (rst) state <= FIRST;
		else
		begin
			case(state)
				FIRST: if (restart | pause) state <= FIRST;
						else state <= SECOND;						
				SECOND: if (restart) state <= FIRST;
						else if (pause) state <= SECOND;
						else state <= THIRD;						
				THIRD: if (restart) state <= FIRST;			
						else if (pause) state <= THIRD;
						else state <= FOURTH;						
				FOURTH: if (restart) state <= FIRST;			
						else if (pause) state <= FOURTH;
						else state <= FIFTH;						
				FIFTH: if (restart|!goto_third) state <= FIRST;			
						else if (goto_third) state <= THIRD;
						else state <= FIFTH;						
				default: state <= FIRST;
			endcase
		end
	end
endmodule


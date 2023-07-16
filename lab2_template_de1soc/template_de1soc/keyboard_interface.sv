module keyboard_interface(
	input logic clk,
	input logic [7:0] keyboard,
	input logic data_ready,
	input logic finish,
	output [2:0]out_signal
);
	
	logic [3:0]state;

  parameter character_B = 8'h42;
  parameter character_D = 8'h44;
  parameter character_E = 8'h45;
  parameter character_F = 8'h46;
  parameter character_R = 8'h52;
  parameter character_lowercase_b = 8'h62;
  parameter character_lowercase_d = 8'h64;
  parameter character_lowercase_e = 8'h65;
  parameter character_lowercase_f = 8'h66;
  parameter character_lowercase_r = 8'h72;
	
	parameter check =4'b0000;
	parameter forward_stop  = 4'b1000;
	parameter forward_play  = 4'b0001;
	parameter backward_stop = 4'b0010;
	parameter backward_play = 4'b0011;
	parameter forward_reset = 4'b0101;
	parameter backward_reset = 4'b0_111;
	
	assign out_signal = state[2:0];
	
	always_ff @(posedge clk) begin
		case(state)
			check: begin
				if(keyboard ==  character_E || keyboard ==  character_lowercase_e) state <= forward_play;
				else if (keyboard ==  character_B || keyboard ==  character_lowercase_b) state <= backward_stop;
				else state <= check;
			end
			forward_stop: begin
				if(keyboard ==  character_E || keyboard ==  character_lowercase_e) state <= forward_play;
				else if (keyboard ==  character_B || keyboard ==  character_lowercase_b) state <= backward_stop;
				else if(keyboard ==  character_R || keyboard ==  character_lowercase_r) state <= forward_reset;
				else state <= forward_stop;
			end			
			
			forward_play: begin
				if(keyboard ==  character_D || keyboard ==  character_lowercase_d) state <= forward_stop;
				else if (keyboard ==  character_B || keyboard ==  character_lowercase_b) state <= backward_play;
				else if(keyboard ==  character_R || keyboard ==  character_lowercase_r) begin
					if(data_ready) state <= forward_reset;
				end
				else state <= forward_play;
			end			
			
			backward_stop: begin
				if(keyboard ==  character_E || keyboard ==  character_lowercase_e) state <= backward_play;
				else if (keyboard ==  character_F || keyboard ==  character_lowercase_f) state <= forward_stop;
				else if(keyboard ==  character_R || keyboard ==  character_lowercase_r) state <= backward_reset;
				else state <= backward_stop;
			end			
			
			backward_play: begin
				if(keyboard ==  character_D || keyboard ==  character_lowercase_d) state <= backward_stop;
				else if (keyboard ==  character_F || keyboard ==  character_lowercase_f) state <= forward_play;
				else if(keyboard ==  character_R || keyboard ==  character_lowercase_r) begin
					if(data_ready) state <= backward_reset;
				end
				else state <= backward_play;
			end			
			
			forward_reset: if(finish)state <= forward_play;

			backward_reset: if(finish) state <= backward_play;
			default: state<= check;
		endcase
	end
endmodule
	
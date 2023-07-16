module address_flash_sim(
	input logic clk,sych_clk,
	input logic [2:0] out_signal,
	input logic finish,
	input logic [31:0] in_data,
	
	output logic add_start, add_read, add_finish,
	output logic [22:0] address,
	output logic [3:0] byteenable,
	output logic [7:0] out_data
);

logic start, dir, restart;
assign start = out_signal[0];
assign dir = out_signal[1];
assign restart = out_signal[2];

logic [5:0] state;
assign add_start = state[1];
assign add_read = state[1];
assign add_finish = state[0];
assign byteenable = 4'b1111;

parameter idle = 6'b0000_00;
parameter flash = 6'b0001_10;//6
parameter get_data1 = 6'b0010_00;//8
parameter read_data1 = 6'b0011_00;//12
parameter get_data2 = 6'b0100_00;//16
parameter read_data2 = 6'b0101_00;//24
parameter dir_change = 6'b0110_00;
parameter back_dir= 6'b0111_00;//28
parameter forw_dir = 6'b1000_00;
parameter finish_state = 6'b1001_01;	

always_ff @(posedge clk) begin
			case(state)
					idle: begin
							if(start) state <= flash;
							else state <= idle;
					end
					flash: begin
							if(finish) state <= get_data1;
							else state <= flash;
					end
					
					get_data1: begin
							if(sych_clk) state <= read_data1;
							else state <= get_data1;
					end
					read_data1: begin
							state <= get_data2;
					end
					get_data2: begin
							if(sych_clk) state <= read_data2;
							else state <= get_data2;
					end
					read_data2:  begin
							state <= dir_change;
					end
					dir_change: begin
							if(dir) state <= back_dir;
							else state <= forw_dir;
					end
					back_dir: state <= 	finish_state;
					forw_dir: state <= 	finish_state;
					finish_state: state <= idle;
			      default: state <= idle;
				endcase
end	
	
always_ff @(posedge clk) begin 
	case (state)

		read_data1: begin 
			if (dir) out_data <= in_data [31:24]; //from uper to lower(backward play)
			else out_data <= in_data [7:0]; //from lower to uper(forward play)
			address <= address; 
		end 
		
		read_data2: begin 
			if(dir) out_data <= in_data [7:0]; 
			else out_data <= in_data [31:24]; 
			address <= address; 
			end 
		
		back_dir: begin
			if (restart) address <= 23'h7FFFF; 
			else begin
				address <= address - 23'd1;   
			if (address == 0)
				address <= 23'h7FFFF;
			end
					   
			out_data <= out_data; //data does not change in this state 
		end 
		
		forw_dir: begin 
			if(restart) address <= 0;   
			else begin
				address <= address + 23'd1;
			if (address > 23'h7FFFF) 
				address <= 23'h0; 		
         end
 
			out_data <= out_data; //data does not change in this state  	  
		end 
		
		default: begin 
			address <= address; 
			out_data <= out_data;
			end
		
	endcase 
end 

endmodule 	
					
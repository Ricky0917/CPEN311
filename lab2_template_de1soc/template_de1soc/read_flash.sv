module read_flash(
	input logic clk, 
	input logic wait_request, data_valid,  // from flash controller
	input logic start,read,
	output logic finish 
);
 
logic [3:0] state;

assign finish = state[0];

parameter idle = 4'b000_0;
parameter check_state = 4'b001_0;//prepare get th esignal for reading address
parameter read_state = 4'b010_0;
parameter wait_state = 4'b011_0;
parameter finish_state = 4'b100_1;

always_ff @(posedge clk)
	case(state)
		idle: begin
						if (start) state <= check_state;
						else state <= idle;
		end
		check_state: begin
						if (read) state <= read_state;
						else state <= check_state;
		end
		read_state: begin
						if (!wait_request) state <= wait_state;
						else state <= read_state;
		end
		wait_state: begin
						if (!data_valid) state <= finish_state;
						else state <= wait_state;
		end
		finish_state: state <= idle;
		default: state <= idle;
	endcase
	
	
endmodule
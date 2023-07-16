module shared_access_to_one_state_machine
#(
parameter N = 32,
parameter M = 8
)
(

input target_state_machine_finished,
input sm_clk,
input logic start_request_a,
input logic start_request_b,
input [(N-1):0] input_arguments_a,
input [(N-1):0] input_arguments_b,
input reset,
input [M-1:0] in_received_data,

output logic finish_a,//
output logic finish_b,//
output logic reset_start_request_a,//
output logic reset_start_request_b,//
output reg [(M-1):0] received_data_a,
output reg [(M-1):0] received_data_b,
output reg [(N-1):0] output_arguments,
output start_target_state_machine//

);

logic [11:0] state;
parameter check_start_a = 		12'b0000_00000000;
parameter give_start_a =  		12'b0001_01100000;
parameter wait_for_finish_a = 12'b0010_00000000;
parameter register_data_a =   12'b0011_00000010;
parameter give_finish_a =     12'b0100_00001000;

parameter check_start_b = 		12'b0101_10000000;
parameter give_start_b =  		12'b0110_11010000;
parameter wait_for_finish_b = 12'b0111_10000000;
parameter register_data_b =   12'b1000_10000001;
parameter give_finish_b =     12'b1001_10000100;

logic select_b_output_parameters, register_data_a_enable, register_data_b_enable;

//list the output with different state
assign register_data_b_enable = state[0];
assign register_data_a_enable = state[1];
assign finish_b = state[2];
assign finish_a = state[3];
assign reset_start_request_b = state[4];
assign reset_start_request_a = state[5];
assign start_target_state_machine = state[6];
assign select_b_output_parameters = state[7];

//select_b_output_parameters: the function of this state machine output is (in pseudo-code):
assign output_arguments = (select_b_output_parameters) ? input_arguments_b : input_arguments_a;

//register_data_a_enable & register_data_b_enable:
always_ff @(posedge sm_clk) begin
		if(register_data_a_enable) received_data_a <= in_received_data;
		if(register_data_b_enable) received_data_b <= in_received_data;
end

//state machine
always_ff @(posedge sm_clk, posedge reset)begin
	if(reset) state <= check_start_a;
	else 
		case(state)
		
			check_start_a: begin
				if (!start_request_a) state <= check_start_b;
            else if (start_request_a) state <= give_start_a;
				else state <= check_start_a;
			end
			
         give_start_a: state <= wait_for_finish_a;

         wait_for_finish_a: begin
				if (!target_state_machine_finished) state <= wait_for_finish_a;
            else if (target_state_machine_finished) state <= register_data_a;
				else state <= wait_for_finish_a;
			end

         register_data_a: state <= give_finish_a;

         give_finish_a: state <= check_start_b;

         check_start_b: begin
				if (!start_request_b) state <= check_start_a;
            else if (start_request_b) state <= give_start_b;
				else state <= check_start_b;
			end
                
         give_start_b: state <= wait_for_finish_b;

         wait_for_finish_b: begin
				if (!target_state_machine_finished) state <= wait_for_finish_b;
            else if (target_state_machine_finished) state <= register_data_b;
				else state <= wait_for_finish_b;
			end
                
			register_data_b: state <= give_finish_b;

         give_finish_b: state <= check_start_a;
			
			default: state <= check_start_a;
		endcase
end

endmodule
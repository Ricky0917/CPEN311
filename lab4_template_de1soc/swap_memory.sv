// shuffle the array based on the secret key. You will build this in Task 2
//j = 0
//for i = 0 to 255 {
//j = (j + s[i] + secret_key[i mod keylength] ) mod 256 //keylength is 3 in our impl.
//swap values of s[i] and s[j] }
module swap_memory(
		input clk,start,reset,
		input logic [23:0] skey,
		input logic [7:0] data_in,
		
		output logic write_enable, finish,
		output logic [7:0] address, data_out
);

//state declarition, 13 state_machine
										   //   1098_7654_3210
parameter s_start 					= 11'b111_0000_0000;										
parameter s_wait 						= 11'b001_0000_0000;
parameter s_get_si					= 11'b010_0000_0000;
parameter s_store_si_temp 			= 11'b000_0001_0000;
parameter s_calculate_j_temp		= 11'b000_0100_0000;
parameter s_retrieve_j				= 11'b000_0000_0100;
parameter s_store_j_temp			= 11'b000_0010_0100;
parameter s_write_i_to_j			= 11'b000_0000_0101;
parameter s_write_wait				= 11'b111_0000_1101;
parameter s_set_address_i			= 11'b000_0000_1000;
parameter s_write_j_to_i			= 11'b000_0000_1001;
parameter s_increment				= 11'b000_0000_0010;
parameter s_finish					= 11'b001_1000_0000;

// declare wire and reg
logic [10:0] state;
logic [7:0] var_i = 8'b0;
logic [7:0] var_j = 0;
logic [1:0] var_k = 0;
logic [7:0] temp = 0;
logic [7:0] temp2= 0;
logic [7:0] s_key_b;

wire addr_sel;
wire data_out_sel;
wire temp_strobe;
wire temp2_strobe;
wire calc_j_strobe;
wire en_count;

		//each bit refer to one wire 
		assign write_enable 	= state[0];
		assign en_count 	= state[1]; 
		assign addr_sel 	= state[2];
		assign data_out_sel 	= state[3];
		assign temp_strobe 	= state[4];
		assign temp2_strobe 	= state[5];
		assign calc_j_strobe 	= state[6];
		assign finish 		= state[7];
	
		// MUX CONTROLS WHICH DATA_OUT AND ADDRESS IT IS ( EITHER s[i] or s[j])
		assign data_out = data_out_sel ? temp2 : temp;
		assign address = addr_sel ? var_j : var_i;



	// state machine
	always_ff @(posedge clk) begin
		case(state)

		s_start:				if(start)
								state <= s_wait;
								else
								state <= s_start;
										
		s_wait:				state <= s_get_si;
		
		s_get_si:			state <= s_store_si_temp;
								
		s_store_si_temp:	state <= s_calculate_j_temp;
								
		s_calculate_j_temp:	state <= s_retrieve_j;
										
		s_retrieve_j:		state <= s_store_j_temp;
								
		s_store_j_temp:	state <= s_write_i_to_j;
								
		s_write_i_to_j:   state <= s_set_address_i;
								
		s_set_address_i:  state <= s_write_j_to_i;
								
		s_write_j_to_i	:	state <= s_increment;
						
				
		// when swap to 255		
		s_increment:		if (var_i == 255) 
								state <= s_finish;
								else 
								state <= s_get_si;
		

//finish		
		s_finish :			state <= s_start;
		
		default	: 			state <= s_start;

		endcase 
	end



//  j: j = j+s[i]+secret_key[i%256]
	always @(*) begin
		var_k <= var_i % 2'd3;

		casex(var_k)
		2'b00	:	s_key_b <= skey[23:16];
		2'b01	:	s_key_b <= skey[15:8];
		2'b10	:	s_key_b <= skey[7:0];
		default	: s_key_b <= 0;
		endcase
	end

// STROBING OUR TEMPORARY REGISTERS AT TEMP (STORING s[i] and s[j], j) 
	always @(posedge clk) begin
		if (reset)
		temp <= 0;

		else if (temp_strobe)
		temp <= data_in;
		else
		temp <= temp;
	end

	always @(posedge clk) begin
		if(reset)
		temp2 <= 0;
		else if (temp2_strobe)
		temp2 <= data_in;
		else
		temp2 <= temp2;
		end

	always @(posedge clk) begin
		if (reset)
		var_j = 0;
		if (calc_j_strobe)
		var_j <= temp + s_key_b + var_j;
	end


// when en, var_i++
	always_ff @(posedge clk) begin
		if (reset)
		var_i <= 0;
		if(en_count) 
		var_i <= var_i + 1'b1;
		else 
		var_i <= var_i;
	end






endmodule
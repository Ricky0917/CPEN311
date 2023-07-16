/*based off state outputs. 	
		 Starts when start is recieved, outputs finished for MASTER when done:

	j = 0
	for i = 0 to 255 {
		j = (j + s[i] + secret_key[i mod keylength] ) //keylength is 3 in our impl.
		swap values of s[i] and s[j] }*/
module swap_fsm(
		input clock,
		input start,
		input reset,
		input [23:0] skey,
		input [7:0] data_in,
		
		output write_enable,
		output finish,
		output logic [7:0] address,
		output logic [7:0] data_out
		);
		
		logic [10:0] state = 11'b0;
		//state declarition
													//    098_7654_3210
		parameter s_start 					= 11'b111_0000_0000;										
		parameter s_wait 						= 11'b001_0000_0000;
		parameter s_get_si					= 11'b010_0000_0000;
		parameter s_store_si_temp 			= 11'b000_0001_0000;//temp_strobe = 1//storing the s[i]
		parameter s_calculate_j_temp		= 11'b000_0100_0000;//calc_j_strobe = 1//j = (j + s[i] + secret_key[i mod keylength] )
		parameter s_retrieve_j				= 11'b000_0000_0100;
		parameter s_store_j_temp			= 11'b000_0010_0100;//temp2_strobe = 1//storing the s[j]
		parameter s_write_i_to_j			= 11'b000_0000_0101;//enable = 1
		parameter s_write_wait				= 11'b111_0000_1101;//enable = 1
		parameter s_set_address_i			= 11'b000_0000_1000;
		parameter s_write_j_to_i			= 11'b000_0000_1001;//enable = 1
		parameter s_increment				= 11'b000_0000_0010;
		parameter s_finish					= 11'b001_1000_0000;//finish = 1

	
	
	//make i, j k =========
		logic [7:0] var_i = 8'b0; //make i = 0;
		logic [7:0] var_j = 8'b0; //make j = 0;
		logic [1:0] var_k = 0;
		
		
	//output finish & write_enable==============				
		assign finish 		= state[7];
		assign write_enable 	= state[0];
	//make a flag to mark the state============	
		logic [7:0] temp = 0;
		logic [7:0] temp2= 0;
		 
		logic addr_sel;
		logic data_out_sel;
		logic temp_strobe;
		logic temp2_strobe;
		logic calc_j_strobe;
		logic en_count;
		logic [7:0] s_key_b;//secret_key[i%256]
	//each bit refer to one logic
		assign en_count 	= state[1]; 
		assign addr_sel 	= state[2];
		assign data_out_sel 	= state[3];
		assign temp_strobe 	= state[4];
		assign temp2_strobe 	= state[5];
		assign calc_j_strobe 	= state[6];
		
		// MUX CONTROLS WHICH DATA_OUT AND ADDRESS IT IS ( EITHER s[i] or s[j])
		assign data_out = data_out_sel ? temp2 : temp; //if data_out_sel =1, swap j to i
		assign address = addr_sel ? var_j : var_i; //if addr_sel =1, var_j go to adress

	// state machine
	always_ff @(posedge clock) begin
		case(state)

		s_start:	begin
			if(start) state <= s_wait;
			else state <= s_start;
		end								
		s_wait:	state <= s_get_si;
		
		s_get_si:	state <= s_store_si_temp;
								
		s_store_si_temp: state <= s_calculate_j_temp;
								
		s_calculate_j_temp:	state <= s_retrieve_j;
										
		s_retrieve_j:	state <= s_store_j_temp;
								
		s_store_j_temp:	state <= s_write_i_to_j;
								
		s_write_i_to_j:   state <= s_set_address_i;
								
		s_set_address_i:  state <= s_write_j_to_i;
								
		s_write_j_to_i	:	state <= s_increment;
						
		s_increment:	begin
			if (var_i == 255) state <= s_finish; //count i untill i =255, go to the finish
			else state <= s_get_si;	
	   end
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
	always @(posedge clock) begin //assign temp_strobe 	= state[4];
		if (reset)
		temp <= 0;

		else if (temp_strobe)
		temp <= data_in;
		else
		temp <= temp;
	end

	always @(posedge clock) begin //assign temp2_strobe 	= state[5];

		if(reset)
		temp2 <= 0;
		else if (temp2_strobe)
		temp2 <= data_in;
		else
		temp2 <= temp2;
		end

	always @(posedge clock) begin //assign calc_j_strobe 	= state[6];
		if (reset)
		var_j = 0;
		if (calc_j_strobe)
		var_j <= temp + s_key_b + var_j;
	end


// when en, var_i++
	always_ff @(posedge clock) begin
		if (reset)
		var_i <= 0;
		if(en_count) 
		var_i <= var_i + 1'b1;
		else 
		var_i <= var_i;
	end
	

endmodule 

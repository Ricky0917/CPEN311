/*===================********TASK 2B, task3********======================
	DECODER FSM, IMPLENTS:
	i = 0, j=0
	for k = 0 to message_length-1 { // message_length is 32 in our implementation
	i = i+1
	j = j+s[i]
	swap values of s[i] and s[j]
	f = s[ (s[i]+s[j]) ]
	decrypted_output[k] = f xor encrypted_input[k] // 8 bit wide XOR function
*/

module decoder_fsm_sim(
		input clock,
		input [7:0] data_in,
		input start,
		input reset,
		input [7:0] data_rom,
		
		output reg [7:0] address,
		output reg [7:0] data_out,
		output [7:0] data_dec,
		output [7:0] address_dec,
		output write_enable,			
		output write_en_dec,		
		output done,
		output bad_key
		
);	
				//    	      			9876_5432_1098_7654_3210	addr_sel = 2 ||| data_sel = 3
	parameter s_start 			= 20'b0000_0000_0000_0000_0000; // state[8]
	
	parameter s_wait  			= 20'b0000_0000_0001_0000_0000;
	
	parameter increment_i  		= 20'b0000_0000_0001_0000_0010; 
	
	parameter get_si		  		= 20'b1000_0000_0001_0000_0000;
	
	parameter strobe_si  		= 20'b0000_0000_0001_0001_0000; 
	
	parameter j_plus_si  		= 20'b0000_0001_0001_0000_0100;	
	
	parameter get_sj				= 20'b0000_0000_0001_0000_0100; 
	
	parameter strobe_sj  		= 20'b0000_0000_0001_0010_0100; 	
	
	parameter write_i_to_j  	= 20'b0000_0000_0001_0000_0101; 	
	
	parameter set_address_i  	= 20'b0001_0000_0001_0000_0000;	
	
	parameter write_j_to_i	 	= 20'b0001_0000_0001_0000_0001;	
	
	parameter sum_si_sj	 		= 20'b0000_0010_0001_0000_1000; 	
	
	parameter get_si_sj			= 20'b0000_0000_0001_0000_1000;
	
	parameter strobe_f	 		= 20'b0000_0000_0001_0100_1000; 		
	
	parameter get_enc				= 20'b0000_0000_0001_1000_0000;	
	
	parameter f_xor_enc			= 20'b0000_0100_0001_0000_0000;	
	
	parameter wait_for_dec		= 20'b0011_0000_0001_0000_0000;
	
	
	parameter store_dec			= 20'b0000_0000_0011_0000_0000; 
	
	parameter s_wait_inc			= 20'b1001_0000_0001_0000_0000; 
	
	
	parameter increment_k		= 20'b0000_0000_0101_0000_0000; 
	
	parameter finish				= 20'b0000_0000_1001_0000_0000; 
		
	parameter abort				= 20'b0000_1000_0001_0000_0000; 
	
	parameter check_k 			= 20'b0100_0000_0001_0000_0000;
	
	// each bit stand for a signal
	assign write_enable 	= state[0];
	assign en_count_i 	= state[1]; 
	assign addr_sel 		= state[3:2];	
	assign temp_strobe 	= state[4];		// s[i]
	assign temp2_strobe 	= state[5];		// s[j]
	assign temp3_strobe  = state[6];		// f
	assign temp4_strobe	= state[7];		// encrypt message
	assign write_en_dec  = state[9];
	assign en_count_k		= state[10];
	assign done 			= state[11];
	assign strobe_j		= state[12];
	assign strobe_l		= state[13];		// s[j]+s[i]
	assign temp5_strobe 	= state[14];
	assign bad_key = state[15];
	assign data_out_sel 	= state[16];		
// 	 STATE MACHINE
	always_ff @(posedge clock) begin

	case(state)
		s_start:				if(start) 
								state <= s_wait;
								else 
								state <= s_start;
										
		s_wait:				state <= increment_i;	
		
		increment_i:		state <= get_si;
		
		get_si:				state <= strobe_si;
		
		strobe_si	:		state <= j_plus_si;
		
		j_plus_si:			state <= get_sj;
		
		get_sj:				state <=strobe_sj;
		
		strobe_sj:			state <= write_i_to_j;
		
		write_i_to_j	:	state <= set_address_i;
		
		set_address_i:		state <= write_j_to_i;
		
		write_j_to_i:		state <= sum_si_sj;
		
		sum_si_sj:			state <= get_si_sj; 
		
		get_si_sj:			state <= strobe_f;
		
		strobe_f:			state <= get_enc;
		
		get_enc:				state <= f_xor_enc;
		
		f_xor_enc:			state <= wait_for_dec;
		
		wait_for_dec:		if (char)
								state <= store_dec;
								else 
								state <= abort;
		
		store_dec:			state <= increment_k;
		
		increment_k:		state <= s_wait_inc;
		
		s_wait_inc:			state <= check_k;
		
		check_k:				if(var_k == 32)
								state <= finish;
								else
								state <= s_wait; 
										
		abort:				state <= s_start;
										
		finish:				state <= finish;
		
		default	: 			state <= s_start;

	endcase 
	end
	

	   logic en_count_i, en_count_k;
		wire [1:0] addr_sel;
		wire data_out_sel;
		wire temp_strobe;
		wire temp2_strobe;
		wire temp3_strobe;
		wire temp4_strobe;
		wire strobe_j, strobe_l;
		wire temp5_strobe;
		
	
		reg [19:0] state;
		reg [7:0] var_i = 0;
		reg [7:0] var_j = 0;
		reg [5:0] var_k = 0;
		reg [7:0] var_l = 0;
		reg [7:0] temp = 0;
		reg [7:0] temp2= 0;
		reg [7:0] temp3= 0;
		reg [7:0] temp4= 0;
		reg [7:0] temp5 =0;
		reg [7:0] s_key_b;
	
	
// ADDRESS READ FROM k AND DATA  WRITTEN TO DECRYPT RAM IS TEMP 5
assign address_dec = var_k; 
assign data_dec = temp5;

// NEED TO CHECK IF THE VALUES WE ARE GETTING ARE LOWER CASE LETTERS OR SPACE
logic char;
always_comb begin
	char = (temp5 >= 8'd97 & temp5 <= 8'd122) | (temp5 == 8'd32);
end

// MUX CONTROLS WHICH DATA_OUT AND ADDRESS IT IS ( EITHER s[i] or s[j]) and the mux is controled with address
assign data_out = data_out_sel ? temp2 : temp;
assign address = addr_sel[1] ? (addr_sel[0] ? 8'b0 : var_l) : (addr_sel[0] ? var_j : var_i);

//===================STROBING OUTPUTS (s[i], s[j], f, encrpted=======

always@ (posedge clock) begin

	if (reset) begin
		temp <= 0;
		temp2 <= 0;
		temp3 <= 0;
		temp4 <= 0;
		temp5 <= 0;
	end
	
	if(temp_strobe) 
		temp <= data_in; 			// temp = s[i]
		
	if(temp2_strobe)
		temp2 <= data_in;			// temp2 = s[j]

	if(temp3_strobe)
		temp3 <= data_in;			// temp3 = f
		
	if(temp4_strobe)
		temp4 <= data_rom;			// temp4 = encripted_data

	if(temp5_strobe)
		temp5 <= temp3 ^ temp4;		//temp5 = decreyped_data = ^ f xor enc_data
end

always @(posedge clock) begin
	if (reset) begin
		var_j <= 0;
		var_l <= 0;
	end
	else if(strobe_j)						//var_j = j -- for addressing working ram
		var_j <= var_j + temp;		// j = j + s[i]
	else if(strobe_l)
		var_l <= temp + temp2;		// j = s[i] + s[j]
end

// COUNTER WITH ENABLE FROM STATE MACHINE
always_ff @(posedge clock) begin
	if (reset)	
		var_i <= 0;
	else if(en_count_i) 
		var_i <= var_i + 1'b1;
	else 
		var_i <= var_i;
end

always_ff @(posedge clock) begin
	if (reset)
		var_k <= 0;
	else if(en_count_k) 
		var_k <= var_k + 1'b1;
	else 
		var_k <= var_k;
end


endmodule
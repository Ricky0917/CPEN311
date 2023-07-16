module core #(parameter low_key = 24'h0,parameter high_key = 24'h400000)
	
(
	input CLK_50M,
	input key_found,
	output not_found,
	output found,
	output [23:0] secret_key
	
);

	logic [7:0] data_from_rom, addr_rom_ram, address_dec, data_dec;
	logic [7:0] data_to_dec_mem, data_from_dec_mem;
	logic wren_to_dec_mem, write_en_s, abort;
	
	logic write_en_init, finish_init;
	logic [7:0] address_init, data_init, address_swap, data_swap_out;
	logic [7:0] data_to_mem, data_from_mem, address_to_mem;
	logic wren_to_mem;
	logic write_en_swap, swap_start, finish_swap;
	logic init_start, decode_start;
	logic [1:0] addr_data_sel;		
	logic reset;
	logic decode_finish;
	

	//FSM for task1
	initialize_memory task_one	(	.clock(CLK_50M), 	
								.start(init_start),
								.reset(reset),
								.address(address_init), 	//output [7:0] address,
								.data(data_init),//output [7:0] data,
								.finish(finish_init), //output finish,
								.write_enable(write_en_init) 	//output write_enable,							
							);


		s_memory RAM		(	.address(address_to_mem),	
							.clock(CLK_50M), 		
							.data(data_to_mem), 
							.wren(wren_to_mem),			
							.q(data_from_mem)	
						 );
//task 2A
	swap_fsm task_twoA	(	.clock(CLK_50M), 
							.start(swap_start),
							.reset(reset),
							.skey (secret_key),//input [23:0] skey
							.data_in(data_from_mem),//input [7:0] data_in,
							
							.write_enable(write_en_swap),//output write_enable, 	
							.finish(finish_swap),	//output finish,			
							.address(address_swap),	//output reg [7:0] address,	 
							.data_out(data_swap_out)//output reg [7:0] data_out	
							
						);
						
//  FSM DATA/ WRITE/ ADDRESS , BASED OFF DATA FROM FSM
 assign  data_to_mem 	= addr_data_sel[1] ? (addr_data_sel[0] ? data_dec 		:	8'b0) 	: (addr_data_sel[0] ? data_swap_out : data_init);
 assign address_to_mem 	= addr_data_sel[1] ? (addr_data_sel[0] ? address_dec 	: 8'b0) 	: (addr_data_sel[0] ? address_swap 	: address_init);
 
 assign  wren_to_mem		= addr_data_sel[1] ? (addr_data_sel[0] ? write_en_s	: 1'b0) 	: (addr_data_sel[0] ? write_en_swap : write_en_init);
 


//MASTER CONTROL the whole system

		master_fsm #(low_key,high_key)
						whole_master	(	
											.clock(CLK_50M),
											.init_finish(finish_init),	
											.swap_finish(finish_swap),	
											.decode_finish(decode_finish),
											.key_found(key_found),
											.abort(abort),
																
											.init_start(init_start),	//output init_start,																
											.swap_start(swap_start),	//output swap_start,															
											.decode_start(decode_start),	//output decode_start,	
											.addr_data_sel(addr_data_sel),//output [1:0] addr_data_sel,		
											.secret_key(secret_key),	//output reg [23:0] secret_key,			
												
											.fail(not_found),	//output fail,					
											.pass(found),	//output pass,							
											.reset(reset)//output reset
											);
	


		// ROM 
		rom_message enc_message			(.address(addr_rom_ram),		
												.clock(CLK_50M),				
												.q(data_from_rom)); // done
		// 1 PORT RAM
		ram_d_message decrypted_message(	.address(addr_rom_ram),			
													.clock(CLK_50M), 			
													.data(data_to_dec_mem), 
													.wren(wren_to_dec_mem),			
													.q(data_from_dec_mem)
												 );

												 
		/*module decode_fsm(
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
		);	*/									 
												 
		// LOOP 3 ---- DECRYPTS THE MESSAGE AND WRITES EACH LETTER INTO RAM										 
		decode_fsm task_two_B		(	.clock(CLK_50M), 
												.data_in(data_from_mem),
		
												.start(decode_start),
												.reset(reset),	
												.data_rom(data_from_rom),
												
												.address(address_dec),					
												.data_out(data_dec),
												.data_dec(data_to_dec_mem),
												.address_dec(addr_rom_ram),
												.write_enable(write_en_s),	
												.write_en_dec(wren_to_dec_mem),		
												.done(decode_finish	),			
												.bad_key(abort)						
										);
						

endmodule

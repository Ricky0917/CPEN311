`default_nettype none
module lab4_top(
		input            CLOCK_50,
	
		input            [3:0] 		KEY,	
		input            [9:0]      SW,
	
		output           [9:0]      LEDR,
		output           [6:0]      HEX0,
		output           [6:0]      HEX1,
		output           [6:0]      HEX2,
		output           [6:0]      HEX3,
		output           [6:0]      HEX4,
		output           [6:0]      HEX5  
);
	
		

		// all wires declared
	wire [7:0] data_from_rom, addr_rom_ram, address_dec, data_dec;
	wire [7:0] data_to_dec_mem, data_from_dec_mem;
	wire wren_to_dec_mem, write_en_s, abort;
	
	wire write_en_init, finish_init;
	wire [7:0] address_init, data_init, address_swap, data_swap_out;
	wire [7:0] data_to_mem, data_from_mem, address_to_mem;
	wire wren_to_mem;
	wire write_en_swap, swap_start, finish_swap;
	wire init_start, decode_finish, decode_start;
	wire [1:0] addr_data_sel;		
	wire [23:0] secret_key;
	wire reset;

	/*module init_fsm(
						input clock,
						input start,
						input reset
						output [7:0] address,
						output [7:0] data,
						output finish,
						output write_enable,
						
						);*/
	
	//FSM for task1
	initialize_memory   ini_fsm(	.clock(CLK_50M), 	
								.start(init_start),
								.reset(reset),
								.address(address_init), 	
								.data(data_init),
								.finish(finish_init), 
								.write_enable(write_en_init) 								
							); 
	
	
	
	//DECLARING LOGICS/REGS
	logic CLK_50M;
	logic  [9:0] LED = 0;
	assign CLK_50M =  CLOCK_50;
	assign LEDR[9:0] = LED[9:0];
	
	//INSTANTIATING DECODER
	logic [6:0] ssOut;
	logic [3:0] nIn;

		SevenSegmentDisplayDecoder mod (.nIn(secret_key[23:20]), .ssOut(HEX5));
		SevenSegmentDisplayDecoder mod1(.nIn(secret_key[19:16]), .ssOut(HEX4));
		SevenSegmentDisplayDecoder mod2(.nIn(secret_key[15:12]), .ssOut(HEX3));
		SevenSegmentDisplayDecoder mod3(.nIn(secret_key[11:8]), .ssOut(HEX2));
		SevenSegmentDisplayDecoder mod4(.nIn(secret_key[7:4]), .ssOut(HEX1));
		SevenSegmentDisplayDecoder mod5(.nIn(secret_key[3:0]), .ssOut(HEX0));



		s_memory RAM		(	.address(address_to_mem),	
							.clock(CLK_50M), 		
							.data(data_to_mem), 
							.wren(wren_to_mem),			
							.q(data_from_mem)	
						 );
//task 2A


/*module swap_fsm(
		input clock,
		input start,
		input reset,
		input [23:0] skey,
		input [7:0] data_in,
		
		output write_enable,
		output finish,
		output reg [7:0] address,
		output reg [7:0] data_out
		);*/
			
	swap_fsm task_twoA	(	.clock(CLK_50M), 
							.start(swap_start),
							.reset(reset),
							.skey (secret_key),
							.data_in(data_from_mem),
							
							.write_enable(write_en_swap), 	
							.finish(finish_swap),				
							.address(address_swap),		 
							.data_out(data_swap_out)	
							
						);
						
//  FSM DATA/ WRITE/ ADDRESS , BASED OFF DATA FROM FSM
 assign  data_to_mem 	= addr_data_sel[1] ? (addr_data_sel[0] ? data_dec 		:	8'b0) 	: (addr_data_sel[0] ? data_swap_out : data_init);
 assign address_to_mem 	= addr_data_sel[1] ? (addr_data_sel[0] ? address_dec 	: 8'b0) 	: (addr_data_sel[0] ? address_swap 	: address_init);
 
 assign  wren_to_mem		= addr_data_sel[1] ? (addr_data_sel[0] ? write_en_s	: 1'b0) 	: (addr_data_sel[0] ? write_en_swap : write_en_init);
 


		master_fsm whole_master	(	
											.clock(CLK_50M),
											.init_finish(finish_init),	
											.swap_finish(finish_swap),	
											.decode_finish(decode_finish),
											.abort(abort),
																
											.init_start(init_start),																	
											.swap_start(swap_start),																
											.decode_start(decode_start),		
											.addr_data_sel(addr_data_sel),		
											.secret_key(secret_key),				
												
											.fail(LED[9]),						
											.pass(LED[8]),								
											.reset(reset)
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
												.done(decode_finish),			
												.bad_key(abort)						
										);
						


								

endmodule

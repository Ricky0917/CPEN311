`default_nettype none
module lab4_top(
   
    CLOCK_50,
   
    LEDR,

    KEY,

    SW,

    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5
);
	
		input            CLOCK_50;
	
		input            [3:0] 		KEY;	
		input            [9:0]      SW;
	
		output           [9:0]      LEDR;
		output           [6:0]      HEX0;
		output           [6:0]      HEX1;
		output           [6:0]      HEX2;
		output           [6:0]      HEX3;
		output           [6:0]      HEX4;
		output           [6:0]      HEX5;

		//wire declarication
		logic CLK_50M;
		logic  [9:0] LED = 0;
		assign CLK_50M =  CLOCK_50;
		assign LEDR[9:0] = LED[9:0];


		logic [6:0] ssOut;
		logic [3:0] nIn;
		logic [23:0] hex_data_in;
		wire [23:0] secret_key_1, secret_key_2, secret_key_3, secret_key_4;
		wire [3:0] found, not_found;
		wire key_found;
		
		SevenSegmentDisplayDecoder mod (.nIn(hex_data_in[23:20]), .ssOut(HEX5));
		SevenSegmentDisplayDecoder mod1(.nIn(hex_data_in[19:16]), .ssOut(HEX4));
		SevenSegmentDisplayDecoder mod2(.nIn(hex_data_in[15:12]), .ssOut(HEX3));
		SevenSegmentDisplayDecoder mod3(.nIn(hex_data_in[11:8]), .ssOut(HEX2));
		SevenSegmentDisplayDecoder mod4(.nIn(hex_data_in[7:4]), .ssOut(HEX1));
		SevenSegmentDisplayDecoder mod5(.nIn(hex_data_in[3:0]), .ssOut(HEX0));
		
	

//break into 4 searching parts, when found, the LEDR 6-9 will be on for one
		assign {LED[6], LED[7], LED[8], LED[9]} = found;//if founded from 0_40000, 40000~80000, 80000~120000, 120000~160000, led9,8,7,6 = 1
		
// if no found then led0 on, found LED1 on
		assign LED[0] = & not_found;
		assign LED[1]= key_found;
//if one found is one then key found is 1
		assign key_found = | found;
		
	//	module core #(parameter low_key = 0,parameter high_key = 24'h400000)
	//(input CLK_50M,
//input key_found,
//	output not_found,
//	output found,
//	output [23:0] secret_key);
	
	//endmodule

// break into 4 cores each search for h'100000 secret message
	core #(24'h0, 24'h40000) core_1(//searching code from 0 to 40000
		 .CLK_50M(CLK_50M),
		 .key_found(key_found),
		 .not_found(not_found[0]),
		 .found(found[0]),
		 .secret_key(secret_key_1));
		 
	core #(24'h40000, 24'h80000) core_2(//searching code from 40000 to 80000
		 .CLK_50M(CLK_50M),
		 .key_found(key_found),
		 .not_found(not_found[1]),
		 .found(found[1]),
		 .secret_key(secret_key_2));
		 
	core #(24'h80000, 24'h120000) core_3(
		 .CLK_50M(CLK_50M),
		 .key_found(key_found),
		 .not_found(not_found[2]),
		 .found(found[2]),
		 .secret_key(secret_key_3));
		 
	core #(24'h120000, 24'h400000) core_4(
		 .CLK_50M(CLK_50M),
		 .key_found(key_found),
		 .not_found(not_found[3]),
		 .found(found[3]),
		 .secret_key(secret_key_4));
	
	always @(*) begin
	case (found)
		4'b0001:	hex_data_in <= secret_key_1;
		4'b0010:	hex_data_in <= secret_key_2; 
		4'b0100:	hex_data_in <= secret_key_3;
		4'b1000:	hex_data_in <= secret_key_4;
		4'b0000: hex_data_in <= {4'hF,secret_key_1[19:0]};
		default:	hex_data_in <= 24'hz;
	endcase
	end	
	
	
endmodule	



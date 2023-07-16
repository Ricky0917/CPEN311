module led_control(input logic clk_1s, output logic [7:0] leds);

	reg [3:0] state;
	reg [3:0] next_state;
	
	parameter [3:0] led0 = 4'd0;
	parameter [3:0] led1 = 4'd1;
	parameter [3:0] led2 = 4'd2;
	parameter [3:0] led3 = 4'd3;
	parameter [3:0] led4 = 4'd4;
	parameter [3:0] led5 = 4'd5;
	parameter [3:0] led6 = 4'd6;
	parameter [3:0] led7 = 4'd7;
	
	parameter [3:0] led_1 = 4'd13;
	parameter [3:0] led_2 = 4'd12;
	parameter [3:0] led_3 = 4'd11;
	parameter [3:0] led_4 = 4'd10;
	parameter [3:0] led_5 = 4'd9;
	parameter [3:0] led_6 = 4'd8;
	
	always_ff @(posedge clk_1s) begin
		state <= next_state;
	end
	
	always_comb begin
		case(state)
			led0: next_state = led1;
			led1: next_state = led2;
			led2: next_state = led3;
			led3: next_state = led4;
			led4: next_state = led5;
			led5: next_state = led6;
			led6: next_state = led7;
			
			led7: next_state = led_6;
			led_6: next_state = led_5;
			led_5: next_state = led_4;
			led_4: next_state = led_3;
			led_3: next_state = led_2;
			led_2: next_state = led_1;
			led_1: next_state = led0;
			default: next_state = led0;
		endcase
	end
	
	always_comb begin
		case(state)
			led0: leds = 8'b0000_0001;
			led1: leds = 8'b0000_0010;
			led2: leds = 8'b0000_0100;
			led3: leds = 8'b0000_1000;
			led4: leds = 8'b0001_0000;
			led5: leds = 8'b0010_0000;
			led6: leds = 8'b0100_0000;
			led7: leds = 8'b1000_0000;
	
			led_1: leds = 8'b0000_0010;
			led_2: leds = 8'b0000_0100;
			led_3: leds = 8'b0000_1000;
			led_4: leds = 8'b0001_0000;
			led_5: leds = 8'b0010_0000;
			led_6: leds = 8'b0100_0000;
			default: leds = 8'b0000_0000;
		endcase
	end
	
endmodule	
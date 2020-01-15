// This takes 8 bit vector in and uses that as the DATA for the LED. 
// It spits out the 8 bits to the SR - so lets call it sr_controller.
// The logic is very simple, really only one assign statement
// Implements clk_div 

module sr_ctrl(
	input [7:0] data_in, // 8 data values for 8 LEDs
	input clk_200, // 50MHz FPGA clock
	//input LED_reset, // A signal to say when to send 50 us of 0 (LED reset)
	output sr_clk, // 20MHz serial clock for clocking out
	output r_clk, // 2.5MHz register clock (latch clock).
	output ser_out, // serial outputs to shift register (1 at a time)
	input ar // Asynchronous reset
	);

wire clk_200; // 200 MHz clock for logic

reg [7:0] reset_count = 8'd0;
reg [2:0] sr_count = 3'd0; //if this is 7, a rising edge occured on the r_clk;
reg [1:0] st;
parameter [1:0] reset = 2'b00, // Reset state 
				send_one = 2'b01, // State that sends 1
				send_data = 2'b10; // State that sends data_in

reg t_flag = 0;
reg [7:0] out_data;


	
clk_div clks ( // Clock divider
	.ar(ar),
	.clk_in(clk_200), 
	//.clk_out0(logic_clk), //25 MHz, NOT USING THIS, CHANGE clk_div
	.clk_out1(sr_clk), //20 MHz
	.clk_out2(r_clk) //2.5 MHz
	);
	
assign ser_out = (st == send_one) ? 1'b1 : // Send 1
	(st == send_data) ? data_in[sr_count] : // Send data_in
	1'b0; // Otherwise, send 0's
	
always @ (negedge sr_clk or negedge ar) begin // This clocks out the serial data
	if(~ar)
		sr_count <= 3'd0; // Handles a reset
	else 
		begin
			sr_count = sr_count + 1;
			if(sr_count == 7)
				begin
					if(st == 2'b10)
						st = 0;
					else
						st = st + 1;
				end
		end
end

endmodule
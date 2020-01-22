// This takes 8 bit vector in and uses that as the DATA for the LED. 
// It spits out the 8 bits to the SR - so lets call it sr_controller.
// The logic is very simple, really only one assign statement
// Implements clk_div 

module sr_ctrl_rev2(
	//input clk_in,
	input [7:0] data_in, // 8 data values for 8 parallel LEDs
	input sr_clk,
	//input LED_reset, // A signal to say when to send 50 us of 0 (LED reset)
	output ser_out, // serial outputs to shift register (1 at a time)
	input ar // Asynchronous reset
	);

//wire clk_200 = clk_in; // 200 MHz clock for logic

reg [7:0] reset_count = 8'd0;
reg [2:0] sr_count = 3'd0; //if this is 7, a rising edge occured on the r_clk;
reg [1:0] st;
parameter [1:0] reset = 2'b00, // Reset state 
				send_one = 2'b01, // State that sends 1
				send_data = 2'b10; // State that sends data_in

reg t_flag = 0;
reg [7:0] out_data;
	
assign ser_out = (st == send_one) ? 1'b1 : // Send 1
	(st == send_data) ? data_in[sr_count] : // Send data_in
	1'b0; // Otherwise, send 0's
	
always @ (posedge sr_clk or negedge ar) begin // Recieves LED data from top_led
	if(~ar)
		out_data = 0;// Handle reset on input loop
	else
		begin
			out_data <= data_in;
		end // top else
end // always block
	
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
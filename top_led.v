// Top Level File for sr_ctrl.v
// Stores a 2D array of frames

module top_led(
	input clk_in,
	input ar,
	output data_out,
	output sr_clk, // 20MHz serial clock for clocking out
	output r_clk // 2.5MHz register clock (latch clock).
	);
	
wire [119:0] frame [7:0]; // For 5 LEDS, 8 strands

/* 8 Green bits, 8 Red bits, 8 Blue bits
	Below data represents one frame, which will be sent into the shift register controller
	In the final design, the frame values will come from the HDMI decoder, 
   and we will have to clock in these values */

assign frame[0] = 120'hff000000ff000000ffff0000ffffff; // G,R,B,G,White
assign frame[1] = 120'hff000000ff000000ffff0000ffffff; // G,R,B,G,White
assign frame[2] = 0;
assign frame[3] = 0;
assign frame[4] = 0;
assign frame[5] = 0;
assign frame[6] = 0;
assign frame[7] = 0;

sys_clk ppl ( // PLL generator
	.inclk0(clk_in), // input clock
	//.areset(ar), // input reset, giving issues for some reason
	.c0(clk_200), // 200 MHz
	); //
	
clk_div clks ( // Clock divider
	.ar(ar),
	.clk_in(clk_200), 
	//.clk_out0(logic_clk), //25 MHz, NOT USING THIS, CHANGE clk_div
	.clk_out1(sr_clk), //20 MHz
	.clk_out2(r_clk) //2.5 MHz
	);

wire clk_200;
wire [7:0] sr0_data; // what we will give to sr_ctrl for the 0th shift register

assign sr0_data[0] = frame[0][n]; // n lets us pick the data value, 
assign sr0_data[1] = frame[1][n]; // will need to loop through it 
assign sr0_data[2] = frame[2][n];
assign sr0_data[3] = frame[3][n];
assign sr0_data[4] = frame[4][n];
assign sr0_data[5] = frame[5][n];
assign sr0_data[6] = frame[6][n];
assign sr0_data[7] = frame[7][n];		

reg n = 0; //Bit index OR could be the index for LEDs

sr_ctrl_rev2 sr0(
	//.clk_in(clk_200),
	.data_in(s0_data),
	.sr_clk(sr_clk),
	.ar(ar)
	);
	
always @ (posedge sr_clk /*or negedge ar*/) begin // clocking values to sr0 at 200 MHz
	if(~ar)
		n = 0; // Handles a reset, not sure what that will mean right now
	else 
		begin
			n <= n + 1;
		end // top else
end // always block
	
endmodule
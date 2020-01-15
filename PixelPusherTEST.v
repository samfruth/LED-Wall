//Description of the Pixel Pusher
module PixelPusherTEST (/*pix_in,*/Reset, clk_in, ser_out, r_clk, sr_clk);

input clk_in, Reset;
output wire r_clk, sr_clk;
output reg ser_out;

//wire pix_in; // hardcoding these values
//reg clk_in;
wire clk_100, clk_24, clk_2_5, clk_5;

wire pix_in; // 24 bits for 8 pixels (8 pixels of data)
reg [1:0] st;
parameter [1:0] StA = 2'b00, StB = 2'b01, StC = 2'b10, StD = 2'b11; // StA is reset state
parameter pix_offset = 24; //not needed anymore
reg l_flag; // Flag that says if a latch has occured

sys_clk ppl (.inclk0(clk_in),
	.c0(clk_100), // 100 MHz
	.c1(sr_clk), // 24 Mhz DONT USE
	.c2(r_clk), // 2.5 MHz DONT USE
	.c3(clk_5) // 5 Mhz, twice that of r_clk DONT USE
	); //
/* What does pix_in look like?
	It gives serial input of the 8 LED strips that the SR controls
	Strip 0 - 7 (s0 - s7) below:

	s0 ---------------------------- 16 8  0
	s1 ---------------------------- 17 9  1
	s2 ---------------------------- 18 10 2
	s3 ---------------------------- 19 11 3
	s4 ---------------------------- 20 12 4
	s5 ---------------------------- 21 13 5
	s6 ---------------------------- 22 14 6
	s7 ---------------------------- 23 15 7

	Values above represent the order of the data coming in through pix_in
	Begins with the first LED value at the specific column.

	So the value at pixel_in[0] would be the B0 bit of the 0 spot LED
*/

/*
Not sure which is first:
G7 G6 G5 G4 G3 G2 G1 G0 R7 R6 R5 R4 R3 R2 R1 R0 B7 B6 B5 B4 B3 B2 B1 B0
*/
reg ser_vals;



always @(posedge clk_100 or negedge Reset)
begin // This is the loop for logic to occur
	// Builds the ser_out wire

	//Always send a 1 first, then the data, then a 0
	//The period of each is 0.4 us
	//A 1 looks like: 110
	//A 0 looks like: 100

	if(~Reset)
		begin // Reset case
			st = StA;
		end
	else
		begin
		case(st) //sets the values, but does not clock them out.
			StA:
				//StA description: Reset state
				st = StB;
			StB:
				begin //StB description: send the 1
					ser_vals = 8'b11111111;
					if(l_flag)
						begin
						//l_flag <= 0;
						st = StC; // go to next stage when latch is executed (should be done by then)
						end
				end	
			StC:
				//StC description: send the data (dependent on pix_in)
				begin
					ser_vals = 8'b11111111; // all 1 for test
					if(l_flag)
						begin
						//l_flag <= 0;
						st = StD; // go to next stage when latch is executed (should be done by then)
						end
				end
			StD:
				//StD descrption: send the 0
				begin
					ser_vals = 8'b00000000;
					if(l_flag)
						begin
						//l_flag <= 0;
						st = StA;
						end
				end
			endcase
			end
		
end //end clk_100

always @(posedge sr_clk)
begin // This is the loop for SRCLK (serial in)
	//This will handle the serial input entering the SR
	ser_out <= ser_vals;

end //end clk_24

always @(posedge clk_5)
begin // This is the loop for RCLK (parallel out latch clock)

l_flag = ~l_flag;

end //end clk_2_5

endmodule

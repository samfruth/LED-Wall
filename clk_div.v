// 50 MHz Clock divider
// Want it to be a 20 and 2.5 Mhz clock output from 200 MHz PLL clock
// clk_div.v
//

module clk_div(ar, clk_in, clk_out1, clk_out2);
    input ar;
    input wire clk_in;         // 50 MHz for audio codec on DE2 board -> WILL BE 200 MHZ
    output reg clk_out1, clk_out2; // 25 MHz, 20MHz and 2.5MHz
	
	parameter m = 3;      // Bit width of counter and limit (log2 of limit)
    parameter [m-1:0] limit1 = 3'd5; //for 20 MHz
    reg [m-1:0]   count1;
	 
	parameter p = 6;      // Bit width of counter and limit (log2 of limit)
    parameter [p-1:0] limit2 = 6'd40; //for 2.5 MHz
    reg [p-1:0]   count2;
    
	//Controls the 20 MHz clock output  
	always @(negedge ar or posedge clk_in)
    if(~ar)
       begin
          count1 = 0;
		  clk_out1 = 1'b0;
       end
    else
      begin    
       if(count1 >= limit1)
         begin
			 clk_out1 = ~clk_out1;
				
			 count1 = 0;
		 end
		else
			count1 = count1 + 1;
      end
		
	//Controls the 2.5 MHz clock output  
	always @(negedge ar or posedge clk_in)
    if(~ar)
       begin
          count2 = 0;
		  clk_out2 = 1'b0;
       end
    else
      begin   
       if(count2 >= limit2)
         begin
			 clk_out2 = ~clk_out2;
				
			 count2 = 0;
		 end
		else
			count2 = count2 + 1;
      end
                                                                                                                                                                                                              
 endmodule 

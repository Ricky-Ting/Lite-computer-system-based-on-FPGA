module Screen(SW, CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_VS, VGA_HS, addr, color);
	input CLOCK_50; 
	input SW;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	//wire clk_change;
	output VGA_CLK;
	output VGA_SYNC_N;
	output VGA_BLANK_N;
	output VGA_VS;
	output VGA_HS;
	
	//wire reset;
	input [11:0] color;
	output wire [18:0] addr;
	wire term;
	
	assign VGA_SYNC_N = 0;
	//assign reset = 0;
	
	//timer_25mhz my_vgaclk(CLOCK_50, 1'b1, clk_change);
	//timer_60hz T(CLOCK_50, 1'b1, VGA_CLK);
	clkgen #(25000000) my_vgaclk1(CLOCK_50,SW,1'b1,VGA_CLK);
	vga_ctrl V(VGA_CLK, SW, {color[11:8], 4'b0, color[7:4], 4'b0, color[3:0], 4'b0}, addr[18:9], {term, addr[8:0]}, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_R, VGA_G, VGA_B);
	
endmodule 
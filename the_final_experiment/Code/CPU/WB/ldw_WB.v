module ldw_WB(walu, wmo, wm2reg, wdi);
	input [31:0] walu, wmo;
	input wm2reg;
	output reg [31:0] wdi;
	
	initial
		wdi = 0;
		
	always@(walu or wmo or wm2reg)
	begin
		case(wm2reg)
			1'b0: wdi = walu;
			1'b1: wdi = wmo;
		endcase
	end
	
endmodule 
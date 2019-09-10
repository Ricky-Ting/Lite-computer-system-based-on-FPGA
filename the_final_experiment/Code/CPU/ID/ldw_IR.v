module ldw_IR(pc4, ins, wir, clk, clrn, dpc4, inst);
	input [31:0] pc4, ins;
	input wir, clk, clrn;
	output [31:0] dpc4, inst;
	
	dffe32 pc4_r(.d(pc4), .clk(clk), .clrn(clrn), .e(wir), .q(dpc4));
	dffe32 ins_r(.d(ins), .clk(clk), .clrn(clrn), .e(wir), .q(inst));
	
endmodule 
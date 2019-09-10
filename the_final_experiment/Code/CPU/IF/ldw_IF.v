module ldw_IF(pcsource, pc, bpc, rpc, jpc, npc, pc4, ins, clk);
	input [31:0] pc, bpc, rpc, jpc;
	input [1:0] pcsource;
	input clk;
	output [31:0] pc4, ins;
	output reg [31:0] npc;
	
	initial
		npc = 0;
	
	assign pc4 = pc + 32'h4;
	
	always@(pc4 or bpc or rpc or jpc or pcsource)
	begin
		case(pcsource)
			2'b00: npc = pc4;
			2'b01: npc = bpc;
			2'b10: npc = rpc;
			2'b11: npc = jpc;
		endcase
	end
	
	ldw_IMem get_ins(.a(pc), .inst(ins), .clk(~clk));//特别注意会不会出问题
	
endmodule 
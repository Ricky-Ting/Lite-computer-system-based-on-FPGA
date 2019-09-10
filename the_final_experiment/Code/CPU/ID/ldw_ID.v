module ldw_ID(mwreg, mrn, ern, ewreg, em2reg, mm2reg, dpc4, inst, wrn, wdi, ealu, malu, mmo, wwreg, clk, clrn,
					bpc, jpc, pcsource, nostall, wreg, m2reg, wmem, aluc, aluimm, a, b, imm, rn, shift, jal);
	input [31:0] dpc4, inst, wdi, ealu, malu, mmo;
	input [4:0] ern, mrn, wrn;
	input mwreg, ewreg, em2reg, mm2reg, wwreg;
	input clk, clrn;
	
	output reg [31:0] a, b;
	output [31 :0] bpc,jpc,imm;
	output reg [4:0] rn;
	output [3:0] aluc;
	output [1:0] pcsource;
	output nostall, wreg, m2reg, wmem, aluimm, shift, jal;
	
	wire [5:0] op, func;
	wire [4:0] rs, rt, rd;
	wire [31:0] qa, qb, br_offset;
	wire [15:0] ext16;
	wire [1:0] fwda, fwdb;
	wire regrt, sext, rsrtequ, e;
	
	initial
	begin
		rn = 0;
		a = 0;
		b = 0;
	end
	
	//指令拆解
	assign func = inst[5:0];
	assign op = inst[31:26];
	assign rs = inst[25:21];
	assign rt = inst[20:16];
	assign rd = inst[15:11];
	assign jpc = {dpc4[31:28], inst[25:0], 2'b00};
	
	ldw_CU CU(.mwreg(mwreg), .mrn(mrn), .ern(ern), .ewreg(ewreg), .em2reg(em2reg), .mm2reg(mm2reg),
					.rsrtequ(rsrtequ), .func(func), .op(op), .rs(rs), .rt(rt), .wreg(wreg), .m2reg(m2reg),
					.wmem(wmem), .aluc(aluc), .regrt(regrt), .aluimm(aluimm), .fwda(fwda), .fwdb(fwdb), 
					.nostall(nostall), .sext(sext), .pcsource(pcsource), .shift(shift), .jal(jal));
	ldw_RegFile RF(.rna(rs), .rnb(rt), .d(wdi), .wn(wrn), .we(wwreg), .clk(~clk), .clrn(clrn), .qa(qa), .qb(qb));
	
	always@(rd or rt or regrt)
	begin
		case(regrt)
			1'b0: rn = rd;
			1'b1: rn = rt;
		endcase
	end
	
	always@(qa or qb or ealu or malu or mmo or fwda or fwdb)
	begin
		case(fwda)
			2'b00: a = qa;
			2'b01: a = ealu;
			2'b10: a = malu;
			2'b11: a = mmo;
		endcase
		
		case(fwdb)
			2'b00: b = qb;
			2'b01: b = ealu;
			2'b10: b = malu;
			2'b11: b = mmo;
		endcase
	end
	
	assign rsrtequ = ~|(a^b); //rsrtequ = (a == b)
	assign e = sext & inst[15];
	assign ext16 = {16{e}};
	assign imm = {ext16, inst[15:0]};
	assign br_offset = {imm[29:0], 2'b00};
	assign bpc = dpc4 + br_offset;
	
endmodule 
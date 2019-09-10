module ldw_CU(mwreg, mrn, ern, ewreg, em2reg, mm2reg,
					rsrtequ, func, op, rs, rt, wreg, m2reg,
					wmem, aluc, regrt, aluimm, fwda, fwdb, 
					nostall, sext, pcsource, shift, jal);
	input mwreg, ewreg, em2reg, mm2reg, rsrtequ;
	input [4:0] mrn, ern, rs, rt;
	input [5:0] func, op;
	output wreg, m2reg, wmem, regrt, aluimm, sext, shift, jal;
	output [3:0] aluc;
	output [1:0] pcsource;
	output [1:0] fwda, fwdb;
	output nostall;//不暂停开关 由于lw的依赖性，所以设置这个
	reg [1:0] fwda, fwdb;
	//reg r_type;
	reg i_add, i_sub, i_and, i_or, i_xor, i_sll, i_srl, i_sra, i_jr;
	reg i_addi, i_andi, i_ori, i_xori, i_lw, i_sw, i_beq, i_bne, i_lui, i_j, i_jal;
	reg i_rs, i_rt;
	
	initial
	begin
		//r_type = 0;
		fwda = 0; fwdb = 0;
		i_add = 0; i_sub = 0; i_and = 0; i_or = 0; i_xor = 0; i_sll = 0; i_srl = 0; i_sra = 0; i_jr = 0;
		i_addi = 0; i_andi = 0; i_ori = 0; i_xori = 0; i_lw = 0; i_sw = 0; i_beq = 0; i_bne = 0; i_lui = 0; i_j = 0; i_jal = 0;
		i_rs = 0; i_rt = 0;
	end
	
	//表格参照121页
	always@(op or func)
	begin
		i_add = 0; i_sub = 0; i_and = 0; i_or = 0; i_xor = 0; i_sll = 0; i_srl = 0; i_sra = 0; i_jr = 0;
		i_addi = 0; i_andi = 0; i_ori = 0; i_xori = 0; i_lw = 0; i_sw = 0; i_beq= 0; i_bne = 0; i_lui = 0; i_j = 0; i_jal = 0;
		i_rs = 0; i_rt = 0;
		case(op)
			//R指令
			6'b000000:
				case(func)
					6'b100000:	begin i_add		= 1'b1;	i_rs = 1'b1;	i_rt = 1'b1;	end
					6'b100010:	begin i_sub		= 1'b1;	i_rs = 1'b1;	i_rt = 1'b1;	end
					6'b100100:	begin i_and		= 1'b1;	i_rs = 1'b1;	i_rt = 1'b1;	end
					6'b100101:	begin i_or		= 1'b1;	i_rs = 1'b1;	i_rt = 1'b1;	end
					6'b100110:	begin i_xor		= 1'b1;	i_rs = 1'b1;	i_rt = 1'b1;	end
					6'b000000:	begin i_sll		= 1'b1;						i_rt = 1'b1;	end
					6'b000010:	begin i_srl		= 1'b1;						i_rt = 1'b1;	end
					6'b000011:	begin i_sra		= 1'b1;						i_rt = 1'b1;	end
					6'b001000:	begin i_jr		= 1'b1;	i_rs = 1'b1;						end
					default: ;
				endcase
			//I指令
			6'b001000:			begin i_addi	= 1'b1;	i_rs = 1'b1;						end
			6'b001100:			begin i_andi	= 1'b1;	i_rs = 1'b1;						end
			6'b001101:			begin i_ori		= 1'b1;	i_rs = 1'b1;						end
			6'b001110:			begin i_xori	= 1'b1;	i_rs = 1'b1;						end
			6'b100011:			begin i_lw		= 1'b1;	i_rs = 1'b1;						end
			6'b101011:			begin i_sw 		= 1'b1;	i_rs = 1'b1;	i_rt = 1'b1;	end
			6'b000100:			begin i_beq		= 1'b1;	i_rs = 1'b1;	i_rt = 1'b1;	end
			6'b000101:			begin i_bne		= 1'b1;	i_rs = 1'b1;	i_rt = 1'b1;	end
			6'b001111:			begin i_lui		= 1'b1;											end
			//J指令
			6'b000010:			begin	i_j		= 1'b1;											end
			6'b000011:			begin	i_jal		= 1'b1;											end
			
			default ;
		endcase
	end
	
	//不暂停开关 由于lw的依赖性，所以设置这个
	assign nostall = ~(ewreg & em2reg & (ern != 0) & (i_rs & (ern == rs) |
																	  i_rt & (ern == rt )));
	
	always@(ewreg or mwreg or ern or mrn or em2reg or mm2reg or rs or rt)
	begin
		//先检查rs
		fwda = 2'b00;
		if(ewreg & (ern != 0) & (ern == rs) & ~em2reg)
			fwda = 2'b01;//和后第一条指令冲突，rs的数据从EXE阶段的ALU中取数据
		else if(mwreg & (mrn != 0) & (mrn == rs) & ~mm2reg)
			fwda = 2'b10;//和后面第二条指令冲突，且该指令不是lw指令，故从MEM阶段的ALU中取数据
		else if(mwreg & (mrn != 0) & (mrn == rs) & mm2reg)
			fwda = 2'b11;//和后面第二条指令冲突，且该指令是lw指令，故从特殊操作
			
		//再检查rt
		fwdb = 2'b00;
		if(ewreg & (ern != 0) & (ern == rt) & ~em2reg)
			fwdb = 2'b01;
		else if(mwreg & (mrn != 0) & (mrn == rt) & ~mm2reg)
			fwdb = 2'b10;
		else if(mwreg & (mrn != 0) & (mrn == rt) & mm2reg)
			fwdb = 2'b11;
	end
	
	//控制信号部分
	assign wreg		=(i_add	|	i_sub	|	i_and	|	i_or	|	i_xor	|	i_sll	|	i_srl |	i_sra	|
						  i_addi	|	i_andi|	i_ori	|	i_xori|	i_lw	|	i_lui	|	i_jal) & nostall;
	assign regrt	= i_addi	|	i_andi|	i_ori	|	i_xori|	i_lw	|	i_lui;
	assign jal 		= i_jal;
	assign m2reg 	= i_lw;
	assign shift	= i_sll	|	i_srl	|	i_sra;
	assign aluimm	= i_addi	|	i_andi|	i_ori	|	i_xori|	i_lw	|	i_lui	|	i_sw;
	assign sext		= i_addi	|	i_lw	|	i_sw	|	i_beq	|	i_bne;
	assign aluc[3]	= i_sra;
	assign aluc[2] = i_sub	|	i_or	|	i_srl	|	i_sra	|	i_ori	|	i_lui;
	assign aluc[1] = i_xor	|	i_sll	|	i_srl	|	i_sra	|	i_xori|	i_beq	|	i_bne	|	i_lui;
	assign aluc[0] = i_and	|	i_or	|	i_sll	|	i_srl	|	i_sra	|	i_andi|	i_ori;
	assign wmem		= i_sw & nostall;
	assign pcsource[1] = i_jr | i_j | i_jal;
	assign pcsource[0] = i_beq & rsrtequ | i_bne & ~rsrtequ | i_j | i_jal; 
	
endmodule 
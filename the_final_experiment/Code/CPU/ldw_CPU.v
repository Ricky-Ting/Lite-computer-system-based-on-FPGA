module ldw_CPU(clock, resetn, pc, inst, ealu, malu, walu, cpuMem_w, cpuMem_in_addr, cpuMem_in_data, cpuMem_out_data);
	input clock, resetn;
	output [31:0] pc, inst, ealu, malu, walu;
	wire [31:0] bpc, jpc, npc, pc4, ins, dpc4, inst, da, db, dimm, ea, eb, eimm;
	wire [31:0] epc4, mb, mmo, wmo, wdi;
	wire [4:0] drn, ern0, ern, mrn, wrn;
	wire [3:0] daluc, ealuc;
	wire [1:0] pcsource;
	wire wpcir;
	wire dwreg, dm2reg, dwmem, daluimm, dshift, djal;
	wire ewreg, em2reg, ewmem, ealuimm, eshift, ejal;
	wire mwreg, mm2reg, mwmem;
	wire wwreg, wm2reg;
	
	output wire cpuMem_w = mwmem & ~clock;
	output wire [31:0] cpuMem_in_addr = malu;
	output wire [31:0] cpuMem_in_data = mb;
	input [31:0] cpuMem_out_data;
	assign mmo = cpuMem_out_data;
	
	
	ldw_PC		PC(.npc(npc), .wpc(wpcir), .clk(clock), .clrn(resetn), .pc(pc));
	ldw_IF		IF(.pcsource(pcsource), .pc(pc), .bpc(bpc), .rpc(da), .jpc(jpc), .npc(npc), .pc4(pc4), .ins(ins), .clk(clock));//这里在给IMem的时钟取了反，可能会出问题，留意
	
	ldw_IR		IR(.pc4(pc4), .ins(ins), .wir(wpcir), .clk(clock), .clrn(resetn), .dpc4(dpc4), .inst(inst));
	ldw_ID		ID(.mwreg(mwreg), .mrn(mrn), .ern(ern), .ewreg(ewreg), .em2reg(em2reg), .mm2reg(mm2reg), .dpc4(dpc4),
						.inst(inst), .wrn(wrn), .wdi(wdi), .ealu(ealu), .malu(malu), .mmo(mmo), .wwreg(wwreg), .clk(clock), .clrn(resetn),
						.bpc(bpc), .jpc(jpc), .pcsource(pcsource), .nostall(wpcir), .wreg(dwreg), .m2reg(dm2reg), .wmem(dwmem),
						.aluc(daluc), .aluimm(daluimm), .a(da), .b(db), .imm(dimm), .rn(drn), .shift(dshift), .jal(djal));
	
	ldw_DEReg	DEReg(.dwreg(dwreg), .dm2reg(dm2reg), .dwmem(dwmem), .daluc(daluc), .daluimm(daluimm), .da(da), .db(db), .dimm(dimm), .drn(drn), .dshift(dshift),
						.djal(djal), .dpc4(dpc4), .clk(clock), .clrn(resetn), .ewreg(ewreg), .em2reg(em2reg), .ewmem(ewmem), .ealuc(ealuc), .ealuimm(ealuimm), .ea(ea),
						.eb(eb), .eimm(eimm), .ern(ern0), .eshift(eshift), .ejal(ejal), .epc4(epc4)) ; 
	ldw_EXE		EXE(.ealuc(ealuc), .ealuimm(ealuimm), .ea(ea), .eb(eb), .eimm(eimm), .eshift(eshift), .ern0(ern0), .epc4(epc4), .ejal(ejal), .ern(ern), .ealu(ealu));
	
	ldw_EMReg	EMReg(.ewreg(ewreg), .em2reg(em2reg), .ewmem(ewmem), .ealu(ealu), .eb(eb), .ern(ern), .clk(clock), .clrn(resetn), .mwreg(mwreg), .mm2reg(mm2reg), .mwmem(mwmem), .malu(malu), .mb(mb), .mrn(mrn));
	//ldw_MEM		MEM(.we(mwmem), .addr(malu), .datain(mb), .clk(clock), .inclk(memclock), .outclk(memclock), .dataout(mmo));
	
	ldw_MWReg	MWReg(.mwreg(mwreg), .mm2reg(mm2reg), .mmo(mmo), .malu(malu), .mrn(mrn), .clk(clock), .clrn(resetn), .wwreg(wwreg), .wm2reg(wm2reg), .wmo(wmo), .walu(walu), .wrn(wrn));
	ldw_WB		WBldw_WB(.walu(walu), .wmo(wmo), .wm2reg(wm2reg), .wdi(wdi));
endmodule 
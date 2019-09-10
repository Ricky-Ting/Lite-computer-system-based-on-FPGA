module ldw_EXE(ealuc, ealuimm, ea, eb, eimm, eshift, ern0, epc4, ejal, ern, ealu);
	input [31:0] ea, eb, eimm, epc4;
	input [4:0] ern0;
	input [3:0] ealuc;
	input ealuimm, eshift, ejal;
	output reg [31:0] ealu;
	output [4:0] ern;
	reg [31:0] alua, alub;
	wire [31:0] sa, ealu0, epc8;
	wire z;
	
	initial
	begin
		ealu = 0;
		alua = 0;
		alub = 0;
	end
	
	assign sa = {eimm[5:0], eimm[31:6]};
	assign epc8 = epc4 + 32'h4;
	
	always@(ea or sa or eshift)
	begin
		case(eshift)
			1'b0: alua = ea;
			1'b1: alua = sa;
		endcase
	end
	
	always@(eb or eimm or ealuimm)
	begin
		case(ealuimm)
			1'b0: alub = eb;
			1'b1: alub = eimm;
		endcase
	end
	
	always@(ealu0 or epc8 or ejal)
	begin
		case(ejal)
			1'b0: ealu = ealu0;
			1'b1: ealu = epc8;
		endcase
	end
	
	assign ern = ern0 | {5{ejal}};
	ldw_ALU ALU(.a(alua), .b(alub), .op(ealuc), .r(ealu0), .z(z));
	
endmodule 
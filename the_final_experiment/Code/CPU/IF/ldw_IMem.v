module ldw_IMem(a, inst, clk);
	input [31:0] a;
	input clk;
	output [31:0] inst;
	
	IMem m(
	a[11:2],
	,
	clk,
	,
	,
	,
	1'b0,
	,
	inst,
	);
	
	/*
	lpm_rom lpm_rom_component (.address(a[7:2]), .q(inst));
	defparam lpm_rom_component.lpm_width = 32,
				lpm_rom_component.lpm_widthad = 6,
				lpm_rom_component.lpm_numwords = "unused",
				lpm_rom_component.lpm_file = "IMem.mif",
				lpm_rom_component.lpm_indata = "unused",
				lpm_rom_component.lpm_outdata = "unregistered",
				lpm_rom_component.lpm_address_control = "unregistered"; 
	*/
endmodule 
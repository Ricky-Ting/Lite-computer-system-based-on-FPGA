//模块废弃不用
module ldw_MEM(we, addr, datain, clk, inclk, outclk, dataout);
	input [31:0] addr, datain;
	input clk, we, inclk, outclk;
	output [31:0] dataout;
	
	wire write_enable = we & ~clk;
	
	Mem m(
	addr[6:2],
	,
	datain,
	,
	inclk,
	outclk,
	write_enable,
	,
	dataout,
	);
	
endmodule 
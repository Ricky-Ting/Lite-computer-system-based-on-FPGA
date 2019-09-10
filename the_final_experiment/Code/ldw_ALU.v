module ldw_ALU(a, b, op, r, z);
	input [31:0] a, b;
	input [3:0] op;
	output reg [31:0] r;
	output z;
	
	initial
		r = 0;
	
	always@(a or b or op)
	begin
		casex(op)
			4'bx000: r = a + b;							//ADD
			4'bx100: r = a - b;							//SUB
			
			4'bx001: r = a & b;							//AND
			4'bx101: r = a | b;							//OR
			
			4'bx010: r = a ^ b;							//XOR
			4'bx110: r = {b[15:0], 16'h0};			//LUI
			
			4'b0011: r = b << a[4:0];					//SLL
			4'b0111: r = b >> a[4:0];					//SRL
			
			4'b1111: r = ($signed(b)) >>> a[4:0];	//SRA
			
			default: r = 32'hffffffff;					//ERROR
		endcase
	end
	
	assign z = ~|r;
	
endmodule 
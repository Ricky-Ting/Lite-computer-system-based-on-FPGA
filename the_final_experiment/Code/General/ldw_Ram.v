//废弃代码
module ldw_Ram
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data_a, data_b, data_c, data_d,
	input [(ADDR_WIDTH-1):0] addr_a, addr_b, addr_c, addr_d,
	input we_a, we_b, we_c, we_d, clk_a, clk_b, clk_c, clk_d,
	output reg [(DATA_WIDTH-1):0] q_a, q_b, q_c, q_d
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	always @ (posedge clk_a)
	begin
		// Port A 
		if (we_a) 
		begin
			ram[addr_a] <= data_a;
			q_a <= data_a;
		end
		else 
		begin
			q_a <= ram[addr_a];
		end 
	end

	always @ (posedge clk_b)
	begin
		// Port B 
		if (we_b) 
		begin
			ram[addr_b] <= data_b;
			q_b <= data_b;
		end
		else 
		begin
			q_b <= ram[addr_b];
		end 
	end
	/*
	always @ (posedge clk_c)
	begin
		// Port C 
		if (we_c) 
		begin
			ram[addr_c] <= data_c;
			q_c <= data_c;
		end
		else 
		begin
			q_c <= ram[addr_c];
		end 
	end
	
	always @ (posedge clk_d)
	begin
		// Port D 
		if (we_d) 
		begin
			ram[addr_d] <= data_d;
			q_d <= data_d;
		end
		else 
		begin
			q_d <= ram[addr_d];
		end 
	end
	*/
endmodule
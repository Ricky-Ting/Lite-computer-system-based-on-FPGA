module Keyboard(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// Seg7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	input VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,
	
	output [18:0] k_addr,
	output [31:0] keyboard_data,
	output k_change,
	input clear,
	output reg [18:0] pos
);
	
	//键盘部分
	wire [4:0] k_h;
	wire [6:0] k_v;
	wire [7:0] data;
	wire [7:0] ascll;
	wire [2:0] MODEL;
	wire ready;
	reg [7:0] s_data;
	reg [8:0] counter;//用于延缓改变
	
	assign LEDR[5:0] = pos[5:0];
	assign LEDR[8:6] = MODEL;
	assign LEDR[9] = k_change;
	assign k_change = counter[0];
	
	initial
	begin
		s_data = 12'd0;
		pos = 0;
		counter = 0;
	end
	
	//键盘实现
	keyboard Ke(CLOCK_50, PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, data, ascll, MODEL[2:0], ready);


	always@(posedge CLOCK_50)
	begin
		if(clear)
			pos <= 0;
		else if(counter)
		begin
			if(counter <= 3'b11111)
				counter <= counter + 1;
			else
				counter <= 0;
		end
		else if(ready)
		begin
			if(MODEL != 0)
				if(ascll != 0 && MODEL == 1)//读入标准字符
				begin
					pos <= pos + 4;
					s_data <= ascll;
					counter <= 1;
				end
				else if((MODEL == 3 || MODEL == 4) && ascll != 0)
				begin
					pos <= pos + 4;
					s_data <= ascll;
					counter <= 1;
				end
		end
	end
	
	assign keyboard_data = {24'b0, s_data};
	assign k_addr = 19'hf00;
	//assign k_addr = {7'h0, 5'h3, 5'h3, 2'b0};
	/*
	assign k_h = pos/70;
	assign k_v = pos%70;
	assign k_addr = {7'h0, k_h, k_v[6:2], 2'b0};
	*/
	/*
	always@(pos)
		case(pos[1:0])
			2'b11: keyboard_data[31:0]  = {24'b0, s_data};
			2'b10: keyboard_data[31:8]  = {16'b0, s_data};
			2'b01: keyboard_data[31:16] = {8'b0, s_data};
			2'b00: keyboard_data[31:24] = s_data;
		endcase
	*/
	/*
	always@(negedge VGA_CLK)
		k_change <= 0;
	*/
endmodule

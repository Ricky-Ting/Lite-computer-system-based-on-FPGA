//废弃模块
module IO_System(

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
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2
);
	
	//VGA部分
	wire [4:0] c_h;
	wire [6:0] c_v;
	wire [7:0] c_a;
	wire [255:0] f_a;
	wire [3:0] f_h;
	wire [3:0] f_v;
	wire point;
	
	wire [18:0] Addr;
	wire [18:0] addr;
	wire [11:0] color;
	
	reg [4:0] offset;
	
	//键盘部分
	wire [7:0] data;
	wire [7:0] ascll;
	reg [7:0] s_data;
	reg [11:0] pos;
	reg [11:0] w_pos;//等待一个clk_e
	wire [4:0] k_h;
	wire [6:0] k_v;
	wire [2:0] MODEL;
	wire clk_e;
	reg [4:0] ls_r_a;
	reg [4:0] ls_w_a;
	reg [7:0] ls_w_d;
	wire [7:0] ls_r_d;
	
	wire ready;
	
	reg rst_clk;
	wire cursor_clk;
	
	reg flush;
	reg [6:0] counter;
	
	wire [3:0] term;

	initial
	begin
		s_data = 12'd2070;
		pos = 0;
		w_pos = 0;
		offset = 30;
		rst_clk = 0;
		flush = 0;
		counter = 0;
	end
	
	assign LEDR[9:5] = offset;
	//assign LEDR[4:0] = k_h;
	assign LEDR[2:0] = MODEL;
	//VGA实现
	assign addr[18:9] = Addr[18:9]+10'h2;
	assign addr[8:0] = Addr[8:0]-9'h1;
	
	//assign c_h = (addr[8:4] + offset)%30;
	assign c_h = (addr[8:4] + offset)%30;
	Line L(addr[18:9], VGA_CLK, {term[0], c_v, f_v});
	Screen_table ({c_h, c_v}, {k_h, k_v}, VGA_CLK, CLOCK_50, ,s_data,1'b0,1'b1,c_a, );
	Font F(c_a, VGA_CLK, f_a);
	assign f_h = addr[3:0];
	assign point = f_a[{4'hf-f_h, f_v}];
	
	assign color = {12{point}};
	
	Screen Sc(SW, CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_VS, VGA_HS, Addr, color);
	
	//键盘实现
	Keyboard Ke(CLOCK_50, PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, data, ascll, MODEL[2:0], ready);

	//Line_statue (ls_r_a, ls_w_a, clk_e, CLOCK_50, , ls_w_d, 1'h0, 1'h1, ls_r_d, );
	Line_statue (k_h-5'h1, k_h, clk_e, CLOCK_50, , k_v, 1'h0, 1'h1, ls_r_d, );
	
	clkgen #(2) my_vgaclk1(CLOCK_50, rst_clk, 1'h1,clk_e);
	clkgen #(2) my_vgaclk2(CLOCK_50, 1'h0, 1'h1,cursor_clk);

	always@(posedge CLOCK_50)
	begin
		w_pos <= pos;
		rst_clk <= 0;
		///*
		if(flush)
		begin
			if(counter != 70)
			begin
				s_data <= 12'h0;
				w_pos <= pos+counter;
				counter <= counter+1;
			end
			else
			begin
				counter <= 0;
				flush <= 0;
				w_pos <= pos;
			end
		end
		//*/
		else if(ready)
		begin
			rst_clk <= 1;
			if(k_h == offset)
			begin
				flush <= 1;
				if(k_h == 30)
				begin
					w_pos <= 0;
					pos <= 0;
					offset <= 1;
				end
				else
				begin
					offset <= k_h+1;
				end
			end
			else
			begin
				if(MODEL != 0)
				begin
					if(ascll >= 8'h20 && ascll <= 8'h7e && MODEL == 1)//读入标准字符
					begin
						s_data <= ascll;
						pos <= pos+1;
						ls_r_a <= (k_h-5'h1)%30;
						ls_w_a <= k_h;
						ls_w_d <= k_v+7'h1;
					end
					else if((MODEL == 3 || MODEL == 4) && ascll != 0)
					begin
						s_data <= ascll;
						pos <= pos+1;
						ls_r_a <= (k_h-5'h1)%30;
						ls_w_a <= k_h;
						ls_w_d <= k_v+7'h1;
					end
					else if(data != 0 && MODEL == 1)//读入非标准字符
					begin
						if(data == 8'h66)//删除键
						begin
							if(k_v != 0)
							begin
								s_data <= 0;
								pos <= (pos-12'h1)%2100;
								ls_r_a <= (k_h-5'h1)%30;
								ls_w_a <= k_h;
								ls_w_d <= k_v-7'h1;
							end
							else
							begin
								/*
								s_data <= 0;
								pos <= ({7'h0,k_h-5'h1}*70+{4'h0,ls_r_d})%2100;
								ls_r_a <= (k_h-5'h2)%30;
								ls_w_a <= (k_h-5'h1)%30;
								*/
							end
						end
						else if(data == 8'h5a)//回车键
						begin
							s_data <= 0;
							//pos <= pos+12'd70-{5'h0, k_v};
							pos <= {7'h0,k_h+5'h1}*70;
							ls_r_a <= k_h;
							ls_w_a <= (k_h+5'h1)%30;
							ls_w_d <= 0;
						end
					end
				end
			end
		end
		else
		begin//光标
			if(cursor_clk)
				s_data <= 8'h0b;//8'h5f;
			else
				s_data <= 8'h0;
		end
	end
	
	assign k_h = w_pos/70;
	assign k_v = w_pos%70;

endmodule

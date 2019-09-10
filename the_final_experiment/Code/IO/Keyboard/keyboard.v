module keyboard(clk, ps2_clk, ps2_data, d1, d2, d3, d4, d5, d6, data1, ascll, model, ready);
	input clk;
	input ps2_clk;
	input ps2_data;
	
	//reg [7:0] before_data;
	output [6:0] d1;
	output [6:0] d2;
	output [6:0] d3;
	output [6:0] d4;
	output [6:0] d5;
	output [6:0] d6;
	
	reg clrn;
	reg nextdata_n;
	
	output reg [2:0] model;
	reg en;
	
	output reg [7:0] data1;
	reg [7:0] data2;
	wire [7:0] ascll1;
	wire [7:0] ascll2;
	output reg [7:0] ascll;
	
	//reg [7:0] counter;
	
	output wire ready;
	wire overflow;
	wire [7:0] k_data;
	
	wire [7:0] dd5;
	wire [7:0] dd6;
	
	//wire clk_2s;
	
	initial
	begin
		clrn = 1;
		nextdata_n = 0;
		ascll = 0;
		model = 0;
		en = 0;
		//counter = 0;
		
		data1 = 0;
		data2 = 0;
		ascll = 0;
	end
	
	ps2_keyboard KEYBOARD(clk,clrn,ps2_clk,ps2_data,k_data,ready,nextdata_n,overflow);
	keyboard_table K1(data1, clk, ascll1);
	keyboard_table K2(data2, clk, ascll2);
	//timer_2s T(clk, ~ready, clk_2s);
	
	//assign dd5 = counter % 10;
	//assign dd6 = counter / 10;
	
	digital_tube 
		D1(data1[3:0], en, d1),
		D2(data1[7:4], en, d2),
		D3(data2[3:0], en, d3),
		D4(data2[7:4], en, d4),
		D5(ascll[3:0], en, d5),
		D6(ascll[7:4], en, d6);
	
	always@(posedge clk)
	begin
		if(overflow)
		begin
			clrn <= 0;
			model <= 0;
			en <= 0;
		end
		else
			clrn <= 1;
			
		if(model == 1)
			ascll <= ascll1;

		if(ready)
		begin
			nextdata_n <= 1;
			case(model)
				0://起始模式
					begin
						if(k_data != 8'hf0)
						begin
							data1 <= k_data;
							en <= 1;
							model <= 1;
							//counter <= counter + 1;
						end
						else
							model <= 5;
					end
				1://单字模式
					begin
						data2 <= data1;
						data1 <= k_data;
						ascll <= ascll1;
						if(k_data == 8'hf0)
						begin
							model <= 2;
						end
						else if(data1 == 8'h12 || data1 == 8'h59)
						begin
							model <= 3;
						end
						else if(data1 == 8'h14)
						begin
							//if(ascll >= 8'h61 && ascll <= 8'h7a)
							model <= 4;
						end
					end
				2://退出模式
					if(k_data != 8'hf0)
					begin
						model <= 0;
						en <= 0;
						data1 <= 0;
						data2 <= 0;
						ascll <= 0;
					end
				3://shift判断模式
					begin
						if(k_data == 8'hf0)
						begin
							model <= 5;
						end
						else if(ascll1 >= 8'h61 && ascll1 <= 8'h7a)
						begin
							ascll <= ascll1 - 8'h20;
						end
					end
				4://control判断模式
					begin
						if(k_data == 8'hf0)
						begin
							model <= 5;
						end
						else if(ascll1 >= 8'h61 && ascll1 <= 8'h7a)
						begin
							ascll <= ascll1 - 8'h60;
						end
					end
				5:
					model <= 6;
				6:
					model <= 2;
			endcase
		end
		else
		begin
			nextdata_n <= 0;
		end
	end
	
endmodule 
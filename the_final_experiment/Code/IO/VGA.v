module VGA(

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
	inout 		          		PS2_DAT2,
	//////////// 自定义部分 //////////
	input [2:0] show_model,//显示模式选择
	input [2:0] background,//背景选择
	input [2:0] move_model,//运动模式选择
	input [2:0] font_model,//字体模式选择
	input [11:0] font_color,//字体颜色
	input [2:0] choose_icon,//用以知道选中了那个图标
	
	output [11:0] font_address,
	input [31:0] char
);
	
	//VGA部分
	wire [4:0] c_h;
	wire [6:0] c_v;
	reg [7:0] c_a;
	wire [255:0] f_a;
	wire [3:0] f_h;
	wire [3:0] f_v;
	wire point;
	reg [7:0] s_data;
	
	wire [18:0] direct_addr;
	wire [18:0] addr;
	reg [11:0] color;
	
	wire [3:0] term;
	//图标部分
	parameter icon_w = 64;
	parameter icon_h = 64;
	parameter icon_interval = 125;
	parameter icon_x_total = 100;
	parameter icon_y_total = 400;
	
	parameter icon_x0 = icon_x_total;
	parameter icon_y0 = icon_y_total;
	wire is_icon0;//判断是否为图标区域
	wire [11:0] iconc0;//图标1对应颜色
	wire [11:0] iconc0_;//图标1被选中时对应颜色
	
	parameter icon_x1 = icon_x_total+icon_interval;
	parameter icon_y1 = icon_y_total;
	wire is_icon1;//判断是否为图标区域
	wire [11:0] iconc1;//图标1对应颜色
	wire [11:0] iconc1_;//图标1被选中时对应颜色
	
	parameter icon_x2 = icon_x_total+icon_interval*2;
	parameter icon_y2 = icon_y_total;
	wire is_icon2;//判断是否为图标区域
	wire [11:0] iconc2;//图标2对应颜色
	wire [11:0] iconc2_;//图标2被选中时对应颜色
	
	parameter icon_x3 = icon_x_total+icon_interval*3;
	parameter icon_y3 = icon_y_total;
	wire is_icon3;//判断是否为图标区域
	wire [11:0] iconc3;//图标2对应颜色
	wire [11:0] iconc3_;//图标2被选中时对应颜色
	
	wire [11:0] b1_color;//图片1对应点颜色
	wire [11:0] b2_color;//图片2对应点颜色
	
	wire [18:0] Addr;
	reg [9:0] h_offset;
	reg [8:0] v_offset;
	reg lock;//用于锁死状态
	reg [9:0] move_counter;//用于运动间隔计时
	
	wire clk_e;
	reg [11:0] font_color_counter;
	
	assign {term[1],Addr[18:9]} = {1'b0,direct_addr[18:9]+10'h2}+{1'b0,h_offset}-11'd640;
	assign {term[2],Addr[8:0]} = {1'b0,direct_addr[8:0]-9'h1}+{1'b0,v_offset}-10'd480;
	
	initial
	begin
		s_data = 12'd2070;
		color = 0;
		
		h_offset = 10'd640;
		v_offset = 9'd320;
		lock = 0;
		move_counter = 0;
		
		c_a = 0;
		font_color_counter = 0;
	end
	
	//字模读取部分
	assign {term[1],addr[18:9]} = Addr[18:9]+10'h2;
	assign {term[2],addr[8:0]} = Addr[8:0]-9'h1;
	
	assign c_h = addr[8:4];
	Line L(addr[18:9], VGA_CLK, {term[0], c_v, f_v});
	//出入数据信号数据信号
	assign font_address = {c_h, c_v};
	
	always@(char)
		case(c_v[1:0])
			2'b11: c_a = char[7:0];
			2'b10: c_a = char[15:8];
			2'b01: c_a = char[23:16];
			2'b00: c_a = char[31:24];
		endcase
	//Screen_table ST({c_h, c_v}, {k_h, k_v}, VGA_CLK, CLOCK_50, ,s_data,1'b0,1'b1,c_a, );
	Font F(c_a, VGA_CLK, f_a);
	assign f_h = addr[3:0];
	assign point = f_a[{4'hf-f_h, f_v}];
	
	//背景存储部分 用212992存两张图，通过第18位（即17）来选择 0x‭34000‬
	//但以下还是打算先用两个rom来实现 所以大小是 深度81920
	Background1 BG1({Addr[18:10], Addr[8:1]}, VGA_CLK, b1_color);//用于从整图中提取点
	Background2 BG2({Addr[18:10], Addr[8:1]}, VGA_CLK, b2_color);
	
	//图标处理部分
	assign is_icon0 = (Addr[18:9] >= icon_x0) && (Addr[8:0] >= icon_y0)
						&& (Addr[18:9] <= icon_w+icon_x0) && (Addr[8:0] <= icon_h+icon_y0);
	Icon0 ICON0(({2'b0,Addr[18:9]}-icon_x0)*icon_w+({3'b0,Addr[8:0]}-icon_y0), VGA_CLK, iconc0);
	Icon0_ ICON0_(({2'b0,Addr[18:9]}-icon_x0)*icon_w+({3'b0,Addr[8:0]}-icon_y0), VGA_CLK, iconc0_);
	
	assign is_icon1 = (Addr[18:9] >= icon_x1) && (Addr[8:0] >= icon_y1)
						&& (Addr[18:9] <= icon_w+icon_x1) && (Addr[8:0] <= icon_h+icon_y1);
	Icon1 ICON1(({2'b0,Addr[18:9]}-icon_x1)*icon_w+({3'b0,Addr[8:0]}-icon_y1), VGA_CLK, iconc1);
	Icon1_ ICON1_(({2'b0,Addr[18:9]}-icon_x1)*icon_w+({3'b0,Addr[8:0]}-icon_y1), VGA_CLK, iconc1_);
	
	assign is_icon2 = (Addr[18:9] >= icon_x2) && (Addr[8:0] >= icon_y2)
						&& (Addr[18:9] <= icon_w+icon_x2) && (Addr[8:0] <= icon_h+icon_y2);
	Icon2 ICON2(({2'b0,Addr[18:9]}-icon_x2)*icon_w+({3'b0,Addr[8:0]}-icon_y2), VGA_CLK, iconc2);
	Icon2_ ICON2_(({2'b0,Addr[18:9]}-icon_x2)*icon_w+({3'b0,Addr[8:0]}-icon_y2), VGA_CLK, iconc2_);
	
	assign is_icon3 = (Addr[18:9] >= icon_x3) && (Addr[8:0] >= icon_y3)
						&& (Addr[18:9] <= icon_w+icon_x3) && (Addr[8:0] <= icon_h+icon_y3);
	Icon3 ICON3(({2'b0,Addr[18:9]}-icon_x3)*icon_w+({3'b0,Addr[8:0]}-icon_y3), VGA_CLK, iconc3);
	Icon3_ ICON3_(({2'b0,Addr[18:9]}-icon_x3)*icon_w+({3'b0,Addr[8:0]}-icon_y3), VGA_CLK, iconc3_);
	
	clkgen #(200) my_vgaclk1(CLOCK_50, 1'b0, 1'h1,clk_e);
	always@(posedge clk_e)
		font_color_counter <= font_color_counter + 1;
	
	//最终处理部分
	always@(Addr)
	begin
		if(~(addr[18:9] >= 0 && addr[18:9] < 640 && addr[8:0] >= 0 && addr[8:0] < 480))//运动过程中多余画面。可考虑放置图案
		begin
			color = 0;
		end
		else if(point)//字处理部分
		begin
			case(font_model)
				3'b000: color = font_color_counter + {2'b0,Addr[18:9]} + {3'b0, Addr[8:0]};
				3'b001: color = font_color;
				3'b010: color = font_color_counter;
				default: color = 0;
			endcase
			//color = font_color;
		end
		else//背景处理部分
		begin
			if(is_icon0 && ~show_model[0])
			begin
				if(choose_icon != 0)
					color = iconc0;
				else
					color = iconc0_;
			end
			else if(is_icon1 && ~show_model[0])
			begin
				if(choose_icon != 1)
					color = iconc1;
				else
					color = iconc1_;
			end
			else if(is_icon2 && ~show_model[0])
			begin
				if(choose_icon != 2)
					color = iconc2;
				else
					color = iconc2_;
			end
			else if(is_icon3 && ~show_model[0])
			begin
				if(choose_icon != 3)
					color = iconc3;
				else
					color = iconc3_;
			end
			else
				case(background)
					3'b000: color = b2_color;
					3'b001: color = b1_color;
					3'b010: color = {Addr[18:15],Addr[18:15],Addr[18:15]};//平行渐变
					3'b011: color = {Addr[8:5],Addr[8:5],Addr[8:5]};//垂直渐变
					3'b100: color = {{1'b0, Addr[18:16]}+{1'b0, Addr[8:6]},{1'b0, Addr[18:16]}+{1'b0, Addr[8:6]},{1'b0, Addr[18:16]}+{1'b0, Addr[8:6]}};//对角渐变
					3'b101: color = ~(font_color_counter + {2'b0,Addr[18:9]} + {3'b0, Addr[8:0]});
					default: color = 0;
				endcase
		end
	end
	
	//如果move_model不改变，那么在执行完一个状态的所有需要执行的动作后，就会停留在原状态
	//在执行完一个“动作模式”后，一定要到一个“静态模式”，然后才能到下一个“动作模式”，否则会无反应（这是由于lock的缘故）
	always@(move_model)
	begin
		case(move_model)//和图像移动相关
			3'b000://正常/默认状态
			begin
				h_offset = 10'd640;
				v_offset = 9'd480;
				lock = 0;
			end
			3'b001://左到中
			begin
				//if(~lock)
				if(h_offset == 10'd640)
				begin
					lock = 1;
					move_counter = 0;
					h_offset = 10'd0;
					v_offset = 9'd480;
				end
				
				if(direct_addr == {10'b1, 9'b1} && h_offset < 10'd640)
					move_counter = move_counter + 1;
				if(move_counter[2] == 1)
				begin
					move_counter = 0;
					h_offset = h_offset + 1;
				end
			end
			default://非法状态，故意显示错误
			begin
				h_offset = 10'd320;
				v_offset = 9'd240;
			end
		endcase
	end
	
	Screen Sc(1'b0, CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_VS, VGA_HS, direct_addr, color);
endmodule

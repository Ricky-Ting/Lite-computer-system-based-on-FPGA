module get_freq (
	input clk,
	input [7:0] data,
	output reg [15:0] freq,
	output reg reset_n
);
(* ram_init_file = "keyfreq.mif" *) reg [15:0] keytable [256:0];

reg [7:0] olddata;
reg [24:0] cnt;

initial 
	begin
		
	
		freq=16'h0000;
		olddata=8'h00;
		reset_n=1'b1;
		cnt=25'b0;
	end
	
always @(posedge clk) 
	begin
		if(data!=olddata)
			begin
				olddata<=data;
				cnt<=25'b0;
				reset_n<=1'b0;
				freq<=keytable[data];
			end
		else
			begin
				
				if(cnt==25'b1111111111111111111111111)
					begin
						freq<=16'b0;
						reset_n<=1'b0;
					end
				else
					begin
						reset_n<=1'b1;
						cnt<=cnt+1'b1;
					end
				
			end
	end



endmodule 
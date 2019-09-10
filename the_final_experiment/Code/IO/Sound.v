module Sound(


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

	//////////// Audio //////////
	input 		          		AUD_ADCDAT,
	inout 		          		AUD_ADCLRCK,
	inout 		          		AUD_BCLK,
	output		          		AUD_DACDAT,
	inout 		          		AUD_DACLRCK,
	output		          		AUD_XCK,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// I2C for Audio and Video-In //////////
	output		          		FPGA_I2C_SCLK,
	inout 		          		FPGA_I2C_SDAT,
	
	//////////// Keyboard //////////

	input ps2_clk,
	input ps2_data,
	
	input [7:0] ascll,
	input [3:0] volume
);



//=======================================================
//  REG/WIRE declarations
//=======================================================

//wire clk_i2c;
//wire reset;
/*
wire [15:0] audiodata0;
wire [15:0] audiodata1;
wire [15:0] audiodata2;
wire [15:0] audiodata3;
*/
//wire [15:0] audiodata;
//wire [15:0] audiodata1;
/*
wire [15:0] sound0;
wire [15:0] sound1;
wire [15:0] sound2;
wire [15:0] sound3;
*/
//wire [15:0] sound;
//wire [15:0] sound1;
//wire [15:0] volume_sound;

//reg [7:0] ascllt;
//reg [1:0] div1;
//reg sign; 

wire clk_i2c;
wire reset;
wire [15:0] audiodata;



wire [15:0] freq;
wire reset_n;


//=======================================================
//  Structural coding
//=======================================================


assign reset = ~KEY[0];

audio_clk u1(CLOCK_50, reset,AUD_XCK, LEDR[9]);


//I2C part
clkgen #(10000) my_i2c_clk(CLOCK_50,reset,1'b1,clk_i2c);  //10k I2C clock  

I2C_Audio_Config myconfig(clk_i2c, KEY[0],FPGA_I2C_SCLK,FPGA_I2C_SDAT,LEDR[2:0]);

I2S_Audio myaudio(AUD_XCK, KEY[0], AUD_BCLK, AUD_DACDAT, AUD_DACLRCK, audiodata);

Sin_Generator sin_wave(AUD_DACLRCK, reset_n, freq, audiodata);//


get_freq get1(CLOCK_50,ascll,freq,reset_n);
endmodule

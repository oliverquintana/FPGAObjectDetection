//---------------------------------------------------------------------------------
//UNIVERSIDAD POLITÉCNICA DE GUANAJUATO
//Captura y procesamiento de imágenes en FPGA
//Ingeniería Robótica
//Elaboró: Oliver Jonathan Quintana Quintana
//---------------------------------------------------------------------------------
module DE2_D5M
	(
		//Pulso de reloj 50 MHz 
		CLOCK_50,				
		//Push Buttons
		KEY,							
		//Switches
		SW,	
		//---------------------------------------------------------------------------------
		//SDRAM
		//---------------------------------------------------------------------------------
		DRAM_DQ,							//	SDRAM Data bus 16 Bits
		DRAM_ADDR,						//	SDRAM Address bus 12 Bits
		DRAM_LDQM,						//	SDRAM Low-byte Data Mask 
		DRAM_UDQM,						//	SDRAM High-byte Data Mask
		DRAM_WE_N,						//	SDRAM Write Enable
		DRAM_CAS_N,						//	SDRAM Column Address Strobe
		DRAM_RAS_N,						//	SDRAM Row Address Strobe
		DRAM_CS_N,						//	SDRAM Chip Select
		DRAM_BA_0,						//	SDRAM Bank Address 0
		DRAM_BA_1,						//	SDRAM Bank Address 0
		DRAM_CLK,						//	SDRAM Clock
		DRAM_CKE,						//	SDRAM Clock Enable
		//---------------------------------------------------------------------------------
		//VGA
		//---------------------------------------------------------------------------------
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,  							//	VGA Blue[9:0]
		//---------------------------------------------------------------------------------
		//GPIO
		GPIO_1							
	);

//---------------------------------------------------------------------------------
//I/O
//---------------------------------------------------------------------------------
input					CLOCK_50;				//	50 MHz
input		[3:0]		KEY;						//	Pushbuttons[3:0]
input		[17:0]	SW;						//	Switches[17:0]
inout		[15:0]	DRAM_DQ;					//	SDRAM Data bus 16 Bits
output	[11:0]	DRAM_ADDR;				//	SDRAM Address bus 12 Bits
output				DRAM_LDQM;				//	SDRAM Low-byte Data Mask 
output				DRAM_UDQM;				//	SDRAM High-byte Data Mask
output				DRAM_WE_N;				//	SDRAM Write Enable
output				DRAM_CAS_N;				//	SDRAM Column Address Strobe
output				DRAM_RAS_N;				//	SDRAM Row Address Strobe
output				DRAM_CS_N;				//	SDRAM Chip Select
output				DRAM_BA_0;				//	SDRAM Bank Address 0
output				DRAM_BA_1;				//	SDRAM Bank Address 0
output				DRAM_CLK;				//	SDRAM Clock
output				DRAM_CKE;				//	SDRAM Clock Enable
output				VGA_CLK;   				//	VGA Clock
output				VGA_HS;					//	VGA H_SYNC
output				VGA_VS;					//	VGA V_SYNC
output				VGA_BLANK;				//	VGA BLANK
output				VGA_SYNC;				//	VGA SYNC
output	[9:0]		VGA_R;   				//	VGA Red[9:0]
output	[9:0]		VGA_G;	 				//	VGA Green[9:0]
output	[9:0]		VGA_B;   				//	VGA Blue[9:0]
inout		[35:0]	GPIO_1;					//	GPIO Connection 1
//---------------------------------------------------------------------------------
//Señales y Registros
//---------------------------------------------------------------------------------
wire		[11:0]	CCD_DATA;
wire					CCD_SDAT;
wire					CCD_SCLK;
wire					CCD_FLASH;
wire					CCD_FVAL;
wire					CCD_LVAL;
wire					CCD_PIXCLK;
wire					CCD_MCLK;				
wire		[15:0]	Read_DATA1;
wire		[15:0]	Read_DATA2;
wire					VGA_CTRL_CLK;
wire		[11:0]	mCCD_DATA;
wire					mCCD_DVAL;
wire					mCCD_DVAL_d;
wire		[15:0]	X_Cont;
wire		[15:0]	Y_Cont;
wire					DLY_RST_0;
wire					DLY_RST_1;
wire					DLY_RST_2;
wire					Read;
reg		[11:0]	rCCD_DATA;
reg					rCCD_LVAL;
reg					rCCD_FVAL;
wire		[11:0]	sCCD_R;
wire		[11:0]	sCCD_G;
wire		[11:0]	sCCD_B;
wire					sCCD_DVAL;
wire		[9:0]		VGA_R;   				
wire		[9:0]		VGA_G;	 				
wire		[9:0]		VGA_B;   			
reg		[1:0]		rClk;
wire					sdram_ctrl_clk;
wire 	 	[9:0]	 	gRed;
wire 	 	[9:0]		gBlue;
wire 	 	[9:0]	 	gGreen;
//---------------------------------------------------------------------------------
//Asignación entradas/salidas 
//---------------------------------------------------------------------------------
assign	CCD_DATA[0]	=	GPIO_1[13];
assign	CCD_DATA[1]	=	GPIO_1[12];
assign	CCD_DATA[2]	=	GPIO_1[11];
assign	CCD_DATA[3]	=	GPIO_1[10];
assign	CCD_DATA[4]	=	GPIO_1[9];
assign	CCD_DATA[5]	=	GPIO_1[8];
assign	CCD_DATA[6]	=	GPIO_1[7];
assign	CCD_DATA[7]	=	GPIO_1[6];
assign	CCD_DATA[8]	=	GPIO_1[5];
assign	CCD_DATA[9]	=	GPIO_1[4];
assign	CCD_DATA[10]=	GPIO_1[3];
assign	CCD_DATA[11]=	GPIO_1[1];
assign	GPIO_1[16]	=	CCD_MCLK;
assign	CCD_FVAL		=	GPIO_1[22];
assign	CCD_LVAL		=	GPIO_1[21];
assign	GPIO_1[19]	=	1'b1;  
assign	GPIO_1[17]	=	DLY_RST_1;
assign	VGA_CTRL_CLK=	rClk[0];
assign	VGA_CLK		=  ~rClk[0];
assign	CCD_MCLK 	= rClk[0];
assign 	CCD_PIXCLK 	= rClk[0];

always@(posedge CCD_PIXCLK)
begin
	rCCD_DATA	<=	CCD_DATA;
	rCCD_LVAL	<=	CCD_LVAL;
	rCCD_FVAL	<=	CCD_FVAL;
end

//---------------------------------------------------------------------------------
//Reloj de control para cámara y VGA
always@(posedge CLOCK_50)
begin
	rClk	<=	rClk+1;
end
//---------------------------------------------------------------------------------
//---------------------------Programación Estructural------------------------------
//---------------------------------------------------------------------------------

//---------------------------------------------------------------------------------
//Controlador VGA
//---------------------------------------------------------------------------------
VGA_Control			u1	(	
							.reset_n		(DLY_RST_2),
							.h_sync		(VGA_HS),
							.v_sync		(VGA_VS),
							.disp_ena	(Read),
							.n_blank		(VGA_BLANK),
							.n_sync		(VGA_SYNC),
							.pixel_clk	(VGA_CTRL_CLK),
							.iR			(gRed),	
							.iG			(gGreen),
							.iB			(gBlue),	
							.R				(VGA_R),
							.G				(VGA_G),
							.B				(VGA_B)
							);
//---------------------------------------------------------------------------------
//Procesado de la imagen
//---------------------------------------------------------------------------------
Image_Processing		u5(
							.sel		  ({SW[17],SW[16]}),
							.chansel   ({SW[15],SW[14]}),
							.iCLK	     (CLOCK_50),
							.iCLK25	  (rClk[0]),
							.iRST	     (DLY_RST_2),
							.iR		  (Read_DATA2[9:0]),
							.iG   	  ({Read_DATA1[14:10],Read_DATA2[14:10]}),
							.iB   	  (Read_DATA1[9:0]),
							.R			  (gRed),
							.G		  	  (gGreen),
							.B	  		  (gBlue)
							);
//---------------------------------------------------------------------------------
//Control de Reset para estructuras
//---------------------------------------------------------------------------------
Reset_Delay			u2	(	
							.iCLK		(CLOCK_50),
							.iRST		(KEY[0]),
							.oRST_0	(DLY_RST_0),
							.oRST_1	(DLY_RST_1),
							.oRST_2	(DLY_RST_2)
						);
//---------------------------------------------------------------------------------
//Captura de la imagen de la cámara
//---------------------------------------------------------------------------------
CCD_Capture			u3	(	
							.oDATA		(mCCD_DATA),
							.oDVAL		(mCCD_DVAL),
							.oX_Cont		(X_Cont),
							.oY_Cont		(Y_Cont),
							.iDATA		(rCCD_DATA),
							.iFVAL		(rCCD_FVAL),
							.iLVAL		(rCCD_LVAL),
							.iSTART		(SW[0]),
							.iEND			(!SW[0]),
							.iCLK			(CCD_PIXCLK),
							.iRST			(DLY_RST_2)
						);
//---------------------------------------------------------------------------------
//Conversión de la imagen capturada RAW a pixeles RGB
//---------------------------------------------------------------------------------
RAW2RGB				u4	(	
							.iCLK		(CCD_PIXCLK),
							.iRST		(DLY_RST_1),
							.iDATA	(mCCD_DATA),
							.iDVAL	(mCCD_DVAL),
							.oRed		(sCCD_R),
							.oGreen	(sCCD_G),
							.oBlue	(sCCD_B),
							.oDVAL	(sCCD_DVAL),
							.iX_Cont	(X_Cont),
							.iY_Cont	(Y_Cont)
						);
//---------------------------------------------------------------------------------
//PLL para el controlador de la SDRAM
//---------------------------------------------------------------------------------
sdram_pll 			u6	(
							.inclk0	(CLOCK_50),
							.c0		(sdram_ctrl_clk),
							.c1		(DRAM_CLK)
						);
//---------------------------------------------------------------------------------
//Controlador SDRAM
//---------------------------------------------------------------------------------
Sdram_Control_4Port	u7	(						
						   .REF_CLK(CLOCK_50),
						   .RESET_N(1'b1),
							.CLK(sdram_ctrl_clk),
							//	FIFO Write Side 1
							.WR1_DATA({1'b0,sCCD_G[11:7],sCCD_B[11:2]}),
							.WR1(sCCD_DVAL),
							.WR1_ADDR(0),
							.WR1_MAX_ADDR(640*480),
							.WR1_LENGTH(9'h100),
							.WR1_LOAD(!DLY_RST_0),
							.WR1_CLK(~CCD_PIXCLK),
							//	FIFO Write Side 2
							.WR2_DATA(	{1'b0,sCCD_G[6:2],sCCD_R[11:2]}),
							.WR2(sCCD_DVAL),
							.WR2_ADDR(22'h100000),
							.WR2_MAX_ADDR(22'h100000+640*480),
							.WR2_LENGTH(9'h100),
							.WR2_LOAD(!DLY_RST_0),
							.WR2_CLK(~CCD_PIXCLK),
							//	FIFO Read Side 1
						    .RD1_DATA(Read_DATA1),
				        	.RD1(Read),
				        	.RD1_ADDR(0),
							.RD1_MAX_ADDR(640*480),
							.RD1_LENGTH(9'h100),
							.RD1_LOAD(!DLY_RST_0),
							.RD1_CLK(~VGA_CTRL_CLK),
							//	FIFO Read Side 2
						    .RD2_DATA(Read_DATA2),
							.RD2(Read),
							.RD2_ADDR(22'h100000),
							.RD2_MAX_ADDR(22'h100000+640*480),
							.RD2_LENGTH(9'h100),
				        	.RD2_LOAD(!DLY_RST_0),
							.RD2_CLK(~VGA_CTRL_CLK),
							//	SDRAM Side
						    .SA(DRAM_ADDR),
						    .BA({DRAM_BA_1,DRAM_BA_0}),
        					.CS_N(DRAM_CS_N),
        					.CKE(DRAM_CKE),
        					.RAS_N(DRAM_RAS_N),
        					.CAS_N(DRAM_CAS_N),
        					.WE_N(DRAM_WE_N),
        					.DQ(DRAM_DQ),
        					.DQM({DRAM_UDQM,DRAM_LDQM})
						);
//---------------------------------------------------------------------------------
//Controlador I2C
//---------------------------------------------------------------------------------
I2C_CCD_Config 		u8	(
							.iCLK					(CLOCK_50),
							.iRST_N				(DLY_RST_2),
							.iZOOM_MODE_SW		(SW[3]),
							.iEXPOSURE_ADJ		(SW[2]),
							.iEXPOSURE_DEC_p	(SW[1]),
							.I2C_SCLK			(GPIO_1[24]),
							.I2C_SDAT			(GPIO_1[23])
						);
//---------------------------------------------------------------------------------
endmodule
//---------------------------------------------------------------------------------
//Conversión imagen RAW a RGB
//---------------------------------------------------------------------------------
module RAW2RGB(	oRed,
				oGreen,		//Salida Canal Verde
				oBlue,		//Salida Canal Azul
				oDVAL,		//Enable salida
				iX_Cont,		//Coordenada X del dato
				iY_Cont,		//Coordenada Y del dato
				iDATA,		//Dato de entrada RAW
				iDVAL,		//Enable entrada
				iCLK,			//Reloj de entrada
				iRST			//Reset
				);
//---------------------------------------------------------------------------------
//I/O
//---------------------------------------------------------------------------------
input		[10:0]	iX_Cont;
input		[10:0]	iY_Cont;
input		[11:0]	iDATA;
input					iDVAL;
input					iCLK;
input					iRST;
output	[11:0]	oRed;
output	[11:0]	oGreen;
output	[11:0]	oBlue;
output				oDVAL;
//---------------------------------------------------------------------------------
//Señales y Registros
//---------------------------------------------------------------------------------
wire		[11:0]	mDATA_0;
wire		[11:0]	mDATA_1;
reg		[11:0]	mDATAd_0;
reg		[11:0]	mDATAd_1;
reg		[11:0]	mCCD_R;
reg		[12:0]	mCCD_G;
reg		[11:0]	mCCD_B;
reg					mDVAL;
//---------------------------------------------------------------------------------
assign	oRed		=	mCCD_R[11:0];
assign	oGreen	=	mCCD_G[12:1];
assign	oBlue		=	mCCD_B[11:0];
assign	oDVAL		=	mDVAL;
//---------------------------------------------------------------------------------
//Buffer que almacena una fila en RAM
//---------------------------------------------------------------------------------
Line_Buffer 	u0	(	.clken(iDVAL),
						.clock(iCLK),
						.shiftin(iDATA),
						.taps0x(mDATA_1),
						.taps1x(mDATA_0)	);
//---------------------------------------------------------------------------------
//Algoritmo de conversión
//---------------------------------------------------------------------------------
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		mCCD_R	<=	0;
		mCCD_G	<=	0;
		mCCD_B	<=	0;
		mDATAd_0<=	0;
		mDATAd_1<=	0;
		mDVAL	<=	0;
	end
	else
	begin
		mDATAd_0	<=	mDATA_0;
		mDATAd_1	<=	mDATA_1;
		mDVAL		<=	{iY_Cont[0]|iX_Cont[0]}	?	1'b0	:	iDVAL;
		if({iY_Cont[0],iX_Cont[0]}==2'b10)
		begin
			mCCD_R	<=	mDATA_0;
			mCCD_G	<=	mDATAd_0+mDATA_1;
			mCCD_B	<=	mDATAd_1;
		end	
		else if({iY_Cont[0],iX_Cont[0]}==2'b11)
		begin
			mCCD_R	<=	mDATAd_0;
			mCCD_G	<=	mDATA_0+mDATAd_1;
			mCCD_B	<=	mDATA_1;
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b00)
		begin
			mCCD_R	<=	mDATA_1;
			mCCD_G	<=	mDATA_0+mDATAd_1;
			mCCD_B	<=	mDATAd_0;
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b01)
		begin
			mCCD_R	<=	mDATAd_1;
			mCCD_G	<=	mDATAd_0+mDATA_1;
			mCCD_B	<=	mDATA_0;
		end
	end
end
//---------------------------------------------------------------------------------
endmodule
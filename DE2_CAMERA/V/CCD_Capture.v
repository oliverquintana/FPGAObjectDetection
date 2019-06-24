//---------------------------------------------------------------------------------
//Estructura para la obtención RAW de la imagen que indexa la información para su
//posterior conversión a RGB. Habilita/deshabilita la recepción de datos de la 
//cámara, seleccionado por el control del interruptor físico de la tarjeta.
//---------------------------------------------------------------------------------
module CCD_Capture(	oDATA,
					oDVAL,
					oX_Cont,
					oY_Cont,
					oFrame_Cont,
					iDATA,
					iFVAL,
					iLVAL,
					iSTART,
					iEND,
					iCLK,
					iRST
					);
//---------------------------------------------------------------------------------
//I/O
//---------------------------------------------------------------------------------
input		[11:0]	iDATA;
input				iFVAL;
input				iLVAL;
input				iSTART;
input				iEND;
input				iCLK;
input				iRST;
output	[11:0]	oDATA;
output	[15:0]	oX_Cont;
output	[15:0]	oY_Cont;
output	[31:0]	oFrame_Cont;
output				oDVAL;
//---------------------------------------------------------------------------------
//Registros
//---------------------------------------------------------------------------------
reg					Pre_FVAL;
reg					mCCD_FVAL;
reg					mCCD_LVAL;
reg		[11:0]	mCCD_DATA;
reg		[15:0]	X_Cont;
reg		[15:0]	Y_Cont;
reg		[31:0]	Frame_Cont;
reg					mSTART;
//---------------------------------------------------------------------------------
//Constantes
//---------------------------------------------------------------------------------
parameter COLUMN_WIDTH = 1280;
//---------------------------------------------------------------------------------
assign	oX_Cont		=	X_Cont;
assign	oY_Cont		=	Y_Cont;
assign	oFrame_Cont	=	Frame_Cont;
assign	oDATA		=	mCCD_DATA;
assign	oDVAL		=	mCCD_FVAL&mCCD_LVAL;
//---------------------------------------------------------------------------------
//Control inicio/paro
//---------------------------------------------------------------------------------
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	mSTART	<=	0;
	else
	begin
		if(iSTART)
		mSTART	<=	1;
		if(iEND)
		mSTART	<=	0;		
	end
end
//---------------------------------------------------------------------------------
//Indexado de datos RAW
//---------------------------------------------------------------------------------
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		Pre_FVAL	<=	0;
		mCCD_FVAL	<=	0;
		mCCD_LVAL	<=	0;
		X_Cont		<=	0;
		Y_Cont		<=	0;
	end
	else
	begin
		Pre_FVAL	<=	iFVAL;
		if( ({Pre_FVAL,iFVAL}==2'b01) && mSTART )
		mCCD_FVAL	<=	1;
		else if({Pre_FVAL,iFVAL}==2'b10)
		mCCD_FVAL	<=	0;
		mCCD_LVAL	<=	iLVAL;
		if(mCCD_FVAL)
		begin
			if(mCCD_LVAL)
			begin
				if(X_Cont<(COLUMN_WIDTH-1))
				X_Cont	<=	X_Cont+1;
				else
				begin
					X_Cont	<=	0;
					Y_Cont	<=	Y_Cont+1;
				end
			end
		end
		else
		begin
			X_Cont	<=	0;
			Y_Cont	<=	0;
		end
	end
end
//---------------------------------------------------------------------------------
//Contador de fotogramas
//---------------------------------------------------------------------------------
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	Frame_Cont	<=	0;
	else
	begin
		if( ({Pre_FVAL,iFVAL}==2'b01) && mSTART )
		Frame_Cont	<=	Frame_Cont+1;
	end
end
//---------------------------------------------------------------------------------
//Transferencia de datos de entrada a registro
//---------------------------------------------------------------------------------
reg	ifval_dealy;
wire ifval_fedge;	
reg	[15:0]	y_cnt_d;

always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
		mCCD_DATA	<=	0;
	else if (iLVAL)
		mCCD_DATA	<=	iDATA;
	else
		mCCD_DATA	<=	0;	
end			

always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
		y_cnt_d	<=	0;
	else
		y_cnt_d	<=	Y_Cont;	
end


always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
		ifval_dealy	<=	0;
	else
		ifval_dealy	<=	iFVAL;	
end

assign ifval_fedge = ({ifval_dealy,iFVAL}==2'b10)?1:0;  
//---------------------------------------------------------------------------------
endmodule
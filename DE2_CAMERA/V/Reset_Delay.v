//---------------------------------------------------------------------------------
//Control de reset para diferentes estructuras.
//---------------------------------------------------------------------------------
module		Reset_Delay(
	iCLK,		//Reloj de entrada
	iRST,		//Control de reset
	oRST_0,	//Salida Reset 1
	oRST_1,  //Salida Reset 2
	oRST_2   //Salida Reset 3
);
//---------------------------------------------------------------------------------
//I/O, Registros
//---------------------------------------------------------------------------------
input			iCLK;
input			iRST;
output reg	oRST_0;
output reg	oRST_1;
output reg	oRST_2;
reg	[31:0]	Cont;
//---------------------------------------------------------------------------------
always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		Cont	<=	0;
		oRST_0	<=	0;
		oRST_1	<=	0;
		oRST_2	<=	0;
	end
	else
	begin
		if(Cont!=32'h11FFFFF)
		Cont	<=	Cont+1;
		if(Cont>=32'h1FFFFF)
		oRST_0	<=	1;
		if(Cont>=32'h2FFFFF)
		oRST_1	<=	1;
		if(Cont>=32'h11FFFFF)
		oRST_2	<=	1;
	end
end
//---------------------------------------------------------------------------------
endmodule
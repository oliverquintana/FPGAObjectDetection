-----------------------------------------------------------------------------------
--Estructura principal para el procesado de la imagen.
-----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Image_Processing is
	port(
		iCLK 		:  in std_logic;								-- Clock de 50 MHz
		iCLK25	:  in std_logic;								-- Clock de 25 MHz
		iRST		:  in std_logic;								-- Señal de reset
		sel		:  in std_logic_vector(1 downto 0);		-- Switches de selección de filtro
		chansel  :  in std_logic_vector(1 downto 0);		-- Switches de selección de canal para procesado
		iR			:  in std_logic_vector(9 downto 0);		-- Canal de entrada rojo
		iG			:  in std_logic_vector(9 downto 0);		-- Canal de entrada verde
		iB			:  in std_logic_vector(9 downto 0);		-- Canal de entrada azul
		R			: out std_logic_vector(9 downto 0);		-- Canal de salida rojo
		G			: out std_logic_vector(9 downto 0);		-- Canal de salida verde
		B			: out std_logic_vector(9 downto 0)		-- Canal de salida azul
		);
end Image_Processing;

architecture arch of Image_Processing is

	signal oGray : std_logic_vector(9 downto 0) := (OTHERS => '0'); 	-- Señal de salida de pixel en escala de grises
	signal oBin  : std_logic_vector(9 downto 0) := (OTHERS => '0'); 	-- Señal de salida de pixel binarizado
	signal iBin  : std_logic_vector(9 downto 0) := (OTHERS => '0');	-- Señal de entrada del canal a binarizar
	signal edge  : std_logic;										 				-- Indicador de borde de objeto en imagen

begin
	-----------------------------------------------------------------------------------
	--Selector de canal para procesado
	-----------------------------------------------------------------------------------
	iBin <= iR when chansel = "01" else
			  iG when chansel = "10" else
			  iB when chansel = "11" else oGray;
	-----------------------------------------------------------------------------------
	--Componente para el procesado del pixel de entrada RGB a escala de grises
	-----------------------------------------------------------------------------------
	u1 : entity work.GrayScale
					port map(
						iCLK		=> iCLK25,
						iRST		=> iRST,
						iRed		=> iR,
						iGreen	=> iG,
						iBlue		=> iB,
						oChannel	=> oGray
						);
	-----------------------------------------------------------------------------------
	--Componente para el binarizado del pixel de entrada a partir del canal elegido 
	--previamente en el selector
	-----------------------------------------------------------------------------------
	u2 : entity work.Binarize
					port map(
						iCLK 		=> iCLK25,
						iRST 		=> iRST,
						iChannel => iBin,
						oChannel => oBin,
						edge     => edge
						);
	-----------------------------------------------------------------------------------
	-- Selector de filtro para la imagen a desplegar en pantalla mediante VGA
	-----------------------------------------------------------------------------------
	process(iCLK25,iRST,sel,edge)
	begin
		if(iRST = '0') then
			R <= (OTHERS => '0');
			G <= (OTHERS => '0');
			B <= (OTHERS => '0');
		elsif(iCLK25'event AND iCLK25 = '1') then
			if(sel = "10") then 					
				if(edge = '1') then				-- Cuando los selectores se encuentran en "10" 
					R <= (OTHERS => '0');		-- se despliega en pantalla la imagen en RGB y
					G <= (OTHERS => '1');		-- el borde del objeto en color verde a partir del
					B <= (OTHERS => '0');		-- pixel binarizado
				else
					R <= iR;
					G <= iG;
					B <= iB;
				end if;
			elsif(sel = "01") then					
				R <= iBin;							-- Cuando los selectores se encuentran en "01" 
				G <= iBin;							-- se despliega en pantalla la imagen del canal
				B <= iBin;							-- seleccionado
			elsif(sel = "11") then
				R <= oBin;							-- Cuando los selectores se encuentran en "11"
				G <= oBin;							-- se despliega en pantalla la imagen binarizada
				B <= oBin;							-- del canal seleccionado
			else
				R <= iR;								-- Cuando los selectores se encuentran en "00"
				G <= iG;								-- se despliega en pantalla la imagen en RGB sin 
				B <= iB;								-- aplicar ningún filtro
			end if;
		end if;
	end process;
	-----------------------------------------------------------------------------------
end arch;
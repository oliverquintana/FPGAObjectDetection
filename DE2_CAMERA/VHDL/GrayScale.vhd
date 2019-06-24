-----------------------------------------------------------------------------------
-- Para el filtro en escala de grises "Luminosity", el cual 
-- consiste en multiplicar cada canal por una constante dada
-- que le asigna cierto porcentaje al mismo.
-----------------------------------------------------------------------------------
-- Librería para operaciones de punto flotante.
-----------------------------------------------------------------------------------
library ieee_proposed;
use ieee_proposed.fixed_pkg.all;
use ieee_proposed.numeric_std_unsigned.all;
use ieee_proposed.env.all;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.float_pkg.all;
use ieee_proposed.math_utility_pkg.all;
use ieee_proposed.numeric_std_additions.all;
use ieee_proposed.standard_additions.all;
use ieee_proposed.std_logic_1164_additions.all;
-----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GrayScale is
	port(
		iCLK		:  in std_logic;													-- Pulso de reloj de entrada
		iRST		:  in std_logic;													-- Señal de reset
		iRed		:  in std_logic_vector(9 downto 0);							-- Canal de entrada rojo
		iGreen		:  in std_logic_vector(9 downto 0);						-- Canal de entrada verde
		iBlue		:  in std_logic_vector(9 downto 0);							-- Canal de entrada azul
		oChannel	: out std_logic_vector(9 downto 0) := (OTHERS => '0')	-- Pixel de salida en escala de grises
	);
end GrayScale;

architecture arch of GrayScale is

	signal nRed,nBlue,nGreen : ufixed(9 downto -6) := (OTHERS => '0') ;
	constant xR  : ufixed( 0 downto - 6) := "0010011";						-- Constante 0.296875 para el canal rojo
	constant xG  : ufixed( 0 downto - 6) := "0100101";						-- Constante 0.578125 para el canal verde
	constant xB  : ufixed( 0 downto - 6) := "0000001";						-- Constante 0.015625 para el canal azul
	signal   sum : ufixed(12 downto -12) := (OTHERS => '0');				-- Pixel resultante
	signal	 Red,Green,Blue : integer := 0;									-- Señales del pixel convertido de 10 bits a entero

begin
	-----------------------------------------------------------------------------------
	--Conversiones de canales de vector a entero
	-----------------------------------------------------------------------------------
	Red    <= to_integer(iRed);					
	Green  <= to_integer(iGreen);					 
	Blue   <= to_integer(iBlue);					
	-----------------------------------------------------------------------------------
	-- Conversión de entero a punto flotante (10 bits para entero, 6 bits después del punto)
	-----------------------------------------------------------------------------------
	process(iCLK,iRST)
	begin
		if(iRST = '0') then
		elsif(iCLK'event AND iCLK = '1') then
			nRed	 <= to_ufixed(Red  ,9,-6);		
			nGreen <= to_ufixed(Green,9,-6);		
			nBlue  <= to_ufixed(Blue ,9,-6); 	
		end if;
	end process;
	-----------------------------------------------------------------------------------
	-- Multiplicación del canal por la constate correspondiente al algoritmo a aplicar 
	-----------------------------------------------------------------------------------
	process(iCLK,iRST)
	begin
		if(iRST = '0') then
		elsif(iCLK'event AND iCLK = '1') then
			sum <= nRed*xR + nGreen*xG + nBlue*xB;	
		end if;
	end process;
	-----------------------------------------------------------------------------------
	-- Conversión de punto flotante a vector de 10 bits
	-----------------------------------------------------------------------------------
	process(iCLK,iRST)
	begin
		if(iRST = '0') then
			oChannel <= (OTHERS => '0');				  
		elsif(iCLK'event AND iCLK = '1') then			 
			oChannel <= to_slv(sum(9 downto 0));	
		end if;
	end process;
	-----------------------------------------------------------------------------------
end arch;
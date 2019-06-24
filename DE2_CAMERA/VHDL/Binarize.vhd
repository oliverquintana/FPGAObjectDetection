-----------------------------------------------------------------------------------
--Estructura para el binarizado y detección de bordes de objetos.
-----------------------------------------------------------------------------------
library ieee;
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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Binarize is
	port(
		iCLK		:  in std_logic;							-- Pulso de reloj de entrada
		iRST		:  in std_logic;							-- Señal de reset
		iChannel	:  in std_logic_vector(9 downto 0);	-- Canal de entrada
		oChannel	: out std_logic_vector(9 downto 0); -- Canal de salida
		edge   	: out std_logic							-- Detección de borde
	);
end Binarize;

architecture arch of Binarize is	

	signal pixel  : integer := 0;
	signal shift  : std_logic_vector(1 downto 0) := "00";
	signal output : std_logic_vector(9 downto 0) := (OTHERS => '0');

begin
	-----------------------------------------------------------------------------------
	-- Binarizado del pixel de entrada
	-----------------------------------------------------------------------------------
	pixel 	<= to_integer(iChannel);					-- Conversión del pixel de 10 bits a entero
	oChannel <= output;										-- Salida del pixel binarizado

	process(iCLK,iRST)
		constant Vmin : integer := 255;					-- Intensidad mínima del pixel a binarizar
		constant Vmax : integer := 500;					-- Intensidad máxima del pixel a binarizar
	begin
		if(iRST = '0') then
			output <= (OTHERS => '0');
		elsif(iCLK'event AND iCLK = '1') then
			if(pixel > Vmin AND pixel < Vmax) then 	-- Binarizado a partir del umbral seleccionado
				output <= (OTHERS => '1');
			else
				output <= (OTHERS => '0');
			end if;
		end if;
	end process;
	-----------------------------------------------------------------------------------
	-- Detección de borde
	-----------------------------------------------------------------------------------
	process(iCLK,iRST)
	begin
		if(iRST = '0') then
			shift    <= "00";
		elsif(iCLK'event AND iCLK = '1') then
			shift(1) <= shift (0);						-- Registro de desplazamiento que almacena el valor de dos pixeles
			shift(0) <= output(0);						-- para determinar si es borde de objeto (cuando shift es "10" o "01")
			if(shift = "10" OR shift = "01") then
				edge <= '1';
			else
				edge <= '0';
			end if;
		end if;
	end process;
	-----------------------------------------------------------------------------------
end arch;
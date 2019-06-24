-----------------------------------------------------------------------------------
--Controlador VGA
-----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity VGA_Control IS
	generic(
		-----------------------------------------------------------------------------------
		--Constantes para la salida VGA de 640x480 a 60 Hz
		-----------------------------------------------------------------------------------
		h_pulse 		:	integer 		:= 96;  				-- Pulso de sincronización horizontal en pixeles
		h_bp	 		:	integer 		:= 48;				-- Pixeles del back porch horizontal en pixeles
		h_pixels		:	integer 		:= 640;				-- Tamaño horizontal de imagen en pixeles
		h_fp	 		:	integer		:= 16;				-- Pixeles del front porch horizontal
		h_pol			:	std_logic 	:= '0';				-- Polaridad del pulso de sincronización horizontal(1 = positivo, 0 = negativo)
		v_pulse 		:	integer 		:= 2;					-- Pulso de sincronización vertical en filas
		v_bp	 		:	integer 		:= 33;				-- Pixeles del back porch vertical en filas
		v_pixels		:	integer 		:= 480;				-- Tamaño vertical de imagen en filas
		v_fp	 		:	integer 		:= 10;				-- Filas del front porch vertical
		v_pol			:	std_logic	:= '0'				-- Polaridad del pulso de sincronización vertical (1 = positive, 0 = negative)
		);
		-----------------------------------------------------------------------------------
	port(
		reset_n			:	 in std_logic;							-- Señal de reset
		h_sync			:	out std_logic 	 := '0';				-- Pulso de sincronización horizontal
		v_sync			:	out std_logic 	 := '0';				-- Pulso de sincronización vertical
		disp_ena		:	out std_logic 		 := '0';				-- Area visible ('1' = display time, '0' = blanking time)
		column			:	out integer 	 := 0;				-- Coordenada de pixel horizontal
		row				:	out integer  	 := 0;				-- Coordenada de pixel vertical
		n_blank			:	out std_logic 	 := '0';				-- Salida blanking al DAC
		n_sync			:	out std_logic 	 := '0';			 	-- Salida "sync-on-green" al DAC
		pixel_clk		:   in std_logic 	 := '0';				-- Pulso de reloj de entrada (25 MHz)
		iR				:   in std_logic_vector(9 downto 0);	-- Canal de entrada rojo
		iG				:   in std_logic_vector(9 downto 0);	-- Canal de entrada verde
		iB				:   in std_logic_vector(9 downto 0);	-- Canal de entrada azul
		R				:  out std_logic_vector(9 downto 0);	-- Canal de salida rojo
		G				:  out std_logic_vector(9 downto 0);	-- Canal de salida verde
		B				:  out std_logic_vector(9 downto 0)		-- Canal de salida azul
		);
		
end VGA_Control;

architecture behavior of VGA_Control is
	constant h_period		: integer := h_pulse + h_bp + h_pixels + h_fp;  -- Número total de pixeles en una fila
	constant v_period		: integer := v_pulse + v_bp + v_pixels + v_fp;  -- Número total de filas en una columna
	signal	t_h_sync  	: std_logic := '0';										-- Señal de sincronismo horizontal
	signal   t_v_sync		: std_logic := '0';										-- Señal de sincronismo vertical
	signal   t_column		: integer;													-- Señal de coordenada horizontal
	signal   t_row			: integer;													-- Señal de coordenada vertical
	signal   t_disp_ena 	: std_logic;												-- Señal de área visible
	
begin
	-----------------------------------------------------------------------------------
	-- Asignación de señales temporales a salidas
	-----------------------------------------------------------------------------------
	h_sync 	 <= t_h_sync;
	v_sync 	 <= t_v_sync;
	n_blank   <= '1';   
	n_sync 	 <= '0';   
	row		 <= t_row;
	column    <= t_column;
	disp_ena  <= t_disp_ena;
	-----------------------------------------------------------------------------------
	--Controlador VGA
	-----------------------------------------------------------------------------------
	process(pixel_clk, reset_n)
		variable h_count : integer RANGE 0 TO h_period - 1 := 0;  -- Contador columnas
		variable v_count : integer RANGE 0 TO v_period - 1 := 0;  -- Contador filas
	begin
		if(reset_n = '0') then		
			h_count 		:= 0;		
			v_count 		:= 0;			
			t_h_sync 	<= NOT h_pol;	
			t_v_sync 	<= NOT v_pol;	
			t_disp_ena 	<= '0';		
			t_column 	<= 0;				
			t_row 		<= 0;					
		elsif(pixel_clk'EVENT AND pixel_clk = '1') then
			-- Contadores
			if(h_count < h_period - 1) then		
				h_count := h_count + 1;
			else
				h_count := 0;
				if(v_count < v_period - 1) then	
					v_count := v_count + 1;
				else
					v_count := 0;
				end if;
			end if;
			-- Señal de sincronismo horizontal
			if(h_count < h_pixels + h_fp OR h_count >= h_pixels + h_fp + h_pulse) then
				t_h_sync <= NOT h_pol;	
			else
				t_h_sync <= h_pol;			
			end if;
			-- Señal de sincronismo vertical
			if(v_count < v_pixels + v_fp OR v_count >= v_pixels + v_fp + v_pulse) then
				t_v_sync <= NOT v_pol;		
			else
				t_v_sync <= v_pol;			
			end if;
			-- Asignar coordenadas del pixel
			if(h_count < h_pixels) then  	
				t_column <= h_count;		
			end if;
			if(v_count < v_pixels) then	
				t_row <= v_count;				
			end if;
			-- área de imagen visible
			if(h_count < h_pixels AND v_count < v_pixels) then  	
				t_disp_ena <= '1';											 	
			else																
				t_disp_ena <= '0';											
			end if;
		end if;
	end process;
	-----------------------------------------------------------------------------------
	-- Asignación del pixel de entrada a la salida cuando área visible = 1, de lo 
	-- contrario a todos los canales se les asigna 0
	-----------------------------------------------------------------------------------
	process(reset_n,pixel_clk,iR,iG,iB)
	begin 
		if(reset_n = '0') then
			R <= (OTHERS => '0');
			G <= (OTHERS => '0');
			B <= (OTHERS => '0');
		elsif(pixel_clk'event AND pixel_clk = '1') then
			if (t_disp_ena = '1') then
				R <= iR;
				G <= iG;
				B <= iB;
			else
				R <= (OTHERS => '0');
				G <= (OTHERS => '0');
				B <= (OTHERS => '0');
			end if;
		end if;
	end process;

end behavior;
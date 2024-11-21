LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;  -- Necessário para usar unsigned, signed, e to_integer

ENTITY Elevador IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		andar : IN STD_LOGIC_VECTOR (3 downto 0); -- entrada
		movimento : OUT STD_LOGIC_VECTOR (2 downto 0);
		sinal_andar_atual : OUT STD_LOGIC_VECTOR (3 downto 0)-- saída
	);
END Elevador;

ARCHITECTURE arch OF Elevador IS
	TYPE estados IS (parado, subindo, descendo);
	SIGNAL estado : estados;
	FUNCTION display7seg (num: integer) return std_logic_vector is
	begin
		case num is
			when 0 => return "1000000";
			when 1 => return "1111001";
			when 2 => return "0100100";
			when 3 => return "0110000";
			when 4 => return "0011001";
			when 5 => return "0010010";
			when 6 => return "0000010";
			when 7 => return "1111000";
			when 8 => return "0000000";
			when 9 => return "0010000";
			when others => return "1111111"; --Apagado
		end case;
	end function;
	
BEGIN
	-- Processo de Controle de estados da máquina de Moore
	PROCESS(clk, reset, andar)
	VARIABLE andar_desejado : integer;  -- Variável interna para armazenar o andar desejado
	VARIABLE andar_atual : integer;  -- Variável interna para armazenar o andar atual
	VARIABLE unidade : integer;
	VARIABLE dezena : integer;
	BEGIN
		-- Converte STD_LOGIC_VECTOR para integer
      andar_desejado := to_integer(unsigned(andar));
		IF reset = '1' THEN
			estado <= parado;
			andar_atual := 0;
		ELSIF rising_edge(clk) THEN -- Verifica borda de subida do clock
		-- Máquina de estados usando CASE
		--Lógica combinacional que decide qual será o próximo estado
			CASE estado IS
				WHEN parado =>
					IF andar_desejado - andar_atual < 0 THEN estado<=descendo; --Descer
						andar_atual := andar_atual - 1;
					ELSIF andar_desejado - andar_atual > 0 THEN estado<=subindo; --Subir
						andar_atual := andar_atual + 1;
					END IF;
				WHEN subindo =>
					IF andar_desejado - andar_atual = 0 THEN estado<=parado; --Parar
					ELSE andar_atual := andar_atual + 1;
					END IF;
				WHEN descendo =>
					IF andar_desejado - andar_atual = 0 THEN estado<=parado; --Parar
					ELSE andar_atual := andar_atual - 1;
					END IF;
			END CASE;
		END IF;
		
		sinal_andar_atual <= std_logic_vector(to_signed(andar_atual, 4));
			
END PROCESS;

WITH estado SELECT movimento <=
	"100" WHEN parado,
	"010" WHEN subindo,
	"001" WHEN descendo;
END arch;

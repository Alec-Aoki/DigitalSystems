library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MaqRef is
	port (CLK, MRESET: in std_logic;
			libRef : in std_logic;
			valorInserido : in std_logic_vector (3 downto 0);
			estAtual : out std_logic_vector (2 downto 0);
			valorAtualSinal : out std_logic_vector (6 downto 0)
			);
end MaqRef;

architecture arq of MaqRef is

	type est is (recDin, devDin, devRef);
	signal estado : est;
			
	function sinalToCent (valorIns: std_logic_vector) return integer is
	begin
		case valorIns is
			when "0001" => return 10;
			when "0010" => return 25;
			when "0100" => return 50;
			when "1000" => return 100;
			when others => return 0;
		end case;
	end function;

begin
	process (CLK, MRESET, valorInserido, libRef)
	variable unidade: integer; 
	variable dezena: integer;
	variable centena: integer;
	variable valorAtual: integer;
	
	begin
		if MRESET = '1' then
			valorAtual := 0;
			estado <= recDin;
		elsif libRef = '1' then
			case estado is
				when recDin =>
					if valorAtual = 100 then
						valorAtual := 0;
						estado <= devRef;
					else
						valorAtual := 0;
						estado <= devDin;
					end if;
				when devDin =>
					valorAtual := 0;
					estado <= devDin;
				when devRef =>
					valorAtual := 0;
					estado <= devRef;
			end case;
		elsif rising_edge(CLK) then
			valorAtual := valorAtual + sinalToCent(valorInserido);
			case estado is
				when recDin =>
					if valorAtual = 100 then
						estado <= recDin;
					elsif valorAtual > 100 then
						valorAtual := 0;
						estado <= devDin;
					elsif valorAtual < 100 then
						estado <= recDin;
					end if;
				when devDin =>
					valorAtual := 0;
					estado <= recDin;
				when devRef =>
					valorAtual := 0;
					estado <= recDin;
			end case;
		end if;
		
		valorAtualSinal <= std_logic_vector(to_signed(valorAtual, 7));

end process;

with estado select estAtual <=
	"001" when recDin,
	"010" when devDin,
	"100" when devRef;
end arq;
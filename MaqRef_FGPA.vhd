library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MaqRef is
	port (clkFPGA, CLK, MRESET, rstDB: in std_logic;
			libRef : in std_logic;
			valorInserido : in std_logic_vector (3 downto 0);
			estAtual : out std_logic_vector (2 downto 0);
			valorUnidade : out std_logic_vector (6 downto 0);
			valorDezena : out std_logic_vector (6 downto 0);
			valorCentena : out std_logic_vector (6 downto 0)
			);
end MaqRef;

architecture arq of MaqRef is
	component debouncer
	port (
		clk_fpga, rst_debouncer, input_key : in std_logic;
		out_key : out std_logic);
	end component;

	type est is (recDin, devDin, devRef);
	signal estado : est;
	signal out_clk_db, out_mrst_db : std_logic;
	
	function display (num: integer) return std_logic_vector is
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
			when 9 => return "0011000";
			when others => return "1000000";
		end case;
	end function;
			
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
	D1: debouncer port map(clk_fpga => clkFPGA, rst_debouncer => rstDB, input_key => CLK, out_key => out_clk_db);
	D2: debouncer port map(clk_fpga => clkFPGA, rst_debouncer => rstDB, input_key => MRESET, out_key => out_mrst_db);

	process (out_clk_db, out_mrst_db, valorInserido, libRef)
	variable unidade: integer; 
	variable dezena: integer;
	variable centena: integer;
	variable valorAtual: integer;
	
	begin
		if out_mrst_db = '1' then
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
		elsif rising_edge(out_clk_db) then
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
		
		unidade := valorAtual mod 10;
		dezena := valorAtual / 10;
		centena := valorAtual / 100;
		
		valorUnidade <= display(unidade);
		valorDezena <= display(dezena);
		valorCentena <= display(centena);
end process;

with estado select estAtual <=
	"001" when recDin,
	"010" when devDin,
	"100" when devRef;
end arq;
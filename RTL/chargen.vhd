library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity charactergenerator is
	port (
		clk : in std_logic;
		reset : in std_logic;
		xpos : in unsigned(9 downto 0);
		ypos : in unsigned(9 downto 0);
		pixel_clock : in std_logic;
		pixel : out std_logic
	);
end entity;

architecture rtl of charactergenerator is
--signal charaddr : unsigned(9 downto 0);
signal romaddr : std_logic_vector(9 downto 0);
signal messageaddr : unsigned(11 downto 0);
signal rowaddr : unsigned(11 downto 0);
signal messagechar : std_logic_vector(7 downto 0);
signal chardata : std_logic_vector(7 downto 0);
signal chardatashift : std_logic_vector(7 downto 0);
signal ycounter : unsigned(2 downto 0);
signal upd : std_logic;

begin

	mycharrom : entity work.CharRom
		port map (
			clock => clk,
			address => std_logic_vector(romaddr),
			q => chardata
	  );

  	mymessagerom : entity work.CharRAM
	port map (
		clock_a => clk,
		clock_b => clk,
		address_a => std_logic_vector(rowaddr),
		address_b => X"000",
		data_a => X"00",
		data_b => X"00",
		q_a => messagechar,
		q_b => open
  );

	process(clk, reset)
	begin
	
		if reset='0' then
			pixel<='0';
--			charaddr<=X"00" & "00";
			messageaddr<=X"000";
			romaddr<=X"00" & "00";
			chardatashift<=X"00";
			upd<='0';
			ycounter <="000";
		elsif rising_edge(clk) then
			romaddr<=messagechar(6 downto 0) & std_logic_vector(ycounter);

			if upd='1' then	-- Draw new pixel
				pixel<=chardata(7);
				chardatashift<=chardata(6 downto 0) & "0";
				upd<='0';
			else
				pixel<=chardatashift(7);
			end if;

			if pixel_clock='1' then
				if xpos=0 and ypos=481 then -- new frame
					messageaddr<=X"000";
					rowaddr<=X"000";
					upd<='1';
					ycounter<="000";
				elsif ypos<480 then
					if xpos=641 then -- new line
						ycounter<=ycounter+1;
						rowaddr<=messageaddr;
						if ycounter="110" then
							messageaddr<=messageaddr+80;
						end if;
						upd<='1';
					elsif xpos<640 then -- new pixel
						chardatashift<=chardatashift(6 downto 0) & '0';
						if xpos(2 downto 0)="000" then
							rowaddr<=rowaddr+1;
							pixel<=chardata(7);
							chardatashift<=chardata(6 downto 0) & "0";
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
end architecture;

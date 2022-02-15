library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity lab is
    Port ( clk,rst, rx : in  STD_LOGIC;    -- rst är tryckknappen i mitten under displayen
           seg: out  UNSIGNED(7 downto 0);
           an : out  UNSIGNED (3 downto 0));
end lab;

architecture Behavioral of lab is

  component leddriver
    Port ( clk,rst : in  STD_LOGIC;
           seg : out  UNSIGNED(7 downto 0);
           an : out  UNSIGNED (3 downto 0);
           value : in  UNSIGNED (15 downto 0));
  end component;

    signal sreg : UNSIGNED(9 downto 0) := B"0_00000000_0";  -- 10 bit skiftregister
    signal tal : UNSIGNED(15 downto 0) := X"0000";  
    signal rx1,rx2 : std_logic;         -- vippor på insignalen
    signal sp : std_logic;              -- skiftpuls
    signal lp : std_logic;              -- laddpuls
    signal pos : UNSIGNED(1 downto 0) := "00";

begin


  -- *****************************
  -- *  synkroniseringsvippor    *
  -- *****************************
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        rx1 = '0';
        rx2 = '0';
      else then
        rx1 <= rx;
        rx2 <= rx1;
      end if;
    end if;
  end process;
  -- *****************************
  -- *       styrenhet           *
  -- *****************************
   
  -- *****************************
  -- * 10 bit skiftregister      *
  -- *****************************
  process(clk) begin                
    if rising_edge(clk) then
      if rst = '1' then
        sreg <= 0;
      elsif sp = '1' then
        sreg <= rx2 & sreg(9 downto 1);
      end if;
    end if;
  end process;
  -- *****************************
  -- * 2 bit räknare             *
  -- *****************************
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        pos <= 0;
      elsif lp = '1' then
        if pos = 3 then
          pos <= 0;
        else then
          pos <= pos + 1;
        end if;
      end if;
    end if;
  end process;
  
  -- *****************************
  -- * 16 bit register           *
  -- *****************************
  
  
  -- *****************************
  -- * Multiplexad display       *
  -- *****************************
  -- Inkoppling av komponenten leddriver
  led: leddriver port map (clk, rst, seg, an, tal);

end Behavioral;


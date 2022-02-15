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

    signal cc : UNSIGNED(9 downto 0) := "0000000000"; -- clock counter
    signal spc : UNSIGNED(3 downto 0) := "0000";      -- shift pulse counter
    signal ce : std_logic;                          -- count enable

begin

  -- *****************************
  -- *  synkroniseringsvippor    *
  -- *****************************
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        rx1 <= '0';
        rx2 <= '0';
      else
        rx1 <= rx;
        rx2 <= rx1;
      end if;
    end if;
  end process;
  -- *****************************
  -- *       styrenhet           *
  -- *****************************
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        ce <= '0';
      elsif rx1 = '0' and rx2 ='1' then
        ce <= '1';
      end if;
    end if;
  end process;

  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' or ce = '0' then
        sp <= '0';
        lp <= '0';
        cc <= "0000000000";
        ce <= '0';
      elsif ce = '1' then 
        if cc = 867 then
          cc <= "0000000000";
          sp <= '0';
        elsif cc = 433 then
          if spc = 9 then
            spc <= "0000";
            lp <= '1';
            ce <= '0';
          else 
            sp <= '1';
            spc <= spc + 1;
          end if;

          cc <= cc + 1;
        else 
          cc <= cc + 1;
          sp <= '0';
        end if;

      elsif rx1 = '0' and rx2 ='1' then
          ce <= '1';
      end if;
    end if;
  end process;

  -- *****************************
  -- * 10 bit skiftregister      *
  -- *****************************
  process(clk) begin                
    if rising_edge(clk) then
      if rst = '1' then
        sreg <= B"0_00000000_0";
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
        pos <= "00";
      elsif lp = '1' then
        if pos = 3 then
          pos <= "00";
        else
          pos <= pos + 1;
        end if;
      end if;
    end if;
  end process;
  
  -- *****************************
  -- * 16 bit register           *
  -- *****************************
  process(clk) begin
    if rising_edge(clk) then
      if rst = '1' then
        tal <= X"0000";
      elsif lp = '1' then 
        if pos = 0 then
          tal(15 downto 12) <= sreg(4 downto 1);
        elsif pos = 1 then
          tal(11 downto 8) <= sreg(4 downto 1);
        elsif pos = 2 then
          tal(7 downto 4) <= sreg(4 downto 1);
        else
          tal(3 downto 0) <= sreg(4 downto 1);
        end if;
      end if;
    end if;
  end process;
        
  -- *****************************
  -- * Multiplexad display       *
  -- *****************************
  -- Inkoppling av komponenten leddriver
  led: leddriver port map (clk, rst, seg, an, tal);

end Behavioral;


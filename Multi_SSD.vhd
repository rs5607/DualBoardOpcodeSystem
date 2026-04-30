library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Multi_SSD is
    Port (
        clk: in STD_LOGIC;
        display: in STD_LOGIC_VECTOR(2 downto 0);
        result: in STD_LOGIC_VECTOR(15 downto 0);
        an: out STD_LOGIC_VECTOR(3 downto 0);
        seg: out STD_LOGIC_VECTOR(6 downto 0)
     );
end Multi_SSD;

architecture Behavioral of Multi_SSD is
    component SSD is
        port(
            SSD_enable: in STD_LOGIC;
            num: in STD_LOGIC_VECTOR(3 downto 0);
            sel: in STD_LOGIC_VECTOR(1 downto 0);
            an: out STD_LOGIC_VECTOR(3 downto 0);
            seg: out STD_LOGIC_VECTOR(6 downto 0)
         );
    end component;
        signal count1: integer range 0 to 99999:= 0; --counter and clock for MUX anode selector
        signal count2: integer range 0 to 199998:= 0;
        signal clk1: STD_LOGIC:= '0';
        signal clk2: STD_LOGIC:= '0';
        signal sel: STD_LOGIC_VECTOR(1 downto 0); --anode selection
        signal number: STD_LOGIC_VECTOR(3 downto 0):= (others => '0'); --number to be put on corresponding segment
        signal en: STD_LOGIC:= '0'; --SSD enable
        signal count_flash: integer range 0 to 16666666:= 0; --seperate counter and "clock" for flash operation
        signal flash: STD_LOGIC:= '0';
begin
    process(clk) begin
        if rising_edge(clk) then --counter and clock sequences
            if count1 = 99999 then
                count1 <= 0;
                clk1 <= not clk1;
            else
                count1 <= count1 + 1; 
            end if;
            if count2 = 199998 then
                count2 <= 0;
                clk2 <= not clk2;
            else
                count2 <= count2 + 1;
            end if;
            if count_flash = 16666666 then
                count_flash <= 0;
                flash <= not flash;              
            else
                count_flash <= count_flash + 1;
            end if; 
            
            if display(2) = '1' and display(0) = '1' then --number selector for easter egg, displays "2026"
                case sel is
                    when "00" =>
                        number <= "0110";
                    when "01" =>
                        number <= "0010";
                    when "10" =>
                        number <= "0000";
                    when "11" =>
                        number <= "0010";
                    when others =>
                        number <= "0000";    
                end case;
            elsif display(2) = '1' and display(0) = '0' then --flash number assignment, switches beteen 'f' and '0'
                if flash = '1' then
                    number <= "1111";
                else
                    number <= "0000";
                end if;      
            else           --normal operation, number is assigned to corresponding bits of calculation result
                case sel is
                    when "00" =>
                        number <= result(3 downto 0);
                    when "01" =>
                        number <= result(7 downto 4);
                    when "10" =>
                        number <= result(11 downto 8);
                    when "11" =>
                        number <= result(15 downto 12);
                    when others => 
                        number <= "0000";    
                end case;  
            end if;                                         
        end if;     
                 
    end process;

    sel <= clk1 & clk2; --MUX for anode selection
    en <= display(1) or display(2); --SSD enable, easter egg or SSD display selected
    
    SEG1: SSD 
        port map(
            SSD_enable => en,
            num => number, 
            sel => sel, 
            an => an, 
            seg => seg
        );           
    
end Behavioral;

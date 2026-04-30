library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display is
    Port (
    clk: in STD_LOGIC;
    opcode: in STD_LOGIC_VECTOR(7 downto 0); --opcode from Zed
    result: in STD_LOGIC_VECTOR(15 downto 0); --calculation result
    led: out STD_LOGIC_VECTOR(15 downto 0):= (others => '0');
    seg: out STD_LOGIC_VECTOR(6 downto 0):= (others => '1');
    an: out STD_LOGIC_VECTOR(3 downto 0):= (others => '1')
     );
end display;

architecture Behavioral of display is
    component Multi_SSD is
        port(
            clk: in STD_LOGIC;
            display: in STD_LOGIC_VECTOR(2 downto 0);
            result: in STD_LOGIC_VECTOR(15 downto 0);
            an: out STD_LOGIC_VECTOR(3 downto 0);
            seg: out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;  
    
    component LED_dis is
        port(
            clk: in STD_LOGIC;
            display: in STD_LOGIC_VECTOR(2 downto 0);
            result: in STD_LOGIC_VECTOR(15 downto 0);
            led: out STD_LOGIC_VECTOR(15 downto 0):= (others => '0')
        );
    end component;
                          
    signal display_mode: STD_LOGIC_VECTOR(2 downto 0):= (others => '0');
begin
    process(opcode) begin
        if opcode(7 downto 4) = "1110" then --special functions
            display_mode <= "100";
        elsif opcode(7 downto 4) = "1111" then
            display_mode <= "111";
        else            
            case opcode(1 downto 0) is --normal operation
                when "00" =>
                    display_mode <= "000"; --hide
                when "01" =>
                    display_mode <= "001"; --LEDs
                when "10" =>
                    display_mode <= "010"; --SSD
                when "11" =>    
                    display_mode <= "011"; --both
                when others =>
                    display_mode <= "000";    
            end case;
        end if;
    end process;       
    SSD_inst: Multi_SSD 
        port map(
            clk => clk,
            display => display_mode,
            result => result,
            an => an,
            seg => seg
        );
    LED_inst: LED_dis
        port map(
            clk => clk,
            display => display_mode,
            result => result,
            led => led
        );    
                
end Behavioral;



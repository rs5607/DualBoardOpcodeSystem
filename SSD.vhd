library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SSD is
  Port (
      SSD_enable: in STD_LOGIC;
      num: in STD_LOGIC_VECTOR(3 downto 0);
      sel: in STD_LOGIC_VECTOR(1 downto 0);
      an: out STD_LOGIC_VECTOR(3 downto 0);
      seg: out STD_LOGIC_VECTOR(6 downto 0)
   );
end SSD;

architecture Behavioral of SSD is
begin
    process(num) begin --simple case statements for hex to SSD
        case num is
            when "0000" => seg <= "1000000";
            when "0001" => seg <= "1111001";
            when "0010" => seg <= "0100100";
            when "0011" => seg <= "0110000";
            when "0100" => seg <= "0011001";
            when "0101" => seg <= "0010010";
            when "0110" => seg <= "0000010";
            when "0111" => seg <= "1111000";
            when "1000" => seg <= "0000000";
            when "1001" => seg <= "0010000";
            when "1010" => seg <= "0001000";
            when "1011" => seg <= "0000011";
            when "1100" => seg <= "1000110";
            when "1101" => seg <= "0100001";
            when "1110" => seg <= "0000110";
            when "1111" => seg <= "0001110";
            when others => seg <= "1111111";
            end case;
    end process;
    
    process(sel(1 downto 0), SSD_enable)
        begin
        if SSD_enable = '0' then --turn off SSD if not enabled
            an <= "1111";
        else    
            case sel is --select anode if SSD is enabled
                when "00" => an <= "1110";
                when "01" => an <= "1101";
                when "10" => an <= "1011";
                when "11" => an <= "0111";
                when others => an <= "1111";
            end case;
        end if;   
    end process;        
end Behavioral;



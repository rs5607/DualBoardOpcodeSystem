library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LED_dis is
    Port (
        clk: in STD_LOGIC;
        display: in STD_LOGIC_VECTOR(2 downto 0);
        result: in STD_LOGIC_VECTOR(15 downto 0);
        led: out STD_LOGIC_VECTOR(15 downto 0):= (others => '0')
     );
end LED_dis;
architecture Behavioral of LED_dis is
    signal count: integer range 0 to 16666667:= 0; --count for sequence easter egg
    signal sequence: integer range 0  to 15:= 0; -- sequence counter for easter egg
    signal led_int: STD_LOGIC_VECTOR(15 downto 0):= (others => '0'); --internal LED signal
    signal reset: STD_LOGIC:= '0';
begin
    led <= led_int;
    process(clk) begin
        if rising_edge(clk) then
            if display(2) = '0' and display(0) = '1' then --normal operation
                led_int <= result;
                reset <= '0';
            elsif display(2) = '1' and display(0) = '0' then --special operation: flash
                if reset <= '0' then --reset LEDs to 0
                    led_int <= (others => '0');
                    reset <= '1';
                end if;    
                if count = 16666666 then --flash counter
                    count <= 0;
                    led_int <= not led_int;    
                else
                    count <= count + 1;
                end if;
            elsif display(2) = '1' and display(0) = '1' then --special operation: sequence
                if reset = '0' then
                    led_int <= (others => '0');
                    reset <= '1';
                else    
                    if count = 16666666 then --sequence counter
                        count <= 0;
                        sequence <= sequence + 1;
                        case sequence is
                            when 0 =>
                                led_int(15) <= '0';
                                led_int(0) <= '1';
                            when 1 =>
                                led_int(0) <= '0';
                                led_int(1) <= '1';
                            when 2 =>
                                led_int(1) <= '0';
                                led_int(2) <= '1';
                            when 3 =>
                                led_int(2) <= '0';
                                led_int(3) <= '1';
                            when 4 =>
                                led_int(3) <= '0';
                                led_int(4) <= '1';
                            when 5 =>
                                led_int(4) <= '0';
                                led_int(5) <= '1';
                            when 6 =>
                                led_int(5) <= '0';
                                led_int(6) <= '1';
                            when 7 =>
                                led_int(6) <= '0';
                                led_int(7) <= '1';
                            when 8 =>
                                led_int(7) <= '0';
                                led_int(8) <= '1';
                            when 9 =>
                                led_int(8) <= '0';
                                led_int(9) <= '1';
                            when 10 =>
                                led_int(9) <= '0';
                                led_int(10) <= '1';
                            when 11 =>
                                led_int(10) <= '0';
                                led_int(11) <= '1';
                            when 12 =>
                                led_int(11) <= '0';
                                led_int(12) <= '1';
                            when 13 =>
                                led_int(12) <= '0';
                                led_int(13) <= '1';
                            when 14 =>
                                led_int(13) <= '0';
                                led_int(14) <= '1';
                            when 15 =>
                                led_int(14) <= '0';
                                led_int(15) <= '1';
                                reset <= '0';
                                sequence <= 0;
                        end case;
                    else
                        count <= count + 1;
                    end if;
                end if;    
            else    
                led_int <= (others => '0');
                sequence <= 0;
                count <= 0;
            end if;
        end if; 
    end process;        
end Behavioral;

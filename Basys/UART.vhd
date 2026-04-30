library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_recieve is
    Port (
        clk, RX, SCLK: in STD_LOGIC;
        opcode: out STD_LOGIC_VECTOR(7 downto 0):= (others => '0');
        done_uart: out STD_LOGIC:= '0'
     );
end UART_recieve;

architecture Behavioral of UART_recieve is
    constant BAUD_DIV: integer:= 868; --baud divisor for 115200bps
    constant HALF_BAUD: integer:= 434; --half baud divisor so that the sample is in the middle of the tick
    
    signal count: integer range 0 to 8:= 0;
    signal baud_count: integer range 0 to 869:= 0;
    signal busy: STD_LOGIC:= '0'; --assert busy status
    signal sample: STD_LOGIC:= '0'; --unlock sampling when in the middle
begin
    process(clk) begin
        if rising_edge(clk) then
            if SCLK = '1' then --reset done UART when spi is recieving so that the opcode buffer switches to spi
                done_uart <= '0';  
            end if;      
            if busy = '0' and RX = '0' then --start uart recieving when woken up by low pulse
                count <= 0;
                busy <= '1';
                baud_count <= 0;
                sample <= '0';
                done_uart <= '0';
            elsif busy = '1' then
                if sample = '0' then
                    if baud_count < HALF_BAUD - 1 then --get to middle of pulse to start sampling
                        baud_count <= baud_count + 1;    
                    else
                        baud_count <= 0;
                        sample <= '1';
                    end if;
                else
                    if baud_count < BAUD_DIV - 1 then
                        baud_count <= baud_count + 1;
                    else
                        if count = 8 then
                            busy <= '0';
                            done_uart <= '1';
                        else
                            baud_count <= 0;
                            opcode(count) <= RX; --LSB first
                            count <= count + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;    
    end process;                                    
end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_send is 
    Port (
        clk, start_uart: in STD_LOGIC;
        data: in STD_LOGIC_VECTOR(11 downto 0);
        TX: out STD_LOGIC:= '1';
        busy_uart: out STD_LOGIC:= '0'
    );
end UART_send;

architecture Behavioral of UART_send is
    constant BAUD_DIV: integer:= 868; --update this to 868 for baud 115200
    signal count: integer range 0 to 12:= 0;
    signal baud_count: integer range 0 to 869:= 0;
    signal busy: STD_LOGIC:= '0';
begin
    busy_uart <= busy;
    process(clk) begin
        if rising_edge(clk) then
            if busy = '0' and start_uart = '1' then 
                TX <= '0'; --pulse low to wake Zed
                busy <= '1'; --assert busy
                count <= 0;
                baud_count <= 0;
            elsif busy = '1' then
                if baud_count < BAUD_DIV - 1 then
                    baud_count <= baud_count + 1;
                else
                    if count = 12 then --last transmission, TX stays high, unassert busy
                        TX <= '1';
                        busy <= '0';
                    else
                        baud_count <= 0;
                        TX <= data(count); --LSB first
                        count <= count + 1;            
                    end if;
                end if;
            end if;    
        end if;
    end process;    
end Behavioral;

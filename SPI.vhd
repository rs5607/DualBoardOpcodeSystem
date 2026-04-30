library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_recieve is
    Port ( 
        clk, SCLK, MOSI, SS, done_uart: in STD_LOGIC;
        opcode: out STD_LOGIC_VECTOR(7 downto 0);
        done_spi: out STD_LOGIC:= '0'
    );
end SPI_recieve;
architecture Behavioral of SPI_recieve is
    signal busy: STD_LOGIC:= '0';
    signal count: integer range 0 to 8:= 0;
    signal SCLK_prev: STD_LOGIC:= '0';
begin
    process(clk) begin
        if rising_edge(clk) then --if UART recieves a packet, switch spi to 0 so that opcode gets UART opcode
            if done_uart = '1' then
                done_spi <= '0';
            end if;    
            SCLK_prev <= SCLK;
            if SCLK = '1' and SCLK_prev = '0' then --detect rising edge of SCLK
                if busy = '0' and SS = '0' then
                    count <= 0;
                    busy <= '1';
                    done_spi <= '0';
                elsif busy = '1' then
                    if SS = '1' then --master unasserts early
                        done_spi <= '1';
                        busy <= '0';
                    elsif count = 7 then
                        busy <= '0';
                        done_spi <= '1';
                        opcode(0) <= MOSI;
                    else
                        opcode(7 - count) <= MOSI; --MSB first
                        count <= count + 1;
                    end if;
                end if;
            end if;                                 
        end if;
    end process;                        
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI_send is
    Port (
        clk, SCLK, SS, start_spi: in STD_LOGIC; 
        data: in STD_LOGIC_VECTOR(11 downto 0);
        SPI_SI, MISO, busy_spi: out STD_LOGIC:= '0'
    );
end SPI_send;
architecture Behavioral of SPI_send is
    signal busy_int: STD_LOGIC:= '0';
    signal count: integer range 0 to 12:= 0;
    signal SCLK_prev: STD_LOGIC:= '0';
begin
    busy_spi <= busy_int; 
    SPI_SI <= start_spi and not busy_int; --send SPI SI to wake master
    process(clk) begin
        if rising_edge(clk) then
            SCLK_prev <= SCLK;
            if SCLK = '1' and SCLK_prev = '0' then --detect rising edge
                if busy_int = '0' and SS = '0' and start_spi = '1' then --assert busy and start
                    busy_int <= '1';
                elsif busy_int = '1' and SS = '0' then
                    if count = 12 then
                        busy_int <= '0';
                        MISO <= '0';
                    else
                        MISO <= data(11 - count); --MSB first
                        count <= count + 1;
                    end if;
                elsif SS = '1' then --master unasserts early
                    busy_int <= '0';
                    MISO <= '0';            
                end if;            
            end if;
        end if;    
    end process;    
end Behavioral;            

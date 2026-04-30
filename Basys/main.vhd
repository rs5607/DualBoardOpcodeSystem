library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main_vhd is
  Port (
      clk, RX, MOSI, SCLK, SS: in STD_LOGIC;
      sw: in STD_LOGIC_VECTOR(15 downto 0);
      TX, MISO, SPI_SI: out STD_LOGIC;
      led: out STD_LOGIC_VECTOR(15 downto 0);
      seg: out STD_LOGIC_VECTOR(6 downto 0);
      an: out STD_LOGIC_VECTOR(3 downto 0)
   );
end main_vhd;


architecture Behavioral of main_vhd is --component declarations (theres a lot)
    component SPI_recieve is
        port(
            clk, SCLK, MOSI, SS, done_uart: in STD_LOGIC;
            opcode: out STD_LOGIC_VECTOR(7 downto 0);
            done_spi: out STD_LOGIC
        );
    end component; 
    
    component SPI_send is 
        port(
            clk, SCLK, SS, start_spi: in STD_LOGIC;
            data: in STD_LOGIC_VECTOR(11 downto 0);
            SPI_SI, MISO, busy_spi: out STD_LOGIC
        ); 
    end component;
    
    component UART_recieve is
        port(
            clk, RX, SCLK: in STD_LOGIC;
            opcode: out STD_LOGIC_VECTOR(7 downto 0);
            done_uart: out STD_LOGIC
        ); 
    end component;
    
    component UART_send is
        port(
            clk, start_uart: in STD_LOGIC;
            data: in STD_LOGIC_VECTOR(11 downto 0);
            TX, busy_uart: out STD_LOGIC
        );           
    end component;
    
    component calculate is
        port(
            sw: in STD_LOGIC_VECTOR(15 downto 0);
            opcode: in STD_LOGIC_VECTOR(7 downto 0);
            send: out STD_LOGIC;
            result: inout STD_LOGIC_VECTOR(15 downto 0);
            send_data: out STD_LOGIC_VECTOR(11 downto 0)
        ); 
    end component;     
    
    component display is
        port(
            clk: in STD_LOGIC;
            opcode: in STD_LOGIC_VECTOR(7 downto 0);
            result: in STD_LOGIC_VECTOR(15 downto 0);
            led: out STD_LOGIC_VECTOR(15 downto 0);
            seg: out STD_LOGIC_VECTOR(6 downto 0);
            an: out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;   
    
    signal opcode: STD_LOGIC_VECTOR(7 downto 0):= (others => '0'); --opcode passed to display
    signal opcode_uart: STD_LOGIC_VECTOR(7 downto 0):= (others => '0'); --opcode if recieved via uart
    signal opcode_spi: STD_LOGIC_VECTOR(7 downto 0):= (others => '0'); --opcode if recived via SPI
    signal send_data: STD_LOGIC_VECTOR(11 downto 0):= (others => '0'); --buffer if needed to send data back to Zed
    signal result: STD_LOGIC_VECTOR(15 downto 0):= (others => '0'); --result from selected computation function
    signal start_uart: STD_LOGIC:= '0';--signal to say UART should start sending a packet
    signal start_spi: STD_LOGIC:= '0'; --signal to say SPI should start sending a packet
    signal done_uart: STD_LOGIC:= '0'; --signal to say UART has recieved a packet
    signal done_spi: STD_LOGIC:= '0'; --signal saying SPI has recieved a packet
    signal send: STD_LOGIC:= '0'; --signal to send data back to Zed
    signal busy_spi: STD_LOGIC:= '0'; --signal to indicate SPI is currently sending
    signal busy_uart: STD_LOGIC:= '0'; --signal to indicate UART is currently sending
    signal send_lock: STD_LOGIC:= '1'; --lock so that a communication interface only sends one time, reset by recieving another opcode
                           
begin
    spi_recv_inst: SPI_recieve
        port map(
            clk => clk,
            SCLK => SCLK,
            MOSI => MOSI,
            SS => SS,
            done_uart => done_uart,
            opcode => opcode_spi,
            done_spi => done_spi
        );
        
    uart_recv_inst: UART_recieve
        port map(
            clk => clk,
            RX => RX,
            SCLK => SCLK,
            opcode => opcode_uart,
            done_uart => done_uart
        );  
        
        process(done_uart, done_spi, clk) begin --multiplex the done signals for uart and spi to see which opcode should be used
            if rising_edge(clk) then
                if done_uart = '1' then
                    opcode <= opcode_uart;
                elsif done_spi = '1' then
                    opcode <= opcode_spi;
                end if;
                if opcode(2) = '1' then --pulse send clock low so that the board only send the packet one time
                    send_lock <= '0';
                    opcode(2) <= '0';
                else
                    send_lock <= '1'; --lock is high if opcode doesnt say to send back, preventing a uneeded send
                end if;        
                 
            end if;    
        end process;                          


    calc_inst: calculate
        port map(
            sw => sw,
            opcode =>opcode,
            send => send,
            result => result,
            send_data => send_data    
        );    
        
    process(clk) begin
        if rising_edge(clk) then
            if start_spi = '0' and start_uart = '0' and send_lock = '0' then --send lock so that a packet is only sent once
                if opcode(3) = '1' then
                    start_spi <= '1';
                    send_lock <= '1';
                else
                    start_uart <= '1';
                    send_lock <= '1';
                end if;
            elsif send_lock = '1' then --reset start when sending
                start_spi <= '0';
                start_uart <= '0';
            end if;                            
        end if;
    end process;  
    
                
    
    
    spi_send_inst: SPI_send
        port map(
            clk => clk,
            SCLK => SCLK,
            SS => SS,
            start_spi => start_spi,
            data => send_data,
            SPI_SI => SPI_SI,
            MISO => MISO,
            busy_spi => busy_spi
        );                       
                
    uart_send_inst: UART_send
        port map(
            clk => clk,
            start_uart => start_uart,
            data => send_data,
            TX => TX,
            busy_uart => busy_uart
        );            

    disp_inst: display
        port map(
            clk => clk,
            opcode => opcode,
            result => result,
            led => led,
            seg => seg,
            an => an
        );  
end Behavioral;



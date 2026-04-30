`timescale 1ns / 1ps

module main_v(
    input SW0, SW1, SW2, SW3, SW4, SW5, SW6, SW7, BTNC, //User Input
    input MISO, SPI_SI, //SPI
          RX, //UART
          clk,
    
    output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7,
           JA1, JA2, JA3, JA4, //SSD PMOD
           JB1, JB2, JB3, JB4, //SSD PMOD
    output SCLK, MOSI, SS, //SPI
           TX //UART
    );
    
    wire [7:0] opcode; //main opcode sent to Basys
    wire [11:0] uart_buffer; //buffer is recieved back via UART
    wire [11:0] spi_buffer; //buffer if recieved back via SPI
    wire start; //output from debounce, makes sure opcode is only sent once
    wire SCLK_send; //SCLK if SPI is sending
    wire SCLK_recv; //SCLK if SPI is receiving
    wire SS_send; //SS if SPI is sending
    wire SS_recv; //SS if SPI is receiving
    wire done_spi; //done signal from receiving opcode via SPI
    wire done_uart; //done signal from receiving opcode via UART
    wire spi_busy_send; //signal if SPI is currently sending
    reg display_enable; //signal to tell board to display, reset by sending an opcode, set by receiving a buffer
    
    debounce db(BTNC, clk, start); //debounce the button to only register 1 high signal from a push
 
    assign opcode = {SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0}; //opcode entered by user on switches, see manual for key

    wire start_SPI = opcode[3] && start; //two lines decide which communication interface is used
    wire start_UART = !opcode[3] && start;
    
    
    assign SCLK = spi_busy_send ? SCLK_send : SCLK_recv; //multiplex SCLK and SS so they are not dual driven
    assign SS = spi_busy_send ? SS_send : SS_recv;
    
    UART_send uart_send_inst(opcode, clk, start_UART, TX); //UART send and receive instance
    UART_recieve uart_recieve_inst(clk, start_UART, RX, uart_buffer, done_uart);
    
    SPI_send spi_send_inst(opcode, clk, start_SPI, SS_send, SCLK_send, MOSI, spi_busy_send); //SPI send and receive instance
    SPI_recieve spi_recieve_inst(clk, start_SPI,  MISO, SPI_SI, spi_buffer, SCLK_recv, SS_recv, done_spi);
    
    always @ (start, done_spi, done_uart) begin //display enable turns off when opcode is sent, only turned back on by recieving something
        if (start == 1) begin
            display_enable <= 1'b0;
        end else if (done_uart | done_spi) begin
            display_enable <= 1'b1;
        end
    end       
            
    wire [11:0] buffer = opcode[3] ? spi_buffer : uart_buffer; //multiplex buffer so it is not dual driven, buffer is determined by the opcode since the send method is the same as the return
    display display_inst(clk, display_enable, buffer, LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7, JA1, JA2, JA3, JA4, JB1, JB2, JB3, JB4); //display instance
    
endmodule

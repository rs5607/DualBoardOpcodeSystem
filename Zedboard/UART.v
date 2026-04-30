`timescale 1ns / 1ps
//UART communication
//clock of 100MHz with baud rate of 115200

module UART_send(
    input [7:0] opcode,
    input clk,
    input wire start_uart,
    output reg TX = 1
    );
    
    localparam BAUD_DIV = 868; //baud divisor for 115200bps
    
    
    reg [14:0] baud_count = 0; 
    reg[4:0] count = 0;
    reg busy = 0;
    
    always @ (posedge clk) begin
        if (!busy && start_uart) begin
            TX <= 0; //pulse TX low to wake RX on Basys
            count <= 0; //reset count
            busy <= 1; //assert busy so you cant override
            baud_count <= 0; //reset baud count
            
        end else if (busy) begin //busy is asserted, countinue with transmission                              
            if (baud_count < BAUD_DIV - 1) begin //count to baud rate divisor, then send
                baud_count <= baud_count + 1;
            end else begin
                if (count == 8) begin //if last transmission, put TX high again and unassert sending
                    TX <= 1;
                    busy <= 0;             
                end else begin
                    baud_count <= 0;
                    TX <= opcode[count]; //LSB first
                    count <= count + 1;
                end       
            end    
        end            
    end 
endmodule

module UART_recieve(
    input clk, clr,
    input wire RX,
    output reg [11:0] buffer,
    output reg done_uart = 0
);

    localparam BAUD_DIV = 868; //Baud Divisor for 115200bps
    localparam HALF_BAUD = 434; //half baud count so that we sample in the middle of a pulse
    
    reg [14:0] baud_count = 0; 
    reg [4:0] count = 0;
    reg busy = 0;
    reg sample = 0;
    
    always @ (posedge clk) begin
        if (clr) begin
            buffer <= 0;
        end else if (!busy && !RX) begin //UART started by low pulse
            count <= 0;
            busy <= 1;
            baud_count <= 0;
            sample <= 0;
            done_uart <= 0;
            
        end else if (busy) begin
            if (!sample) begin //get to the middle of a pulse before sampling
                if (baud_count < HALF_BAUD - 1) begin 
                    baud_count <= baud_count + 1;
                end else begin
                    baud_count <= 0;
                    sample <= 1;
                end
                
            end else begin                
                if (baud_count < BAUD_DIV - 1) begin
                    baud_count <= baud_count + 1;
                end else begin
                    if (count == 12) begin //12 bits always sent
                        busy <= 0;
                        done_uart <= 1;
                    end else begin
                        baud_count <= 0;
                        buffer[count] <= RX; //LSB first
                        count <= count + 1;
                    end    
                end
            end    
        end            
    end
endmodule

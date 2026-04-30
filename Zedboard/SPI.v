`timescale 1ns / 1ps
//SPI communication
//SPI_SI is slave interrupt

module SPI_send(
    input [7:0] opcode, //opcode from switches
    input clk,
    input wire start_SPI,

    output reg SS = 1,
    output reg SCLK = 0,
    output reg MOSI = 0,
    output reg busy_send = 0 //busy_send used to have outputs SCLK and SS use the SPI send SS and SCLK instead of the recieve SS and SCLK
    );
    
    reg [4:0] count = 0;
    reg busy = 0;
    
    always @ (posedge clk) begin
    
        if (!busy && start_SPI) begin
            SS <= 0;
            count <= 0;
            busy <= 1; //assert busy to not be interrupted
            busy_send <= 1; //assert SCLK and SS from sending
            SCLK <= 1; //pulse SCLK to wake up SPI recieve on Basys
            
        end else if (busy) begin
            SCLK <= ~SCLK; //change SCLK
            
            if (SCLK == 0) begin //transmit on "falling edge" so Basys can recieve on rising
                if (count == 8) begin
                    SS <= 1; //SS high idle
                    busy <= 0; //unassert busy
                    busy_send <= 0;
                    SCLK <= 0; //SCLK low idle
                end else begin               
                    MOSI <= opcode[7 - count]; //MSB first
                    count <= count + 1;
                end
            end
        end
    end    
endmodule

module SPI_recieve(
    input clk, clr,
    input wire MISO, SPI_SI,
    
    output reg [11:0] buffer,
    output reg SCLK = 0, 
    output reg SS = 1,
    output reg done_spi = 0
);

    reg [4:0] count = 0;
    reg busy = 0;
    reg SCLK_int = 0;
    
    always @ (posedge clk) begin
        if (clr) begin
            buffer <= 0;
        end else if (!busy && SPI_SI) begin //assert busy
            busy <= 1;
            SS <= 0;
            count <= 0;
            done_spi <= 0;
            
            
        end else if (busy) begin
            SCLK_int <= ~SCLK_int;
            
            if (SCLK == 1) begin
                if (count == 12) begin //done, unassert busy and deselect board, send done signal
                    SS <= 1;
                    busy <= 0;
                    SCLK_int <= 0;
                    done_spi <= 1;
                end else begin    
                    buffer[11 - count] <= MISO; //MSB first
                    count <= count + 1;
                end    
            end
        end else begin
            SS <= 1;
            SCLK_int <= 0;
        end
        SCLK <= SCLK_int;
    end    
endmodule

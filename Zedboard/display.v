`timescale 1ns / 1ps

module display(
    input clk,
    input display_enable, //enable high when something is recieved back
    input wire [11:0] buffer,
    output LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7,
               JA1, JA2, JA3, JA4, //SSD PMOD
               JB1, JB2, JB3, JB4 //SSD PMOD
    );
    
    reg [2:0] display_result = 0;
    
    always @ (posedge clk) begin
        if (display_enable) begin
             case (buffer[2:0]) //since result was sent back, buffer[2] will always be 1, switch on rest of buffer[1:0]               
                3'b100:
                    //special
                    begin
                        if (buffer[11] == 1) begin
                            display_result <= 3'b111; //easter egg
                        end else begin
                            display_result <= 3'b100; //flash   
                        end
                    end
                3'b101:
                    //leds
                    display_result <= 3'b001;
                3'b110:
                    //SSD
                    display_result <= 3'b010;
                3'b111:
                    //Both
                    display_result <= 3'b011;
                default: 
                    //hide result
                    display_result <= 3'b000;
            endcase  
        end else begin
            display_result <= 3'b000; //if display enable is low, turn off SSD and LEDs
        end             
    end
    
    LED led_display(buffer[11:4], display_result, clk, LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7);
    Multi_SSD ssd_display(buffer[11:4], display_result, clk, JA1, JA2, JA3, JA4, JB1, JB2, JB3, JB4);       
                
endmodule

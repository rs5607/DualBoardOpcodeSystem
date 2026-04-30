`timescale 1ns / 1ps

module LED(
    input [7:0] buffer, //result from Basys
    input [2:0] display, //display setting
    input clk,
    output reg LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7
    );
    
    integer count = 0;
    integer led_sequence = 0;
    
    always @ (posedge clk) begin  
        if (display[0] && !display[2]) begin //normal operation
            LD0 <= buffer[0];
            LD1 <= buffer[1];
            LD2 <= buffer[2];
            LD3 <= buffer[3];
            LD4 <= buffer[4];
            LD5 <= buffer[5];
            LD6 <= buffer[6];
            LD7 <= buffer[7];
        end else if (display[2] && !display[0]) begin //flash
            if (count == 16666666) begin  
                count <= 0;
                LD0 <= ~LD0;
                LD1 <= ~LD1;
                LD2 <= ~LD2;
                LD3 <= ~LD3;
                LD4 <= ~LD4;
                LD5 <= ~LD5;
                LD6 <= ~LD6;
                LD7 <= ~LD7;
            end else begin
                count <= count + 1; 
            end
        end else if (display[2] && display[0]) begin //easter egg
            if (count == 16666666) begin
                count <= 0;
                case (led_sequence)
                    0: begin
                        LD7 <= 0;
                        LD0 <= 1;
                        led_sequence <= led_sequence + 1;
                    end
                    1: begin
                        LD0 <= 0;
                        LD1 <= 1;
                        led_sequence <= led_sequence + 1;
                    end
                    2: begin
                        LD1 <= 0;
                        LD2 <= 1;
                        led_sequence <= led_sequence + 1;
                    end 
                    3: begin
                        LD2 <= 0;
                        LD3 <= 1;
                        led_sequence <= led_sequence + 1;
                    end
                    4: begin
                        LD3 <= 0;
                        LD4 <= 1;
                        led_sequence <= led_sequence + 1;
                    end
                    5: begin
                        LD4 <= 0;
                        LD5 <= 1;
                        led_sequence <= led_sequence + 1;
                    end           
                    6: begin
                        LD5 <= 0;
                        LD6 <= 1;
                        led_sequence <= led_sequence + 1;
                    end
                    7: begin
                        LD6 <= 0;
                        LD7 <= 1;
                        led_sequence <= 0;
                    end    
                    default: begin
                        LD0 = 0;
                        LD1 = 0;  
                        LD2 = 0;  
                        LD3 = 0;  
                        LD4 = 0;  
                        LD5 = 0;  
                        LD6 = 0;  
                        LD7 = 0;                           
                    end
                endcase
            end else begin
                count <= count + 1;
            end        
                                          
        end else begin //default state off
            LD0 = 0;
            LD1 = 0;  
            LD2 = 0;  
            LD3 = 0;  
            LD4 = 0;  
            LD5 = 0;  
            LD6 = 0;  
            LD7 = 0; 
        end
    end            
endmodule

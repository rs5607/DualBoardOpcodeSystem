`timescale 1ns / 1ps
//debounce the button so that only 1 high signal is gotten from a button push, debounce period is 10ms
module debounce(
    input wire btn_in, clk,
    output reg btn_out = 0
    );
    
    localparam DEBOUNCE_MAX = 1_000_000; //updated debounce max for 10ms
    
    reg [19:0] count = 0; 
    reg btn_last = 0;
    
    always @ (posedge clk) begin
        btn_out <= 0;
        
        if (btn_in == btn_last) begin
            if (count < DEBOUNCE_MAX - 1) begin
                count <= count + 1;
            end else if (count == DEBOUNCE_MAX - 1) begin
                btn_out <= btn_in;
                count <= count + 1;
            end
        end else begin
            count <= 0;
            btn_last <= btn_in;
        end
    end                        
endmodule

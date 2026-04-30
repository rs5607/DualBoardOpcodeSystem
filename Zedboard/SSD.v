`timescale 1ns / 1ps


module Multi_SSD(
    input [7:0] buffer, //two 4 bit inputs
    input [2:0] display, //display setting
    input clk,
    output JA1, JA2, JA3, JA4, //Pmod SSD pins
           JB1, JB2, JB3, JB4
        );
reg seg; //switches between first and second display
integer count = 0; //count for switching displays
integer count_flash = 0; //seperate count for special flash display mode
reg flash = 0;
reg on = 0; //SSD enable
initial
begin
    count = 0;
    seg = 0;
end    
reg A, B, C, D;
always @(posedge clk) begin
    if (count == 499999) begin  
        seg = ~seg;
        count = 0;
    end else begin
        count = count + 1;
    end   
    if (display[1] && !display[2]) begin //normal operation
        on <= 1;
        if (~seg) begin //normal operation, seg displays 8 bit result from Basys
            D = buffer[0];
            C = buffer[1];
            B = buffer[2];
            A = buffer[3];
         end else begin
            D = buffer[4];
            C = buffer[5];
            B = buffer[6];
            A = buffer[7];
         end
    end else if (display[2] && !display[0]) begin //flash
        on <= 1;
        if (count_flash == 16666666) begin
            flash <= ~flash;
            if (flash) begin
                A = 1;
                B = 1;
                C = 1;
                D = 1;
            end else begin
                A = 0;
                B = 0;
                C = 0;
                D = 0;
            end
        end
    end else if (display[2] && display[0]) begin //easter egg
        on <= 1;
        if (~seg) begin
            A = 0;
            B = 1;
            C = 1;
            D = 0;
        end else begin
            A = 0;
            B = 0;
            C = 1;
            D = 0;
        end
    end else begin //no result recieved from Basys, turn SSD off
        on <= 0;
    end                                         
end

    SSD_Decoder D1(on, A, B, C, D, seg, JA1, JA2, JA3, JA4, JB1, JB2, JB3, JB4);
endmodule


module SSD_Decoder(
input on, A, B, C, D,  //enable signal and 4 bit input
input select, //digit select
output JA1, JA2, JA3, JA4,
       JB1, JB2, JB3, JB4
    );
    
    wire AA, AB, AC, AD, AE, AF, AG, CAT;
    wire display[6:0]; //corresponds to Segments

    

    
    assign display[6] = (!A&( (C&D) | !(B^D))) | // Logic Expressions for the segments
                        (A&( (!B&!C)|(B&!D) ))|
                        (C&( (B&D)|!D) );
                        
    assign display[5] = (!A& (!B|(!(C^D) )) )|
                        (A&((!C&D)|(!B&!D)));
                        
    assign display[4] = (A^B) | 
                        (!A&((!B&!C)|(!B&D)))|
                        (!C&D);
                        
    assign display[3] = (B& ( (C^D) | (A&!C) ))|
                        (!B& ( (!C&!D) | (!A&C) | (A&D) ));
                        
    assign display[2] = (A& ( (!(C^D)) | B)) |
                        (!D& ((!A&!B) | C));
                        
    assign display[1] = (B& ((!(A^C)) | (C&!D)))|
                        (A&!B) | (!C&!D);
                        
    assign display[0] = (A& ((B&D) | !B)) |
                        (C& ((!B&D) | !D))|
                        !A&B&!C;
                        
    assign AA = display[6] & on; //on = SSD enable
    assign AB = display[5] & on;
    assign AC = display[4] & on;
    assign AD = display[3] & on;
    assign AE = display[2] & on;
    assign AF = display[1] & on;
    assign AG = display[0] & on;
    assign CAT = select;
    
    assign JA1 = AA; //Mapping internal seven seg signal names to output on PMod
    assign JA2 = AB;
    assign JA3 = AC;
    assign JA4 = AD;
    assign JB1 = AE;
    assign JB2 = AF;
    assign JB3 = AG;
    assign JB4 = CAT;
        
endmodule

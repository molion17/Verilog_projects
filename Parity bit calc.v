module Parity_bit_calc #(parameter N=8) (P_input,clk,rst,P_bit,parity_out,load);
// P_bit=0 even 
// P_bit=1 odd
input [N-1:0] P_input;
input clk,rst,P_bit,load;
output reg parity_out;
always @(posedge clk or negedge rst) begin
    if(!rst)
    begin
        parity_out<=0;
    end
    else if (load)
    begin
        if(P_bit)
        begin
            parity_out <= !(^P_input);
        end
        else
        begin
            parity_out <= (^P_input);
        end 
    end
end
endmodule

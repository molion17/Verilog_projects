module Parity_bit_calc #(parameter N=8) (
    input   logic [N-1:0] P_input,
    input   logic clk,rst,P_bit,load,i_tx_en,
    output  logic  parity_out);
// P_bit=0 even 
// P_bit=1 odd
    always_ff @(posedge clk or negedge rst) begin
        if(!rst)
            begin
                parity_out<=0;
            end
        else if (i_tx_en && load)
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


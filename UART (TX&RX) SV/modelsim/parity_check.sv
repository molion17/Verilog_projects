module parity_check#(parameter w=8)(
    input logic i_par_n, cheak_par,i_par_odd,i_clk,i_rst_n,par_bit,
    input logic [w-1:0] o_data,
    output logic o_parity_err
);
    logic expected ,error;
    assign expected = (^o_data) ^ i_par_odd;
    assign error = (i_par_n) && !(expected == par_bit);
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_parity_err <=0;
        end
        else begin
            if (cheak_par) begin
                o_parity_err <= error;
            end
        end
    end
endmodule


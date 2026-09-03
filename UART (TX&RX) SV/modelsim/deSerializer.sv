module deserializer #(parameter w = 8) (
    input  logic  i_rx, shift_en, i_clk, i_rst_n,
    output logic [w-1:0] o_data,
    output logic  done
);
    logic [$clog2(w+1)-1:0] count;
    logic [$clog2(w+1)-1:0] count_next;

    assign count_next = count + 1'b1;
    assign done   = shift_en && (count_next == w);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_data <= '0;
            count  <= '0;
        end
        else if (shift_en) begin
            o_data <= {i_rx, o_data[w-1:1]};
           
            if (done) begin
                count <= '0;      
            end
            else begin
                count <= count_next;
            end
        end
    end
endmodule



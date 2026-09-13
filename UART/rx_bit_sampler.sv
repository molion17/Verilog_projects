
module rx_bit_sample (
    input logic i_clk, i_rst_n, i_rx_sync, i_rx_en, i_rx,
    output logic o_bit_ready, o_bit_value
);
    localparam oversample = 16;
    logic [3:0] sample_counter;
    logic [2:0] sample_reg;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            sample_counter <= 0;
        end
        else if (i_rx_sync) begin
            sample_counter <= 0;
        end
        else if (i_rx_en) begin
            if (sample_counter == (oversample - 1)) begin
                sample_counter <= 0;
            end
            else begin
                sample_counter <= sample_counter + 1'b1;
            end
        end
    end

    assign o_bit_ready = (sample_counter == (oversample - 1)) && i_rx_en;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            sample_reg <= 0;
        end
        else if (i_rx_sync) begin
            sample_reg <= 0;
        end
        else if (i_rx_en) begin
            unique case (sample_counter)
                4'd6:    sample_reg[0] <= i_rx;
                4'd7:    sample_reg[1] <= i_rx;
                4'd8:    sample_reg[2] <= i_rx;
                default: sample_reg    <= sample_reg;
            endcase
        end
    end

    assign o_bit_value = (sample_reg[0] & sample_reg[1]) |
                          (sample_reg[1] & sample_reg[2]) |
                          (sample_reg[0] & sample_reg[2]);

endmodule


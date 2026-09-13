module baud_gen #(
    parameter int unsigned rate = 9600,
    parameter int unsigned freq = 50_000_000
) (
    input  logic i_clk, i_rst_n,
    input  logic i_rx_sync,  
    output logic o_tx_en,
    output logic o_rx_en
);
    localparam int unsigned tx_cycles = freq / rate;
    localparam int unsigned rx_cycles = tx_cycles / 16;

    localparam int unsigned TX_CW = $clog2(tx_cycles);
    localparam int unsigned RX_CW = $clog2(rx_cycles);

    logic [TX_CW-1:0] tx_counter;
    logic [RX_CW-1:0] rx_counter;

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            tx_counter <= '0;
        end
        else if (tx_counter == tx_cycles - 1) begin
            tx_counter <= '0;
        end
        else begin
            tx_counter <= tx_counter + 1'b1;
        end
    end

    assign o_tx_en = (tx_counter == tx_cycles - 1);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            rx_counter <= '0;
        end
        else if (i_rx_sync) begin
            rx_counter <= '0;   
        end
        else if (rx_counter == rx_cycles - 1) begin
            rx_counter <= '0;
        end
        else begin
            rx_counter <= rx_counter + 1'b1;
        end
    end

    assign o_rx_en = (rx_counter == rx_cycles - 1);

endmodule
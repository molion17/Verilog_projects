module uart_top #(
    parameter int unsigned DATA_W      = 8,
    parameter int unsigned CLK_FREQ_HZ = 50_000_000,
    parameter int unsigned BAUD_RATE   = 9600
) (
    input  logic              i_clk, i_rst_n,
 
    // TX side
    input  logic [DATA_W-1:0] i_tx_data,
    input  logic               i_tx_valid,
    output logic               o_tx_busy,
    output logic               o_tx,             // serial output pin
 
    // RX side
    input  logic               i_rx,             // serial input pin
    output logic [DATA_W-1:0]  o_rx_data,
    output logic               o_rx_valid,
    output logic               o_rx_busy,
    output logic               o_rx_parity_err,
    output logic               o_rx_frame_err,
 
    // Shared parity configuration -- must agree on both ends of the link
    input  logic               i_par_en, i_par_odd
);
 
    logic tx_tick, rx_tick, rx_sync;
 
    baud_gen #(
        .rate (BAUD_RATE),
        .freq (CLK_FREQ_HZ)
    ) u_baud_gen (
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_rx_sync (rx_sync),
        .o_tx_en   (tx_tick),
        .o_rx_en   (rx_tick)
    );
 
    uart_tx #(.DATA_W(DATA_W)) u_uart_tx (
        .i_data    (i_tx_data),
        .i_valid   (i_tx_valid),
        .i_clk     (i_clk),
        .i_rst_n   (i_rst_n),
        .i_par_en  (i_par_en),
        .i_par_odd (i_par_odd),
        .i_tx_en   (tx_tick),
        .o_tx      (o_tx),
        .o_busy    (o_tx_busy)
    );
 
    uart_rx #(.DATA_W(DATA_W)) u_uart_rx (
        .i_clk        (i_clk),
        .i_rst_n      (i_rst_n),
        .i_rx         (i_rx),
        .i_par_en     (i_par_en),
        .i_par_odd    (i_par_odd),
        .i_rx_en      (rx_tick),
        .o_data       (o_rx_data),
        .o_valid      (o_rx_valid),
        .o_busy       (o_rx_busy),
        .o_parity_err (o_rx_parity_err),
        .o_frame_err  (o_rx_frame_err),
        .o_rx_sync    (rx_sync)
    );
 
endmodule
 
module uart_top_fifo #(
    parameter int unsigned DATA_W      = 8,
    parameter int unsigned CLK_FREQ_HZ = 50_000_000,
    parameter int unsigned BAUD_RATE   = 9600,
    parameter int unsigned DEPTH = 8,
    parameter int unsigned RTS_MARGIN  = 1
)(
    input i_clk,i_rst_n,

//    --> TX FIFO <--
    input wr_en_tx,
    input [DATA_W-1:0] i_data_tx,
    output o_full_tx,o_empty_tx,
    output [$clog2(DEPTH):0] o_count_tx,   

//  --> RX FIFO <--
    input  rd_en_rx,
    output o_full_rx,o_empty_rx,
    output [DATA_W-1:0] o_data_rx,
    output [$clog2(DEPTH):0] o_count_rx, 
 
 // --> RX overrun <--
    output logic o_rx_overrun,
    input  logic i_rx_overrun_clr,
 
    // --> flow control <--
    output logic o_rts,   // 1 = "ok to send me more", 0 = "stop, my RX FIFO is nearly full"
    input  logic i_cts,   // 1 = "remote receiver has room", gates whether TX may send

// -->  top UART <--
    // TX side
    output logic               o_tx_busy,
    output logic               o_tx,             // serial output pin
 
    // RX side
    input  logic               i_rx,             // serial input pin
    output logic               o_rx_busy,
    output logic               o_rx_parity_err,
    output logic               o_rx_frame_err,
 
    // Shared parity configuration
    input  logic               i_par_en, i_par_odd
);
    logic rd_en_tx;
    logic [DATA_W-1:0] data_tx_fifo;
    logic  rx_valid;
    logic [DATA_W-1:0] data_rx_fifo;
    logic tx_vaild;
    assign tx_vaild = (!o_tx_busy && !o_empty_tx && i_cts);
    assign rd_en_tx = tx_vaild; 
    assign o_rts = (o_count_rx < (DEPTH - RTS_MARGIN));
    
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_rx_overrun <= 1'b0;
        end
        else if (rx_valid && o_full_rx) begin
            o_rx_overrun <= 1'b1;
        end
        else if (i_rx_overrun_clr) begin
            o_rx_overrun <= 1'b0;
        end
    end
 // -----> TX FIFO <-----
 
 fifo #(
    .width(DATA_W)
    ,.depth(DEPTH) 
 )  FIFO_tx(
    .i_clk(i_clk)
    ,.i_rst_n(i_rst_n)
    ,.wr_en(wr_en_tx)
    ,.rd_en(rd_en_tx)
    ,.i_data(i_data_tx)
    ,.o_full(o_full_tx)
    ,.o_empty(o_empty_tx)
    ,.o_data(data_tx_fifo)
    ,.o_count(o_count_tx) 
 );

    logic [DATA_W-1:0] tx_data_latched;
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            tx_data_latched <= '0;
        end
        else if (tx_vaild) begin
            tx_data_latched <= data_tx_fifo;
        end
    end

// -----> TOP <-----


 uart_top #(
    .DATA_W(DATA_W)
    ,.CLK_FREQ_HZ(CLK_FREQ_HZ)
    ,.BAUD_RATE(BAUD_RATE)
 ) dut_top (
    .i_clk(i_clk) ,.i_rst_n(i_rst_n),
 
    // TX side
    .i_tx_data(tx_data_latched)
    ,.i_tx_valid(tx_vaild)  
    ,.o_tx_busy(o_tx_busy)
    ,.o_tx(o_tx)                                 // serial output pin
 
    // RX side
    ,.i_rx(i_rx)                                 // serial input pin
    ,.o_rx_data(data_rx_fifo)
    ,.o_rx_valid(rx_valid)
    ,.o_rx_busy(o_rx_busy)
    ,.o_rx_parity_err(o_rx_parity_err)
    ,.o_rx_frame_err(o_rx_frame_err)
 
    // Shared parity configuration 
    ,.i_par_en(i_par_en)
    ,.i_par_odd(i_par_odd)
);
    
 
 
 // -----> RX FIFO <-----

 fifo #(
    .width(DATA_W)
    ,.depth(DEPTH) 
 ) FIFO_rx (
    .i_clk(i_clk)
    ,.i_rst_n(i_rst_n)
    ,.wr_en(rx_valid)
    ,.rd_en(rd_en_rx)
    ,.i_data(data_rx_fifo)
    ,.o_full(o_full_rx)
    ,.o_empty(o_empty_rx)
    ,.o_data(o_data_rx)
    ,.o_count(o_count_rx) 
);

endmodule
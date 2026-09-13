module apb_uart_wrapper#(
    parameter int unsigned DATA_W      = 8,
    parameter int unsigned CLK_FREQ_HZ = 50_000_000,
    parameter int unsigned BAUD_RATE   = 9600,
    parameter int unsigned DEPTH = 8,
    parameter int unsigned RTS_MARGIN  = 1
)(
    // ---- APB3 ----
    input  logic        PCLK, PRESETn,
    input  logic        PSEL, PENABLE, PWRITE,
    input  logic [7:0]  PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR,
 
    // ---- Serial + flow-control pins, exposed to the outside world ----
    output logic o_tx,
    input  logic i_rx,
    output logic o_rts,
    input  logic i_cts

);


    localparam logic [7:0] ADDR_TX_DATA     = 8'h00;
    localparam logic [7:0] ADDR_RX_DATA     = 8'h04;
    localparam logic [7:0] ADDR_STATUS      = 8'h08;
    localparam logic [7:0] ADDR_CONTROL     = 8'h0C;
    localparam logic [7:0] ADDR_OVERRUN_CLR = 8'h10;

    logic              wr_en_tx, rd_en_rx;
    logic [DATA_W-1:0] i_data_tx, o_data_rx;
    logic              o_full_tx, o_empty_tx, o_full_rx, o_empty_rx;
    logic [$clog2(DEPTH):0] o_count_tx, o_count_rx;
    logic              o_rx_overrun, i_rx_overrun_clr;
    logic              o_tx_busy, o_rx_busy, o_rx_parity_err, o_rx_frame_err; 
    logic              par_en_reg, par_odd_reg;

uart_top_fifo #(
    .DATA_W(DATA_W)
    ,.CLK_FREQ_HZ(CLK_FREQ_HZ)
    ,.BAUD_RATE(BAUD_RATE)
    ,.DEPTH(DEPTH)
    ,.RTS_MARGIN(RTS_MARGIN)
) dut_top(
    .i_clk(PCLK),.i_rst_n(PRESETn)

//    --> TX FIFO <--
    ,.wr_en_tx(wr_en_tx)
    ,.i_data_tx(i_data_tx)
    ,.o_full_tx(o_full_tx),.o_empty_tx(o_empty_tx)
    ,.o_count_tx(o_count_tx)   

//  --> RX FIFO <--
    ,.rd_en_rx(rd_en_rx)
    ,.o_full_rx(o_full_rx),.o_empty_rx(o_empty_rx)
    ,.o_data_rx(o_data_rx)
    ,.o_count_rx(o_count_rx) 
 
 // --> RX overrun <--
    ,.o_rx_overrun(o_rx_overrun)
    ,.i_rx_overrun_clr(i_rx_overrun_clr)
 
    // --> flow control <--
    ,.o_rts(o_rts)     
    ,.i_cts(i_cts)

// -->  top UART <--
    // TX side
    ,.o_tx_busy(o_tx_busy)
    ,.o_tx(o_tx)                                 // serial output pin
 
    // RX side
    ,.i_rx(i_rx)                                 // serial input pin
    ,.o_rx_busy(o_rx_busy)
    ,.o_rx_parity_err(o_rx_parity_err)
    ,.o_rx_frame_err(o_rx_frame_err)
 
    // Shared parity configuration
    ,.i_par_en(par_en_reg),.i_par_odd(par_odd_reg)
);
    logic addr_valid;
    assign addr_valid = (PADDR == ADDR_TX_DATA)  || (PADDR == ADDR_RX_DATA) ||
                         (PADDR == ADDR_STATUS)   || (PADDR == ADDR_CONTROL) ||
                         (PADDR == ADDR_OVERRUN_CLR);
    
    logic access;
    assign access = PSEL && PENABLE ;
    assign PREADY = 1'b1;
    assign PSLVERR = access && ! addr_valid;

    assign wr_en_tx = access && (PADDR == ADDR_TX_DATA) && PWRITE;
    assign rd_en_rx = access && (PADDR == ADDR_RX_DATA) && !PWRITE;
    assign i_data_tx = PWDATA[DATA_W-1:0];
    assign i_rx_overrun_clr = access && (PADDR == ADDR_OVERRUN_CLR) && PWRITE && PWDATA[0];

    // -->parity<-- 
    always_ff @(posedge PCLK or negedge PRESETn) begin 
        if (!PRESETn) begin
          par_en_reg <= 0;
          par_odd_reg <=0;  
        end
        else if(access && PWRITE && (PADDR == ADDR_CONTROL))begin
            par_en_reg <= PWDATA[0];
            par_odd_reg <= PWDATA[1]; 
        end
    end

    always_comb begin  
        case (PADDR)
           ADDR_TX_DATA :  PRDATA = {{(32-DATA_W){1'b0}},i_data_tx};
           ADDR_RX_DATA :  PRDATA = {{(32-DATA_W){1'b0}},o_data_rx};
           ADDR_STATUS  :  PRDATA = {23'b0, o_rx_overrun, o_rx_frame_err, o_rx_parity_err,
                                         o_rx_busy, o_tx_busy, o_empty_rx, o_full_rx,
                                         o_empty_tx, o_full_tx};
           ADDR_CONTROL : PRDATA = {30'b0,par_odd_reg,par_en_reg};
           ADDR_OVERRUN_CLR: PRDATA = 32'b0;
        default: PRDATA = 32'b0;
        endcase
    end

endmodule 
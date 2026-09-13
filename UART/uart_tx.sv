module uart_tx #(parameter DATA_W = 8)
    (
    input   logic [DATA_W-1:0] i_data,
    input logic i_valid,i_clk,i_rst_n,i_par_en,i_par_odd,i_tx_en,
    output  logic o_tx,o_busy);
    
    logic done ,load,start,serial_out,parity_out;
    logic [1:0] select;
    
    fsm  u_fsm (
        .i_valid(i_valid)
        ,.i_tx_en(i_tx_en)
        ,.clk(i_clk)
        ,.rst(i_rst_n)
        ,.done(done)
        ,.select(select)
        ,.load(load)
        ,.start(start)
        ,.P_en(i_par_en)
        ,.busy(o_busy));

    Serializer #(.N(DATA_W)) secmodule (
        .P_input(i_data)
        ,.i_tx_en(i_tx_en)
        ,.clk(i_clk)
        ,.rst(i_rst_n)
        ,.start(start)
        ,.load(load)
        ,.serial_out(serial_out)
        ,.done(done));

    Parity_bit_calc #(.N(DATA_W)) thirdmodule (
        .i_tx_en(i_tx_en)
        ,.P_input(i_data)
        ,.clk(i_clk)
        ,.rst(i_rst_n)
        ,.P_bit(i_par_odd)
        ,.parity_out(parity_out)
        ,.load(load));

    mux fourthmodule (
        .serial_out(serial_out)
        ,.select(select)
        ,.parity_out(parity_out)
        ,.TX_out(o_tx));

endmodule

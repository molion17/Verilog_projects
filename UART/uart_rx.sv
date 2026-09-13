module uart_rx #(parameter DATA_W = 8 )(
    input logic i_clk,i_rst_n,i_rx,i_par_en,i_par_odd,i_rx_en, 
    output logic [DATA_W-1:0] o_data,
    output logic o_valid,o_busy,o_parity_err,o_frame_err,o_rx_sync
  );
    
    logic done,par_bit,cheak_par,shift_en, bit_ready , bit_value,start_check,pos_edge_A,edge_A;
  
  edge_detector detect_start (
    .clk(i_clk)
    ,.n_rst(i_rst_n)
    ,.A(i_rx)
    ,.neg_edge_A(start_check) 
    ,.pos_edge_A(pos_edge_A)
    ,.edge_A(edge_A)
    );
   
   rx_bit_sample u_sample (
    .i_clk(i_clk)
    ,.i_rst_n(i_rst_n)
    ,.i_rx_sync(o_rx_sync)
    ,.i_rx_en(i_rx_en)
    ,.i_rx(i_rx)
    ,.o_bit_ready(bit_ready)
    ,.o_bit_value(bit_value)
);

  fsm_rx u_fsm (
    .start_check(start_check)
    ,.i_bit_ready(bit_ready)
    ,.i_bit_value(bit_value)
    ,.i_clk(i_clk)
    ,.i_rst_n(i_rst_n)
    ,.i_par_n(i_par_en)
    ,.done(done)
    ,.o_valid(o_valid)
    ,.o_busy(o_busy)
    ,.o_frame_err(o_frame_err)
    ,.shift_en(shift_en)
    ,.par_bit(par_bit)
    ,.cheak_par(cheak_par)
    ,.o_rx_sync(o_rx_sync)
);

  deserializer #(.w(DATA_W)) u_deserializer (
    .i_bit_value(bit_value)
    ,.i_bit_ready(bit_ready)
    ,.i_rx_en(i_rx_en)
    ,.shift_en(shift_en)
    ,.i_clk(i_clk)
    ,.i_rst_n(i_rst_n)
    ,.o_data(o_data)
    ,.done(done)
);

  parity_check#(.w(DATA_W)) u_parity (
    .i_par_n(i_par_en)
    ,.cheak_par(cheak_par)
    ,.i_par_odd(i_par_odd)
    ,.i_clk(i_clk)
    ,.i_rst_n(i_rst_n)
    ,.par_bit(par_bit)
    ,.i_rx_en(i_rx_en)
    ,.o_data(o_data)
    ,.o_parity_err(o_parity_err)
);
  
  endmodule

module uart_rx #(parameter DATA_W = 8 )(
    input logic i_clk,i_rst_n,i_rx,i_par_en,i_par_odd, 
    output logic [DATA_W-1:0] o_data,
    output logic o_valid,o_busy,o_parity_err,o_frame_err  
  );
    
    logic done,par_bit,cheak_par,shift_en;
  
  fsm_rx first_module (
    .i_rx(i_rx)
    ,.i_clk(i_clk)
    ,.i_rst_n(i_rst_n)
    ,.i_par_n(i_par_en)
    ,.done(done),
    .o_valid(o_valid)
    ,.o_busy(o_busy)
    ,.o_frame_err(o_frame_err)
    ,.shift_en(shift_en)
    ,.par_bit(par_bit)
    ,.cheak_par(cheak_par)
);

  deserializer #(.w(DATA_W)) sec_mod (
    .i_rx(i_rx)
    ,.shift_en(shift_en)
    ,.i_clk(i_clk)
    ,.i_rst_n(i_rst_n)
    ,.o_data(o_data)
    ,.done(done)
);

  parity_check#(.w(DATA_W)) third_module (
    .i_par_n(i_par_en)
    ,.cheak_par(cheak_par)
    ,.i_par_odd(i_par_odd)
    ,.i_clk(i_clk)
    ,.i_rst_n(i_rst_n)
    ,.par_bit(par_bit)
    ,.o_data(o_data)
    ,.o_parity_err(o_parity_err)
);
  
  endmodule

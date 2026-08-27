module UART_TX #(parameter  N = 8 )(
    P_input,V_input,clk,rst,P_en,P_bit,TX_output,busy
);
    input [N-1:0] P_input;
    input  V_input,clk,rst,P_en,P_bit;
    output TX_output,busy;
    wire done ,load,start,serial_out,parity_out;
    wire [1:0] select;
    
    fsm  main (
        .V_input(V_input)
        ,.clk(clk)
        ,.rst(rst)
        ,.done(done)
        ,.select(select)
        ,.load(load)
        ,.start(start)
        ,.P_en(P_en)
        ,.busy(busy));

    Serializer #(.N(N)) secmodule (
        .P_input(P_input)
        ,.clk(clk)
        ,.rst(rst)
        ,.start(start)
        ,.load(load)
        ,.serial_out(serial_out)
        ,.done(done));

    Parity_bit_calc #(.N(N)) thirdmodule (
        .P_input(P_input)
        ,.clk(clk)
        ,.rst(rst)
        ,.P_bit(P_bit)
        ,.parity_out(parity_out)
        ,.load(load));

    mux fourthmodule (
        .serial_out(serial_out)
        ,.select(select)
        ,.parity_out(parity_out)
        ,.TX_out(TX_output));




endmodule

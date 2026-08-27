`timescale 1ns/1ps
module Parity_bit_calc_tb;
parameter N=8;
reg [N-1:0] P_input;
reg clk,rst,P_bit,load;
wire parity_out;
Parity_bit_calc #(.N(N)) DUT (
    .P_input(P_input)
    ,.clk(clk)
    ,.rst(rst)
    ,.P_bit(P_bit)
    ,.parity_out(parity_out)
    ,.load(load));
initial begin
    clk<=0;
    forever begin
        #10 clk=!clk;
    end
end
initial begin
    $monitor("time=%0t | P_input= %b | rst= %b | load= %b | P_bit= %b | parity_out=%b ",
    $time,P_input, rst, load , P_bit, parity_out);
end 
initial begin
    rst=0;
    P_input=0;
    P_bit=0;
    load=0;
    #23 rst=1;
    load =1;
    P_input = 8'b01001000; // parity =0 
    P_bit= 0;
    #10 load =0;
    #10 load =1; 
    P_input = 8'b01001000; // parity =1 at 50
    P_bit= 1;
    #10 load =0; 
    #30 load =1;
    P_input= 8'b11101010; // parity = 1 at 90
    P_bit =0 ;
    #10 P_bit=1; // parity =0
    #20;
    $finish;
end
endmodule

`timescale 1ns/1ps  
module Serializer_tb;
parameter N=8;

    reg [N-1:0] P_input;
    reg clk,rst,start,load;
    wire serial_out,done;

Serializer  #(.N(N)) dut (
    .P_input(P_input)
    ,.clk(clk)
    ,.rst(rst)
    ,.start(start)
    ,.load(load)
    ,.serial_out(serial_out)
    ,.done(done)
);
initial begin
    clk<=0;
    forever begin
        #10 clk=!clk;
    end
end
initial begin
    $monitor("time=%0t | P_input= %b | rst= %b | start= %b | load= %b | serial= %b | done=%b ",
    $time,P_input, rst, start, load , serial_out,done);
end 
initial begin
    rst=0;
    start = 0;
    load = 0;
    P_input = 0;
    #23 rst = 1;
    load = 1;
    P_input = 8'b01010101;
    #20 load=0;
    start=1;
    #160; //201ns
    load=1;
    P_input= 8'b10101010;
    #20 load=0;
    #160;
    load=1;
    P_input=8'b00000101;
    #20 load=0;
    #160 load=1;
    P_input=8'b10101010;
    #20 load=0;
    #100 rst=0;
    #20 rst =1;
    #100 ;
    $finish;
end
endmodule
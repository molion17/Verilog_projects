`timescale 1ns/ 1ps 
module UART_TX_tb;
    parameter N = 8;
    reg [N-1:0] P_input;
    reg  V_input,clk,rst,P_en,P_bit;
    wire TX_output,busy;
UART_TX #(.N(N)) dut(
    .P_input(P_input)
    ,.V_input(V_input)
    ,.clk(clk)
    ,.rst(rst)
    ,.P_en(P_en)
    ,.P_bit(P_bit)
    ,.TX_output(TX_output)
    ,.busy(busy)
);
initial begin
    clk<=0;
    forever begin
        #10 clk=!clk;
    end
end
initial begin
    $monitor("time=%0t | P_input= %b | V_in=%b | rst= %b | P_en= %b | P_bit= %b | Tx_out= %b | busy=%b",
    $time,P_input,V_input, rst,P_en, P_bit, TX_output,busy);
end 
initial
begin
    //reset
    rst=0;
    V_input=0;
    P_input=0;
    P_en=0;
    P_bit=0;

    #23 rst=1;
    //task1 without parity
    P_input = 8'b01010101;
    P_en=0;
    V_input=1;
    #10 V_input=0; // 33ns
    #220; // from 50 0101010101 to 230 checked
    #30; // 283ns tx must be 1
    //task2 with parity even
    P_en=1;
    V_input=1;
    #10; //293ns 
    V_input=0;
    #220; // from 310 01010101001 to 530 checked

    #10; // 543ns 
    //task3 with parity odd
    V_input=1;
    P_bit=1;
    #10 V_input=0; //553
    #240;// from 570 01010101011 to 790
    //task4 zeros with odd parity
    V_input=1;
    P_input=0;
    #20;//833ns
    V_input=0;
    #240;// 00000000011
    #20 V_input =1;
    P_input=8'b10000000;
    #20 V_input=0;
    // V=1 while transmit
    #120 V_input=1;
    P_input=8'b00000001;
    #80 V_input=0;
    #100;
    V_input=1;
    P_en=0;
    P_input=8'b10010101;
    #20 V_input=0;
    #220;
    V_input=1;
    P_input=8'b01011001;
    #20 V_input=0;
    #220;
    V_input=1;
    #20 V_input=0;
    #100 rst=0;
    #20 rst =1;
    #100;
    #20;
    $finish;
end
endmodule

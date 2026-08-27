module mux (serial_out,select,parity_out,TX_out);
    input parity_out,serial_out;
    input [1:0] select;
    output reg TX_out;
    localparam s0= 2'b00 ,s1=2'b01, s2=2'b10 , s3=2'b11;
    always @ (*)
    begin
        case(select)
        s0: TX_out=0;
        s1: TX_out=serial_out;
        s2: TX_out=parity_out;
        s3: TX_out=1'b1; 
        default: TX_out = 1'b1;
        endcase
   end
endmodule

module mux (serial_out,select,parity_out,TX_out);
    input logic parity_out,serial_out;
    input logic [1:0] select;
    output logic TX_out;
    localparam s0= 2'b00 ,s1=2'b01, s2=2'b10 , s3=2'b11;
    always_comb
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


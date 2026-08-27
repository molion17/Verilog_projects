module Serializer#(parameter N = 8) (P_input,clk,rst,start,load,serial_out,done);
    input [N-1:0] P_input;
    input clk,rst,start,load;
    output reg serial_out,done;
    reg [N-1:0] shift;
    reg [5:0] count; // if N changes for 16
    always @(posedge clk or negedge rst) 
    begin
    done <= 0 ;
    if(!rst)
        begin
            shift <= 0;
            serial_out <= 0;
            done <= 0;
            count <= 0;
        end    
    else if (load==1)
        begin
            shift <= P_input;
            count<=0;
        end
    else if (start)
        begin
            if(count < N)
            begin
               serial_out <= shift[0];
                shift <= {1'b0,shift[N-1:1]};
                count <= count+ 1'b1;
            end
            if(count==N-1)//
            begin
                count<=0;
                done <=1;
            end
        end
    end
endmodule

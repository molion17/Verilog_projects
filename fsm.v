module fsm (V_input,clk,rst,done,select,load,start,P_en,busy);
input V_input,clk,rst,done,P_en;
output reg [1:0] select;
output reg load,start,busy;
localparam s0= 2'b00 ,s1=2'b01, s2=2'b10 , s3=2'b11;
reg [1:0] perv;
always @(posedge clk or negedge rst)begin
    if(!rst)begin
        load<=0;
        start<=0;
        busy<=0;
        select<=s3;
        perv<=s3;
        end
    else
        begin
            load <=0;
            case (select)
                s0: begin   
                    select <= s1;
                    perv<=s0;
                    start <=1;
                    busy<=1;
                end
                s1: begin
                    if(done)
                    begin
                        start <=0;
                        if(P_en)
                        begin
                            select <= s2;
                            perv<=s1;
                        end
                        else
                        begin
                            select<=s3;
                            perv<=s1;
                        end 
                    end
                end
                s2: select<=s3;
                s3: begin
                    if(perv == s3)
                    begin
                    busy <=0;
                    end
                    if(V_input)
                    begin
                        load <=1;
                        select<=s0;
                        perv <= s3;
                    end 
                    else
                    begin
                        select<=s3;
                        perv<=s3;
                    end
                end 
            endcase
        end
end
endmodule

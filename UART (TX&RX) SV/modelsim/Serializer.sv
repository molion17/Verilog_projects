module Serializer #(parameter N = 8) (
    input  logic [N-1:0] P_input,
    input  logic clk, rst, start, load,
    output logic serial_out,
    output logic done
);
    logic [N-1:0] shift;
    logic [$clog2(N+1)-1:0] count;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            shift      <= 0;
            serial_out <= 0;
            count      <= 0;
        end
        else if (load) begin
            shift <= P_input;
            count <= 0;
        end
        else if (start && count != N) begin
            serial_out <= shift[0];
            shift      <= {1'b0, shift[N-1:1]};
            count      <= count + 1'b1;
        end
    end
    assign done = (count == N); 
endmodule


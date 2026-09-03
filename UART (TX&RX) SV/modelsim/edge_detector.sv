module edge_detector (
    input logic  clk,n_rst,A,
    output logic neg_edge_A ,pos_edge_A, edge_A
);
    logic delay;
    always_ff @( posedge clk or negedge n_rst ) begin 
        if (!n_rst) begin
            delay<=0;
        end
        else begin
            delay <= A;
        end
    end
    always_comb begin 
        pos_edge_A = A && !delay;
        neg_edge_A = !A && delay;
        edge_A = A ^ delay;  
    end
endmodule


module fifo #(
    parameter int unsigned width =8,
    parameter int unsigned depth = 8 
)(
    input i_clk,i_rst_n,wr_en,rd_en,
    input [width-1:0] i_data,
    output o_full,o_empty,
    output [width-1:0] o_data,
    output [$clog2(depth):0] o_count 
);
    logic wr_fire, rd_fire;
    logic [$clog2(depth)-1:0] wrt_ptr;
    logic [$clog2(depth)-1:0] rd_ptr;
    logic [$clog2(depth):0] count; 
    logic [width-1:0] mem [0:depth-1];

    assign wr_fire = wr_en && !o_full;
    assign rd_fire = rd_en && !o_empty;
   
    //--> write data <--
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            wrt_ptr <= 0;
        end
        else if (wr_fire) begin
            mem[wrt_ptr] <= i_data;
            wrt_ptr <= wrt_ptr + 1'b1;
        end
    end

//--> read data <--
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            rd_ptr <= 0;
        end
        else if (rd_fire) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

// --> count <--
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
                count <= 0;
            end
        else begin
            case ({wr_fire , rd_fire})
            2'b01 : count <= count - 1'b1;
            2'b10 : count <= count + 1'b1;
                default: count <= count;
            endcase
        end
    end

assign o_full = (count == depth);
assign o_empty = (count == 0);
assign o_count =  count ;
assign o_data = mem[rd_ptr];

endmodule
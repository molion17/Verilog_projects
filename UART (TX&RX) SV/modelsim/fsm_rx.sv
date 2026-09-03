module fsm_rx (
    input logic i_rx,i_clk,i_rst_n,i_par_n,done,
    output logic o_valid,o_busy,o_frame_err,shift_en,par_bit,cheak_par
);
    typedef enum  logic [1:0] { IDLE ,DATA,PARITY,STOP} state_u;
    state_u state , nextstate;
    
    logic start_check , pos_edge_A,edge_A,error_parity,valid;
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= IDLE;
        end
        else begin 
            state <= nextstate;
            o_frame_err <= error_parity;
            o_valid <= valid;
        end
    end
    
    edge_detector detect_start (
    .clk(i_clk)
    ,.n_rst(i_rst_n)
    ,.A(i_rx)
    ,.neg_edge_A(start_check) 
    ,.pos_edge_A(pos_edge_A)
    ,.edge_A(edge_A)
    );
    
    always_comb begin
	    o_busy= 0;
        shift_en=0;
        par_bit=0;
        cheak_par=0;
        error_parity=0;
        valid=0;
        nextstate = state;

        case (state)
            IDLE: begin
                if (start_check) begin
                    nextstate = DATA;
                    o_busy=1'b1;
                end
            end
            DATA: begin 
                o_busy=1'b1;
                shift_en=1'b1;
                if (done) begin
                    if (i_par_n) begin
                        nextstate = PARITY;
                    end
                    else begin
                        nextstate = STOP;
                         cheak_par = 1'b1;
                    end
                end
            end
            PARITY: begin 
                o_busy=1'b1;
                cheak_par=1'b1;
                par_bit=i_rx;
                nextstate =STOP;
            end
            STOP: begin
                nextstate = IDLE;
                valid=1'b1;
                if (!i_rx) begin
                    error_parity=1;
                end
            end 
            default: nextstate = IDLE; 
        endcase
    end
endmodule

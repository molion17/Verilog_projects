module fsm_rx (
    input logic i_clk,i_rst_n,i_par_n,done,i_bit_ready,i_bit_value,start_check,
    output logic o_valid,o_busy,o_frame_err,shift_en,par_bit,cheak_par,o_rx_sync
);
    typedef enum  logic [2:0] { IDLE,START,DATA,PARITY,STOP} state_u;
    state_u state , nextstate;
    
    logic  error_parity,valid;
    
    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state <= IDLE;
            o_frame_err <= 0;
            o_valid <= 0;
        end
        else  begin 
            state <= nextstate;
            o_frame_err <= error_parity;
            o_valid <= valid;
        end
    end

    always_comb begin
	    
        o_busy= 0;
        shift_en=0;
        par_bit=0;
        cheak_par=0;
        error_parity=0;
        valid=0;
        nextstate = state;
        o_rx_sync =0;
        
        case (state)
            IDLE: begin
                if (start_check) begin
                    o_rx_sync =1'b1;
                    nextstate = START;    
                end
            end
            START:begin
                o_busy=1'b1; 
                if (i_bit_ready) begin
                       if (i_bit_value == 0) begin
                        nextstate = DATA;
                       end
                        else   nextstate = IDLE;                    
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
                if (i_bit_ready)begin
                    par_bit = i_bit_value;
                    nextstate =STOP;
                end                   
            end
            STOP: begin
                o_busy = 1'b1;
                if (i_bit_ready) begin
                    valid=1'b1;
                    nextstate = IDLE;
                    if(!i_bit_value) error_parity=1;
                end
            end 
            default: nextstate = IDLE; 
        endcase
    end
endmodule

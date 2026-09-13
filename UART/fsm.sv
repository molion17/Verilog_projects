module fsm (
    input  logic i_valid, clk, rst, done, P_en,i_tx_en,
    output logic [1:0] select,
    output logic load, start, busy
);
    typedef enum logic [2:0] {IDLE, START, DATA, PARITY, STOP} state_t;
    state_t state, next_state;

    assign select = (state == START)  ? 2'b00 :
                    (state == DATA)   ? 2'b01 :
                    (state == PARITY) ? 2'b10 :
                                        2'b11;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) state <= IDLE;
        else  if (i_tx_en)   state <= next_state;
    end

    logic valid_pending;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            valid_pending <= 1'b0;
        end
        else if (i_valid && !busy) begin
            valid_pending <= 1'b1;               
        end
        else if (i_tx_en && state == IDLE) begin
            valid_pending <= 1'b0;              
        end
    end

    always_comb begin
        next_state = state;
        load  = 1'b0;
        start = 1'b0;
        busy  = valid_pending;

        case (state)
            IDLE: begin
                if (valid_pending) begin
                    next_state = START;
                    load = 1'b1;
                end
            end
            START: begin
                next_state = DATA;
                start = 1'b1;
                busy  = 1'b1;
            end
            DATA: begin
                start = 1'b1;  
                busy  = 1'b1;
                if (done)
                    next_state = P_en ? PARITY : STOP;
            end
            PARITY: begin
                busy = 1'b1;
                next_state = STOP;
            end
            STOP: begin
                busy = 1'b1;
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end
endmodule

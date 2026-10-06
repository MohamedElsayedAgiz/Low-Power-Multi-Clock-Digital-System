module FSM_TX (

    input            Data_Valid,PAR_EN,ser_done,
    input            RST,
    input            CLK,
    output reg       ser_en,busy,load,
    output reg [1:0] mux_sel
    
);

typedef enum logic [2:0] {
    IDLE  = 3'b000,
    START = 3'b001,
    DATA  = 3'b010,
    PAR   = 3'b011,
    STOP  = 3'b111
} state_t;

state_t current_state, next_state;

always @(posedge CLK or negedge RST) begin
    
    if(!RST)
    current_state <= IDLE;
    else 
    current_state <= next_state;

end

always @(*) begin

    load = 1'b0;

   case (current_state)
    
    IDLE: begin
    busy    = 1'b0;
    ser_en  = 1'b0;
    mux_sel = 2'b01;
    load    = 1'b0;

    if (Data_Valid) begin
        load       = 1'b1;
        next_state = START;
    end
    else begin
        next_state = IDLE;
    end

    end

    START : begin
        busy    = 1'b1;
        ser_en  = 1'b0;
        mux_sel = 2'b00;
        next_state = DATA;
    end

    DATA: begin
    busy    = 1'b1;
    mux_sel = 2'b10;
    if (ser_done) begin
        ser_en = 1'b0;

        if (PAR_EN)
            next_state = PAR;
        else
            next_state = STOP;
    end
    else begin
        ser_en = 1'b1;
        next_state = DATA;
    end
    end

    PAR : begin
        busy    = 1'b1;
        ser_en  = 1'b0;
        mux_sel = 2'b11;
        next_state = STOP;
    end
    
    STOP : begin
        busy    = 1'b1;
        ser_en  = 1'b0;
        mux_sel = 2'b01;
        next_state = IDLE;
    end 

    default : begin
        busy    = 1'b0;
        ser_en  = 1'b0;
        mux_sel = 2'b01;
        next_state = IDLE;
        load = 1'b0;
    end
   endcase
end

endmodule
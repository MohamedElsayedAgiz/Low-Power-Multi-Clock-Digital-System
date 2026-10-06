module FSM_RX (

    input      [3:0] bit_cnt,
    input      [5:0] edge_cnt,Prescale,     
    input            RX_IN,PAR_EN,stp_err,strt_glitch,par_err,
    input            RST,
    input            CLK,
    output reg [1:0] frame_valid,  
    output reg       enable,dat_samp_en,data_valid,par_chk_en,strt_chk_en,stp_chk_en,State,new_frame

);

typedef enum logic [2:0] {
    IDLE  = 3'b000,
    START = 3'b001,
    DATA  = 3'b010,
    PAR   = 3'b011,
    STOP  = 3'b111,
    CHECK = 3'b110
} state_t;

state_t current_state, next_state;

always @(posedge CLK or negedge RST) begin

    if(!RST)
    current_state <= IDLE;
    else 
    current_state <= next_state;

end

always @(*) begin

    enable       = 1'b0;
    dat_samp_en  = 1'b0;
    par_chk_en   = 1'b0;
    strt_chk_en  = 1'b0;
    stp_chk_en   = 1'b0;
    State        = 1'b0;
    new_frame    = 1'b0;

    case (current_state)
    
    IDLE : begin
        if (!RX_IN) begin
            next_state = START;
            new_frame  = 1'b1;
            State      = 1'b1;
            enable     = 1'b1;
        end
        else begin
            next_state = IDLE;
        end
    end

    START : begin
        dat_samp_en = 1'b1;
        enable      = 1'b1;
        strt_chk_en = 1'b1;
        if (edge_cnt == Prescale) begin
            if (!strt_glitch) begin
                next_state = DATA;
            end
            else begin
                next_state = IDLE;
            end
        end
        else begin
            next_state = START;
        end
    end

    DATA : begin
        dat_samp_en = 1'b1;
        enable      = 1'b1;
        if (PAR_EN) begin
            if (edge_cnt == Prescale && bit_cnt == 4'd8) begin
                next_state = PAR;
            end
            else begin
                next_state = DATA;
            end
        end
        else begin
            if (edge_cnt == Prescale && bit_cnt == 4'd8) begin
                next_state = STOP;
            end
            else begin
                next_state = DATA;
            end
        end
    end

    PAR : begin
        enable      = 1'b1;
        dat_samp_en = 1'b1;
        par_chk_en  = 1'b1;
        if(edge_cnt == Prescale ) begin
            next_state = STOP;
        end
        else begin
            next_state = PAR;
        end
    end

    STOP : begin
        enable      = 1'b1;
        dat_samp_en = 1'b1;
        stp_chk_en  = 1'b1;
        if(edge_cnt == Prescale ) begin
            next_state = CHECK;
        end
        else begin
            next_state = STOP;
        end
    end

    CHECK : begin
    if (stp_err) begin
        if (RX_IN) begin
            next_state = IDLE;
        end
        else begin
            next_state = CHECK;
        end
    end
    else begin
        if (RX_IN) begin
            next_state = IDLE;
        end
        else begin
            next_state = START;
            State      = 1'b1;
            enable     = 1'b1;
            new_frame  = 1'b1;
        end
    end
    end

    default : begin
        next_state = IDLE;
    end

endcase
    
end

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        frame_valid <= 2'b00;
        data_valid  <= 1'b0;
    end
    else begin
        if (new_frame) begin
            frame_valid <= 2'b00;
        end
        else if (PAR_EN && current_state == PAR  && edge_cnt == Prescale && !par_err) begin
            frame_valid <= frame_valid + 1'b1;
        end 
        else if (!PAR_EN && current_state == DATA && edge_cnt == Prescale && bit_cnt == 4'd8) begin
            frame_valid <= frame_valid + 1'b1;
        end
        else if (current_state == STOP && edge_cnt == Prescale && !stp_err) begin
            frame_valid <= frame_valid + 1'b1;
        end
        if (current_state == CHECK && frame_valid == 2'd2) begin
            data_valid <= 1'b1;
        end
        else begin
            data_valid <= 1'b0;
        end
    end
end

endmodule
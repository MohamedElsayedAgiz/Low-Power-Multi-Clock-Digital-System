module deserializer (

    input              sampled_pit,new_frame,
    input       [5:0]  edge_cnt,
    input       [3:0]  bit_cnt,
    input       [5:0]  Prescale,
    input       [1:0]  frame_valid,
    input              RST,
    input              CLK,
    output reg  [7:0]  P_DATA,Q
 
);


always @(posedge CLK or negedge RST) begin
    
    if (!RST) begin
        P_DATA  <= 8'b0;
        Q       <= 8'b0;
    end
    else begin
        if (new_frame) begin
            Q <= 8'b0;
        end
        else if (bit_cnt >= 4'd1 && bit_cnt <= 4'd8) begin
            if (edge_cnt == Prescale - 1) begin
                Q <= {sampled_pit, Q[7:1]};
            end
        end
        if(frame_valid == 2'd2) begin
                P_DATA <= Q;
        end
    end
end


endmodule
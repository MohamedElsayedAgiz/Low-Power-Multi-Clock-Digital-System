module Stop_C (

    input              new_frame,stp_chk_en,sampled_pit,
    input       [5:0]  edge_cnt,
    input       [5:0]  Prescale,
    input              RST,
    input              CLK,
    output reg         stp_err

);

always @(posedge CLK or negedge RST) begin

    if (!RST) begin
        stp_err <= 1'b0;
    end
    else begin
        if (new_frame) begin
            stp_err <= 1'b0;
        end
        else if (stp_chk_en && edge_cnt == Prescale - 1) begin
            if (sampled_pit == 1'b1)
                stp_err <= 1'b0;
            else
                stp_err <= 1'b1;
        end
    end
end


endmodule
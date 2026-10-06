module P_C(

    input      [7:0]  P_DATA,
    input      [5:0]  edge_cnt,
    input      [5:0]  Prescale,
    input             PAR_TYP,par_chk_en,sampled_pit,new_frame,
    input             RST,
    input             CLK,
    output reg        par_err

);

always @(posedge CLK or negedge RST) begin

    if (!RST) begin
        par_err <= 1'b0;
    end
    else begin
        if (new_frame) begin
            par_err <= 1'b0;
        end
        else if (par_chk_en && edge_cnt == Prescale - 1) begin
            if (!PAR_TYP) begin
                if ((^P_DATA) == sampled_pit)
                    par_err <= 1'b0;
                else
                    par_err <= 1'b1;
            end
            else begin
                if ((~(^P_DATA)) == sampled_pit)
                    par_err <= 1'b0;
                else
                    par_err <= 1'b1;
            end
        end
    end
    
end

endmodule
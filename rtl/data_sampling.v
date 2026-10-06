module data_sampling (

    input           dat_samp_en,
    input    [5:0]  Prescale,edge_cnt,
    input           RX_IN,
    input           RST,
    input           CLK,
    output reg      sampled_pit  

);

reg S1,S2,S3;
reg samples_done;

always @(posedge CLK or negedge RST) begin
    
    if(!RST) begin
        sampled_pit <= 1'b0;
        S1 <= 1'b0;
        S2 <= 1'b0;
        S3 <= 1'b0;
        samples_done <= 1'b0;
    end
    else begin
        if (!dat_samp_en) begin
            sampled_pit <= 1'b0;
            S1 <= 1'b0;
            S2 <= 1'b0;
            S3 <= 1'b0;
            samples_done <= 1'b0;
        end
        else begin
            if (samples_done == 1'b1) begin
                samples_done <= 1'b0;
                if (S1 == S2) begin
                    sampled_pit <= S1;
                end
                else if (S1 == S3) begin
                    sampled_pit <= S1;
                end
                else if (S2 == S3) begin
                    sampled_pit <= S2;
                end
            end
            else if (edge_cnt == Prescale/2 - 1) begin
                S1 <= RX_IN;
            end
            else if (edge_cnt == Prescale/2) begin
                S2 <= RX_IN;
            end
            else if (edge_cnt == Prescale/2 + 1) begin
                S3 <= RX_IN;
                samples_done <= 1'b1;
            end
        end
    end
end

endmodule
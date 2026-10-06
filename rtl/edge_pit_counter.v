module edge_pit_counter (

    input              enable,
    input       [5:0]  Prescale,
    input              PAR_EN,
    input              State,
    input              RST,
    input              CLK,
    output reg  [3:0]  bit_cnt,
    output reg  [5:0]  edge_cnt

);

always @(posedge CLK or negedge RST) begin

    if (!RST) begin
        edge_cnt <= 6'd1;
        bit_cnt  <= 4'd0;
    end
    else begin
        if (!enable) begin
            edge_cnt <= 6'd1;
            bit_cnt  <= 4'd0;
        end
        else begin
            if (State) begin
                edge_cnt <= 6'd2;
                bit_cnt  <= 4'd0;
            end
            else if (edge_cnt == Prescale) begin
                edge_cnt <= 6'd1;
                if (PAR_EN) begin
                    if (bit_cnt == 4'd10)
                        bit_cnt <= 4'd0;
                    else
                        bit_cnt <= bit_cnt + 1;
                end
                else begin
                    if (bit_cnt == 4'd9)
                        bit_cnt <= 4'd0;
                    else
                        bit_cnt <= bit_cnt + 1;
                end
            end
            else begin
                edge_cnt <= edge_cnt + 1;
            end
        end
    end

end

endmodule
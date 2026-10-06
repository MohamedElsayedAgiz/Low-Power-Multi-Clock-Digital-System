module Sync_w2r #(parameter addr = 3) (
    
    input      [addr:0]   wptr,
    input                 r_clk,
    input                 r_rst,
    output reg [addr:0]   rq2_wptr

);

reg [addr:0] FF;

always @(posedge r_clk or negedge r_rst) begin
    
    if (!r_rst) begin
        FF       <= 'd0;
        rq2_wptr <= 'd0;
    end
    else begin
        FF       <= wptr;
        rq2_wptr <= FF;
    end

end
    
endmodule
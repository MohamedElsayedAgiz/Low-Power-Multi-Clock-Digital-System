module Sync_r2w #(parameter addr = 3) (
    
    input      [addr:0]   rptr,
    input                 w_clk,
    input                 w_rst,
    output reg [addr:0]   wq2_rptr

);

reg [addr:0] FF;

always @(posedge w_clk or negedge w_rst) begin
    
    if (!w_rst) begin
        FF       <= 'd0;
        wq2_rptr <= 'd0;
    end
    else begin
        FF       <= rptr;
        wq2_rptr <= FF;
    end

end
    
endmodule
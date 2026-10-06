module RST_SYN #(parameter NUM_STAGES = 2) (
    
    input      RST,
    input      CLK,
    output     SYNC_RST

);

reg [NUM_STAGES-1:0]   FF;

always @(posedge CLK or negedge RST) begin
    
    if (!RST) begin
        FF       <= 'd0;
    end
    else begin
        FF <= {1'b1 , FF[NUM_STAGES-1:1]};
    end

end

assign SYNC_RST = FF[0];
    
endmodule
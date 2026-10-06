module PULSE_GEN (
    
    input     busy,
    input     CLK,
    input     RST,
    output    rinc

);
    
reg         F_F;
reg         P_F_F;

always @(posedge CLK or negedge RST) begin
    
    if (!RST) begin
        F_F   <= 1'b0;
        P_F_F <= 1'b0;
    end
    else begin
        F_F   <= busy;
        P_F_F <= F_F;
    end

end 

assign rinc = F_F & (!P_F_F);

endmodule
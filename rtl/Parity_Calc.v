module Parity_Calc (

    input [7:0]  P_DATA,
    input        load,PAR_TYP,
    input        RST,
    input        CLK,
    output reg   par_bit

);

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        par_bit <= 1'b0;
    end
    else if (load) begin
    
        if (!PAR_TYP) begin
            par_bit <= ^(P_DATA);
        end
        else begin
            par_bit <= ~(^P_DATA);
        end

    end
end

endmodule
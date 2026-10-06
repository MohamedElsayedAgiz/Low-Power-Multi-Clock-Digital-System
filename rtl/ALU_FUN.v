module A_F #( parameter OPER_WIDTH = 8,
                        OUT_WIDTH = OPER_WIDTH*2
)
(
input       [OPER_WIDTH-1:0] a,b,
input       [3:0]            ALU_FUN,
input                        EN,
input                        CLK,
input                        RST,
output reg  [OUT_WIDTH-1:0]  ALU_OUT,
output reg                   OUT_VALID
);

always @(posedge CLK or negedge RST)

if (!RST) begin
    ALU_OUT   <= 'd0;
    OUT_VALID <= 'd0;
end
else if (EN) begin
  
  OUT_VALID <= 1'b1;
  case(ALU_FUN)

    4'b0000:
    begin
        ALU_OUT <= a + b;
    end

    4'b0001:
    begin
        ALU_OUT <= a - b;
    end

    4'b0010:
    begin
        ALU_OUT <= a * b;
    end

    4'b0011:
    begin
        if (b != 'd0)
            ALU_OUT <= a / b;
        else
            ALU_OUT <= 'd0;
    end

    4'b0100:
    begin
        ALU_OUT <= a & b;
    end

    4'b0101:
    begin
        ALU_OUT <= a | b;
    end

    4'b0110:
    begin
        ALU_OUT <= ~(a & b);
    end

    4'b0111:
    begin
        ALU_OUT <= ~(a | b);
    end

    4'b1000:
    begin
        ALU_OUT <= a ^ b;
    end

    4'b1001:
    begin
        ALU_OUT <= ~(a ^ b);
    end

    4'b1010:
    begin
        ALU_OUT <= (a == b) ? 'd1 : 'd0;
    end

    4'b1011:
    begin
        ALU_OUT <= (a > b) ? 'd2 : 'd0;
    end
    
    4'b1100:
    begin
        ALU_OUT <= (a < b) ? 'd3 : 'd0;
    end

    4'b1101:
    begin
        ALU_OUT <= a >> 1;
    end

    4'b1110:
    begin
        ALU_OUT <= a << 1;
    end

    default:
    begin
        ALU_OUT <= 'd0;
    end

endcase 
end
else begin
    ALU_OUT   <= 'd0;
    OUT_VALID <= 'd0;
end
endmodule

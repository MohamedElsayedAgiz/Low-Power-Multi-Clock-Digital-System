module FIFO_RD #(parameter addr = 3) (
    
    input                   rinc,
    input      [addr:0]     rq2_wptr,
    input                   r_rst,
    input                   r_clk,
    output reg              rempty,
    output reg [addr:0]     rptr,
    output     [addr-1:0]   r_addr

);

reg  [addr:0] rbinary;
wire [addr:0] rptr_after_read;


function [3:0] binary_to_gray;

    input [3:0] binary;

    begin

        case (binary)

            4'b0000: binary_to_gray = 4'b0000;
            4'b0001: binary_to_gray = 4'b0001;
            4'b0010: binary_to_gray = 4'b0011;
            4'b0011: binary_to_gray = 4'b0010;
            4'b0100: binary_to_gray = 4'b0110;
            4'b0101: binary_to_gray = 4'b0111;
            4'b0110: binary_to_gray = 4'b0101;
            4'b0111: binary_to_gray = 4'b0100;

            4'b1000: binary_to_gray = 4'b1100;
            4'b1001: binary_to_gray = 4'b1101;
            4'b1010: binary_to_gray = 4'b1111;
            4'b1011: binary_to_gray = 4'b1110;
            4'b1100: binary_to_gray = 4'b1010;
            4'b1101: binary_to_gray = 4'b1011;
            4'b1110: binary_to_gray = 4'b1001;
            4'b1111: binary_to_gray = 4'b1000;

            default: binary_to_gray = 4'b0000;

        endcase

    end

endfunction


assign r_addr = rbinary[addr-1:0];

assign rptr_after_read =
       binary_to_gray(
           rbinary + ((rinc && !rempty) ? 1'b1 : 1'b0)
       );


always @(posedge r_clk or negedge r_rst) begin
    
    if (!r_rst) begin

        rbinary <= 'd0;
        rempty  <= 1'b1;
        rptr    <= 'd0;

    end

    else begin

        if (rinc && !rempty) begin
            rbinary <= rbinary + 1'b1;
        end

        rptr <= rptr_after_read;


        if (rptr_after_read == rq2_wptr) begin

            rempty <= 1'b1;

        end

        else begin

            rempty <= 1'b0;

        end

    end

end


endmodule
module FIFO_WR #(parameter addr = 3) (
    
    input                   winc,
    input      [addr:0]     wq2_rptr,
    input                   w_rst,
    input                   w_clk,
    output                  w_clken,
    output reg              wfull,
    output reg [addr:0]     wptr,
    output     [addr-1:0]   w_addr

);

reg  [addr:0] wbinary;
wire [addr:0] wptr_after_write;


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


assign w_addr = wbinary[addr-1:0];

assign w_clken = winc & !wfull;

assign wptr_after_write =
       binary_to_gray(
           wbinary + (w_clken ? 1'b1 : 1'b0)
       );


always @(posedge w_clk or negedge w_rst) begin
    
    if (!w_rst) begin

        wfull   <= 'd0;
        wbinary <= 'd0;
        wptr    <= 'd0;

    end

    else begin

        if (w_clken) begin
            wbinary <= wbinary + 1'b1;
        end

        wptr <= wptr_after_write;


        if (wptr_after_write[addr] != wq2_rptr[addr] &&
            wptr_after_write[addr-1] != wq2_rptr[addr-1] &&
            wptr_after_write[addr-2:0] == wq2_rptr[addr-2:0]) begin

            wfull <= 1'b1;

        end

        else begin

            wfull <= 1'b0;

        end

    end

end


endmodule
module CLKDIV_MUX #(parameter Prescale_WIDTH = 6 , CLKDIV_WIDTH = 3) 
(
    
    input       [Prescale_WIDTH-1:0]  Prescale,
    output reg  [CLKDIV_WIDTH-1:0]    CLKDIV_MUX_OUT

);

always @(*) begin
    
    case (Prescale)

        6'd32  : CLKDIV_MUX_OUT = 1;
        6'd16  : CLKDIV_MUX_OUT = 2;
        6'd8   : CLKDIV_MUX_OUT = 4;
        default: CLKDIV_MUX_OUT = 1;

    endcase

end
    
endmodule
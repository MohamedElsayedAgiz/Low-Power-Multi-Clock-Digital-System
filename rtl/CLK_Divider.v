module ClkDiv #(parameter DIV_RATIO_WIDTH = 8) 
(

    input                             I_ref_clk,
    input      [DIV_RATIO_WIDTH-1:0]  I_div_ratio,
    input                             I_rst_n,
    input                             I_clk_en,
    output reg                        o_div_clk

);

reg  [DIV_RATIO_WIDTH-1:0]  counter;
wire [DIV_RATIO_WIDTH-1:0]  half;
reg  [DIV_RATIO_WIDTH-1:0]  last_div_ratio;
assign                      half = I_div_ratio >> 1;
reg                         div_clk;
wire                        Disable;
    
always @(posedge I_ref_clk or negedge I_rst_n) begin

    if(!I_rst_n) begin
        div_clk        <= 0;
        counter        <= 1;
        last_div_ratio <= 0;
    end

    else if (Disable) begin
        counter        <= 1;
        div_clk        <= 0;
        last_div_ratio <= I_div_ratio;
    end

    else if (I_div_ratio != last_div_ratio) begin
        counter        <= 1;
        div_clk        <= 0;
        last_div_ratio <= I_div_ratio;
    end

    else if (I_div_ratio[0] == 0) begin

        if (counter == half) begin
            counter <= 1;
            div_clk <= !div_clk;
        end
        else begin
            counter <= counter + 1;
        end

    end

    else begin

        if (counter == half) begin
            div_clk <= !div_clk;
            counter <= counter + 1;
        end
        else if (counter == I_div_ratio) begin
            counter <= 1;
            div_clk <= !div_clk;
        end
        else begin
            counter <= counter + 1;
        end

    end

end

assign Disable = (!I_clk_en) || (I_div_ratio == 'd0) || (I_div_ratio == 'd1);

always @(*) begin

    
    if (!I_clk_en || I_div_ratio == 'd0 || I_div_ratio == 'd1) begin
        o_div_clk = I_ref_clk;
    end
    else begin
        o_div_clk = div_clk;
    end

end

endmodule

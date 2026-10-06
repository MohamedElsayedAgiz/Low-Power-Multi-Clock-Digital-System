module FIFO_Memory #(parameter DATA_WIDTH = 8, DEPTH = 8, ADDR_SIZE = 3) (
    
    input      [DATA_WIDTH-1:0]   w_data,
    input      [ADDR_SIZE-1 :0]   w_addr,r_addr,
    input                         w_clken,
    input                         w_clk,
    input                         w_rstn,
    output reg [DATA_WIDTH-1:0]   r_data

);

reg [DATA_WIDTH-1:0] MEM [DEPTH-1:0];
integer i;

always @(posedge w_clk or negedge w_rstn) begin

    if(!w_rstn) begin 
        for(i = 0 ; i < DEPTH ; i = i + 1) 
            MEM[i] <= 'b0;
    end
    else if (w_clken) begin
        MEM[w_addr] <= w_data;
    end

end

always @(*) begin
    
    r_data = MEM[r_addr];

end
    
endmodule
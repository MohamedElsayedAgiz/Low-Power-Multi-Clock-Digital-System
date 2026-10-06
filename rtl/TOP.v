module FIFO_TOP #(parameter DATA_WIDTH = 8, addr = 3) (
    
    input                    w_inc,
    input                    r_inc,
    input   [DATA_WIDTH-1:0] wr_data,
    input                    w_rst,
    input                    r_rst,
    input                    w_clk,
    input                    r_clk,
    output                   full,
    output                   empty,
    output  [DATA_WIDTH-1:0] rd_data

);

wire [addr-1:0] w_addr,r_addr;
wire [addr:0]   w_ptr,r_ptr;
wire [addr:0]   rq2_wptr,wq2_rptr;
wire            w_clken;

FIFO_Memory F_M (

    .w_data   (wr_data),
    .w_addr   (w_addr),
    .r_addr   (r_addr),
    .w_rstn   (w_rst),
    .w_clken  (w_clken),
    .w_clk    (w_clk),
    .r_data   (rd_data)

);

Sync_w2r S_w2r (

    .wptr     (w_ptr),
    .r_clk    (r_clk),
    .r_rst    (r_rst),
    .rq2_wptr (rq2_wptr)

);

Sync_r2w S_r2w (

    .rptr     (r_ptr),
    .w_clk    (w_clk),
    .w_rst    (w_rst),
    .wq2_rptr (wq2_rptr)

);

FIFO_RD F_R (

    .rinc     (r_inc),
    .rq2_wptr (rq2_wptr),
    .r_rst    (r_rst),
    .r_clk    (r_clk),
    .rempty   (empty),
    .rptr     (r_ptr),
    .r_addr   (r_addr)

);

FIFO_WR F_W (
    
    .winc     (w_inc),
    .wq2_rptr (wq2_rptr),
    .w_rst    (w_rst),
    .w_clk    (w_clk),
    .w_clken  (w_clken),
    .wfull    (full),
    .wptr     (w_ptr),
    .w_addr   (w_addr)

);
    
endmodule
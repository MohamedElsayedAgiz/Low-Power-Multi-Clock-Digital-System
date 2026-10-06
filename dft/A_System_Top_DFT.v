module SYS_TOP  # ( parameter DATA_WIDTH = 8 ,  RF_ADDR = 4 , ALU_FUN_WIDTH = 4 , CLKDIV_WIDTH = 3 , NUM_OF_CHAINS = 4) 
(

    input                      scan_clk,
    input                      scan_rst,
    input                      test_mode,
    input                      SE,
    input  [NUM_OF_CHAINS-1:0] SI,
    output [NUM_OF_CHAINS-1:0] SO,

    input                      UART_RX_IN,
    input                      UART_CLK,
    input                      REF_CLK,
    input                      RST_N,

    output                     UART_TX_O,
    output                     parity_error,
    output                     framing_error

);

parameter RX_DIV_WIDTH = 3;
parameter TX_DIV_WIDTH = 8;

wire                     UART_TX_O_V;
wire                     SYNC_UART_RST,SYNC_SYS_RST;
wire                     UART_TX_CLK;
wire                     UART_RX_CLK;
wire [DATA_WIDTH-1:0]    UART_RX_OUT_P;
wire                     UART_RX_OUT_V; 
wire                     UART_TX_IN_V;
wire [DATA_WIDTH-1:0]    UART_Config;
wire [DATA_WIDTH*2-1:0]  ALU_OUT; 
wire                     ALU_OUT_Valid;
wire [DATA_WIDTH-1:0]    RdData;
wire                     RdData_Valid;
wire [DATA_WIDTH-1:0]    RX_P_DATA_Sync;
wire                     RX_D_VLD_Sync;
wire [ALU_FUN_WIDTH-1:0] ALU_FUN;
wire                     ALU_EN;
wire                     ALU_CLK_EN;
wire [RF_ADDR-1:0]       Address;
wire                     WrEn;
wire                     RdEn;
wire [DATA_WIDTH-1:0]    WrData;
wire [DATA_WIDTH-1:0]    TX_P_DATA_FIFO;
wire                     TX_D_VLD_FIFO;
wire                     clk_div_en;
wire [DATA_WIDTH-1:0]    Operand_A;
wire [DATA_WIDTH-1:0]    Operand_B;
wire [DATA_WIDTH-1:0]    Div_Ratio;
wire [CLKDIV_WIDTH-1:0]  CLKDIV_MUX_OUT;
wire                     GATED_CLK;
wire                     FIFO_FULL;
wire [DATA_WIDTH-1:0]    UART_TX_IN_Sync;
wire                     r_inc_Sync;
wire                     FIFO_EMPTY;

wire SYS_DFT_CLK;
wire UART_DFT_CLK;
wire RX_DFT_CLK;
wire TX_DFT_CLK;

assign SYS_DFT_CLK  = test_mode ? scan_clk : REF_CLK;
assign UART_DFT_CLK = test_mode ? scan_clk : UART_CLK;
assign RX_DFT_CLK   = test_mode ? scan_clk : UART_RX_CLK;
assign TX_DFT_CLK   = test_mode ? scan_clk : UART_TX_CLK;

wire DFT_RST;
wire SYS_DFT_RST;
wire UART_DFT_RST;

assign DFT_RST = test_mode ? scan_rst : RST_N;
assign SYS_DFT_RST = test_mode ? scan_rst : SYNC_SYS_RST;
assign UART_DFT_RST = test_mode ? scan_rst : SYNC_UART_RST;

wire   ALU_CLK_EN_TEST;

assign ALU_CLK_EN_TEST = ALU_CLK_EN | test_mode;


RST_SYN U0_SYS_RST(
.RST     (DFT_RST),
.CLK     (SYS_DFT_CLK),
.SYNC_RST(SYNC_SYS_RST)
);

RST_SYN U0_UART_RST(
.RST     (DFT_RST),
.CLK     (UART_DFT_CLK),
.SYNC_RST(SYNC_UART_RST)
);


CLKDIV_MUX #(
.CLKDIV_WIDTH(RX_DIV_WIDTH)
) U0_CLKDIV_MUX (
.Prescale      (UART_Config[7:2]),
.CLKDIV_MUX_OUT(CLKDIV_MUX_OUT)    
);

ClkDiv #(
.DIV_RATIO_WIDTH(RX_DIV_WIDTH)
) UO_RX_ClkDiv (
.I_ref_clk  (UART_DFT_CLK),
.I_div_ratio(CLKDIV_MUX_OUT),
.I_rst_n    (UART_DFT_RST),
.I_clk_en   (clk_div_en),
.o_div_clk  (UART_RX_CLK)
);

ClkDiv #(
.DIV_RATIO_WIDTH(TX_DIV_WIDTH)
) UO_TX_ClkDiv (
.I_ref_clk  (UART_DFT_CLK),
.I_div_ratio(Div_Ratio),
.I_rst_n    (UART_DFT_RST),
.I_clk_en   (clk_div_en),
.o_div_clk  (UART_TX_CLK)
);

CLK_GATE UO_CLK_GATE(
.CLK_EN   (ALU_CLK_EN_TEST),    
.CLK      (SYS_DFT_CLK),    
.GATED_CLK(GATED_CLK)    
);

Data_Synchronizer U_0_Data_Synchronizer (
.Unsync_bus  (UART_RX_OUT_P),
.bus_enable  (UART_RX_OUT_V),
.CLK         (SYS_DFT_CLK),
.RST         (SYS_DFT_RST),
.Sync_bus    (RX_P_DATA_Sync),
.enable_bulse(RX_D_VLD_Sync)
);

PULSE_GEN U0_PULSE_GEN (
.busy(UART_TX_O_V),
.CLK (TX_DFT_CLK),
.RST (UART_DFT_RST),
.rinc(r_inc_Sync)
);

FIFO_TOP U0_FIFO_TOP (
.w_inc  (TX_D_VLD_FIFO),
.r_inc  (r_inc_Sync),
.wr_data(TX_P_DATA_FIFO),
.w_rst  (SYS_DFT_RST),
.r_rst  (UART_DFT_RST),
.w_clk  (SYS_DFT_CLK),
.r_clk  (TX_DFT_CLK),
.full   (FIFO_FULL), 
.empty  (FIFO_EMPTY),
.rd_data(UART_TX_IN_Sync)
);

A_F U0_A_F (
.a        (Operand_A),
.b        (Operand_B),
.ALU_FUN  (ALU_FUN),
.EN       (ALU_EN),
.CLK      (GATED_CLK),
.RST      (SYS_DFT_RST),
.ALU_OUT  (ALU_OUT),
.OUT_VALID(ALU_OUT_Valid)
);

UART UO_UART (
.RST          (UART_DFT_RST),
.TX_CLK       (TX_DFT_CLK),
.RX_CLK       (RX_DFT_CLK),
.RX_IN_S      (UART_RX_IN),
.RX_OUT_P     (UART_RX_OUT_P),
.RX_OUT_V     (UART_RX_OUT_V),
.TX_IN_P      (UART_TX_IN_Sync),
.TX_IN_V      (!FIFO_EMPTY),
.TX_OUT_S     (UART_TX_O),
.TX_OUT_V     (UART_TX_O_V),  //Busy
.Prescale     (UART_Config[7:2]),
.parity_enable(UART_Config[0]),
.parity_type  (UART_Config[1]),
.parity_error (parity_error),
.framing_error(framing_error)
);

SYS_CTRL U0_SYS_CTRL (
.CLK         (SYS_DFT_CLK),
.RST         (SYS_DFT_RST),
.ALU_OUT     (ALU_OUT),
.OUT_Valid   (ALU_OUT_Valid),
.RdData      (RdData),
.RdData_Valid(RdData_Valid),
.RX_P_DATA   (RX_P_DATA_Sync),
.RX_D_VLD    (RX_D_VLD_Sync),
.ALU_FUN     (ALU_FUN),
.EN          (ALU_EN),
.CLK_EN      (ALU_CLK_EN),
.Address     (Address),
.WrEn        (WrEn),
.RdEn        (RdEn),
.WrData      (WrData),
.TX_P_DATA   (TX_P_DATA_FIFO),
.TX_D_VLD    (TX_D_VLD_FIFO),
.clk_div_en  (clk_div_en),
.FIFO_FULL   (FIFO_FULL)
);
    
Memory U0_Memory(
.WrData    (WrData),
.Address   (Address),
.WrEn      (WrEn),
.RdEn      (RdEn),
.RST       (SYS_DFT_RST),
.CLK       (SYS_DFT_CLK),
.RdData    (RdData),
.RdData_VLD(RdData_Valid),
.REG0      (Operand_A),
.REG1      (Operand_B),
.REG2      (UART_Config),
.REG3      (Div_Ratio)
);


endmodule

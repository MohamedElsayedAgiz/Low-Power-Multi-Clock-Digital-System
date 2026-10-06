module SYS_CTRL #(parameter ALU_OUT_WIDTH = 16 , DATA_WIDTH = 8 , ALU_FUN_WIDTH = 4 ,
ADDR_WIDTH = 4 )
(
    
    input                           CLK,
    input                           RST,
    input      [ALU_OUT_WIDTH-1:0]  ALU_OUT,
    input                           OUT_Valid,
    input      [DATA_WIDTH-1:0]     RdData,
    input                           RdData_Valid,
    input      [DATA_WIDTH-1:0]     RX_P_DATA,
    input                           RX_D_VLD,
    input                           FIFO_FULL,
    output reg [ALU_FUN_WIDTH-1:0]  ALU_FUN,
    output reg                      EN,
    output reg                      CLK_EN,
    output reg [ADDR_WIDTH-1:0]     Address,
    output reg                      WrEn,
    output reg                      RdEn,
    output reg [DATA_WIDTH-1:0]     WrData,
    output reg [DATA_WIDTH-1:0]     TX_P_DATA,
    output reg                      TX_D_VLD,
    output reg                      clk_div_en

);


typedef enum logic [3:0] {
            IDLE            = 4'b0000,
            WRITE_ADDR      = 4'b0001,
            WRITE_DATA      = 4'b0011,
            READ_ADDR       = 4'b0010,
            READ_DATA       = 4'b0110,
            OPRAND_A        = 4'b0111,
            OPRAND_B        = 4'b0101,
            ALU_FUN_S       = 4'b0100,
            Send_Result     = 4'b1100,
            Send_Result_LSB = 4'b1101
} state_t;

state_t current_state , next_state;
reg [ADDR_WIDTH-1:0] Write_Address_reg;

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        current_state <= IDLE;
        Write_Address_reg   <= 'b0;
    end
    else begin
        current_state <= next_state;
        if (current_state == WRITE_ADDR && RX_D_VLD && RX_P_DATA >= 8'd2 && RX_P_DATA <= 8'd15) begin
            Write_Address_reg <= RX_P_DATA[ADDR_WIDTH-1:0];
        end
    end
end

always @(*) begin

    ALU_FUN    = 'b1111;
    EN         = 'b0;
    CLK_EN     = 'b0;
    Address    = Write_Address_reg;
    WrEn       = 'b0;
    RdEn       = 'b0;
    WrData     = 'b0;
    TX_P_DATA  = 'b0;
    TX_D_VLD   = 'b0;
    clk_div_en = 'b1;

    case (current_state)

        IDLE : begin
            if (RX_D_VLD) begin
            case (RX_P_DATA)
                'hAA : begin 
                    next_state = WRITE_ADDR;
                end
                'hBB : begin
                    next_state = READ_ADDR;
                end
                'hCC : begin
                    next_state = OPRAND_A;
                end
                'hDD : begin 
                    next_state = ALU_FUN_S;
                end
                default: begin
                    next_state = IDLE;
                end
            endcase
            end
            else begin
                next_state = IDLE;
            end
        end

        WRITE_ADDR : begin
            if (RX_D_VLD) begin 
                if (RX_P_DATA >= 'd2 && RX_P_DATA <= 'd15) begin
                    next_state = WRITE_DATA;
                end
                else begin
                    next_state = IDLE;
                end
            end
            else begin
                next_state = WRITE_ADDR;
            end
        end

        WRITE_DATA : begin
            if (RX_D_VLD) begin
                Address    = Write_Address_reg;
                WrEn       = 'b1;
                WrData     = RX_P_DATA;
                next_state = IDLE;
            end
            else begin
                next_state = WRITE_DATA;
            end
        end

        READ_ADDR : begin
            if (RX_D_VLD) begin
                if (RX_P_DATA <= 'd15) begin
                    if (!FIFO_FULL) begin
                        Address    = RX_P_DATA;
                        RdEn       = 'b1;
                        next_state = READ_DATA;    
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
                else begin
                    next_state = IDLE;
                end
            end
            else begin
                next_state = READ_ADDR;
            end
        end
        
        READ_DATA : begin
            if (RdData_Valid) begin
                TX_P_DATA  = RdData ;
                TX_D_VLD   = 'b1;
                next_state = IDLE;
            end
            else begin
                next_state = READ_DATA;
            end
        end

        OPRAND_A : begin
            if (RX_D_VLD) begin
                WrEn       = 'b1;
                Address    = 'd0;
                WrData     = RX_P_DATA;
                next_state = OPRAND_B;
            end
            else begin
                next_state = OPRAND_A;
            end
        end

        OPRAND_B : begin
            WrEn       = 'b0;
            if (RX_D_VLD) begin
                WrEn       = 'b1;
                Address    = 'd1;
                WrData     = RX_P_DATA;
                next_state = ALU_FUN_S;
            end
            else begin
                next_state = OPRAND_B;
            end
        end
        
        ALU_FUN_S : begin
            CLK_EN = 1'b1;
            if (RX_D_VLD) begin
                EN         = 1'b1;
                ALU_FUN    = RX_P_DATA;
                next_state = Send_Result;
            end
            else begin
                EN         = 1'b0;
                next_state = ALU_FUN_S;
            end
        end

        Send_Result : begin  
            if (OUT_Valid) begin
                if (!FIFO_FULL) begin
                    TX_D_VLD  = 'b1;
                    TX_P_DATA = ALU_OUT[ALU_OUT_WIDTH-1:ALU_OUT_WIDTH/2]; // 8'b -> 16'b ??
                    next_state = Send_Result_LSB;    
                end
                else begin
                    next_state = Send_Result;
                end
            end
            else begin
                next_state = Send_Result;
            end
        end

        Send_Result_LSB : begin
            if (!FIFO_FULL) begin
                TX_D_VLD   = 1'b1;
                TX_P_DATA = ALU_OUT[(ALU_OUT_WIDTH/2)-1 : 0];
                next_state = IDLE;
            end
            else begin
                next_state = Send_Result_LSB;
            end
        end
        
        default:  next_state = IDLE;
    
    endcase

end

endmodule
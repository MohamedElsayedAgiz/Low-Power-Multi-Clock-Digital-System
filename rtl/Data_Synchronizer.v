module Data_Synchronizer #(parameter bus_width = 8,  No_FF = 2) (
    
    input       [bus_width-1:0]     Unsync_bus,
    input                           bus_enable,
    input                           CLK,
    input                           RST,
    output reg     [bus_width-1:0]  Sync_bus,
    output reg                      enable_bulse

);

reg  [No_FF-1:0]     F_F;
reg                  P_F_F;
reg  [bus_width-1:0] Mux_O;
wire                 Pulse_Gen;

assign Pulse_Gen = (!P_F_F) && (F_F[0]);

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        F_F   <= 'd0;
        P_F_F <= 'd0;
    end
    else begin
        {F_F, P_F_F} <= {bus_enable, F_F};
    end
end

always @(posedge CLK or negedge RST) begin
    if (!RST) begin
        enable_bulse <= 'd0;
        Sync_bus     <= 'd0;
    end
    else begin
        enable_bulse <= Pulse_Gen;
        Sync_bus     <= Mux_O;
    end
end

always @(*) begin
    if (Pulse_Gen) begin
        Mux_O = Unsync_bus;
    end
    else begin
        Mux_O = Sync_bus;
    end
end

    
endmodule
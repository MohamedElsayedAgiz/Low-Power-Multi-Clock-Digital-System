module Memory #(parameter WIDTH = 8, DEPTH = 16, ADDR = 4)
(
input      [WIDTH-1:0]      WrData,
input      [ADDR-1:0]       Address,
input                       WrEn,
input                       RdEn,
input                       RST,
input                       CLK,
output reg [WIDTH-1:0]      RdData,
output reg                  RdData_VLD,
output     [WIDTH-1:0]      REG0,
output     [WIDTH-1:0]      REG1,
output     [WIDTH-1:0]      REG2,
output     [WIDTH-1:0]      REG3   

);
// 2D array
reg[WIDTH-1:0] memory [DEPTH-1:0];

always @(posedge CLK or negedge RST)
  begin
    
    if(!RST)
      begin
        RdData_VLD <= 1'b0 ;
        RdData <= 'b0;
// Reset all register files        
        memory[0] <= 'b0;
        // ALU Operand A
        memory[1] <= 'b0;
        // ALU Operand B
        memory[2] <= 'b1000_0001;
        // UART Config -> REG2[0]: Parity Enable (1) -> REG2[1]: Parity Type (0) -> REG2[7:2]: Prescale (32)
        memory[3] <= 'b0010_0000;
        // REG3[7:0]: Division ratio (32)
        memory[4]  <= 'b0;
        memory[5]  <= 'b0;
        memory[6]  <= 'b0;
        memory[7]  <= 'b0;
        memory[8]  <= 'b0;
        memory[9]  <= 'b0;
        memory[10] <= 'b0;
        memory[11] <= 'b0;
        memory[12] <= 'b0;
        memory[13] <= 'b0;
        memory[14] <= 'b0;
        memory[15] <= 'b0;
      end
    else
    begin
      if(WrEn && !RdEn)
        begin
          memory[Address] <= WrData;
          RdData_VLD      <= 1'b0;
        end
      else if (RdEn && !WrEn)
        begin
          RdData <= memory[Address];
          RdData_VLD <= 1'b1;
        end
      else begin
          RdData_VLD <= 1'b0;
      end
    end  
  end

assign REG0 = memory[0] ;
assign REG1 = memory[1] ;
assign REG2 = memory[2] ;
assign REG3 = memory[3] ;

endmodule
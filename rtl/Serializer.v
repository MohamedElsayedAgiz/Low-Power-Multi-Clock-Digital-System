module Serializer (
    input        CLK,
    input        RST,
    input        load,
    input        ser_en,
    input  [7:0] P_DATA,
    output       ser_data,
    output reg   ser_done
);

reg [7:0] Q;
reg [3:0] counter;

assign ser_data = Q[0];

always @(posedge CLK or negedge RST) begin

    if (!RST) begin
        Q        <= 8'b0;
        counter  <= 4'b0;
        ser_done <= 1'b0;
    end

    else begin

     if (load) begin
        Q        <= P_DATA;
        counter  <= 4'b0;
        ser_done <= 1'b0;
    end

    else if (ser_en) begin

        Q       <= Q >> 1;
        counter <= counter + 1'b1;

        if (counter == 6)
            ser_done <= 1'b1;
        else
            ser_done <= 1'b0;

    end

    else begin
        ser_done <= 1'b0;
    end
    
    end

end

endmodule
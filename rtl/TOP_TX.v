module TOP_TX (

    input [7:0] P_DATA,
    input       Data_Valid,PAR_EN,PAR_TYP,
    input       RST,
    input       CLK,
    output      TX_OUT,busy

);

wire ser_done,ser_en,par_bit,ser_data,load;
wire [1:0] mux_sel;

FSM_TX F_S_M (

    .Data_Valid (Data_Valid),
    .PAR_EN     (PAR_EN),
    .ser_done   (ser_done),
    .RST        (RST),
    .CLK        (CLK),

    .ser_en     (ser_en),
    .busy       (busy),
    .load       (load),  
    .mux_sel    (mux_sel)

);

Serializer Ser (

    .P_DATA     (P_DATA),
    .ser_en     (ser_en),
    .load       (load),
    .RST        (RST),
    .CLK        (CLK),

    .ser_done   (ser_done),
    .ser_data   (ser_data)

);

MUX M_U_X (

    .mux_sel    (mux_sel),
    .ser_data   (ser_data),
    .par_bit    (par_bit),
    .TX_OUT     (TX_OUT)

);

Parity_Calc P_C (

    .P_DATA     (P_DATA),
    .load       (load),
    .PAR_TYP    (PAR_TYP),
    .CLK        (CLK),
    .RST        (RST),
    
    .par_bit    (par_bit)

);

endmodule
module TOP_RX (

    input          RX_IN,PAR_EN,PAR_TYP,
    input   [5:0]  Prescale,
    input          RST,
    input          CLK,
    output  [7:0]  P_DATA,
    output         par_err,stp_err,data_valid

);

wire [7:0] Q;
wire [5:0] edge_cnt;
wire [3:0] bit_cnt;
wire [1:0] frame_valid;
wire       strt_glitch,enable,dat_samp_en,par_chk_en,strt_chk_en,stp_chk_en,State,sampled_pit,new_frame;




FSM_RX D_U_T_FSM (

    .bit_cnt        (bit_cnt),
    .edge_cnt       (edge_cnt),
    .Prescale       (Prescale),
    .RX_IN          (RX_IN),
    .PAR_EN         (PAR_EN),
    .stp_err        (stp_err),
    .strt_glitch    (strt_glitch),
    .par_err        (par_err),
    .RST            (RST),
    .CLK            (CLK),
    .frame_valid    (frame_valid),
    .enable         (enable),
    .dat_samp_en    (dat_samp_en),
    .data_valid     (data_valid),
    .par_chk_en     (par_chk_en),
    .strt_chk_en    (strt_chk_en),
    .stp_chk_en     (stp_chk_en),
    .State          (State),
    .new_frame      (new_frame)

);

edge_pit_counter D_U_T_edge_pit_counter (

    .enable         (enable),
    .Prescale       (Prescale),
    .PAR_EN         (PAR_EN),
    .State          (State),
    .RST            (RST),
    .CLK            (CLK),
    .bit_cnt        (bit_cnt),
    .edge_cnt       (edge_cnt)

);

data_sampling D_U_T_data_sampling (

    .dat_samp_en    (dat_samp_en),
    .Prescale       (Prescale),
    .edge_cnt       (edge_cnt),
    .RX_IN          (RX_IN),
    .RST            (RST),
    .CLK            (CLK),
    .sampled_pit    (sampled_pit)

);

P_C D_U_T_P_C (

    .P_DATA         (Q),
    .edge_cnt       (edge_cnt),
    .Prescale       (Prescale),
    .PAR_TYP        (PAR_TYP),
    .par_chk_en     (par_chk_en),
    .sampled_pit    (sampled_pit),
    .new_frame      (new_frame),
    .RST            (RST),
    .CLK            (CLK),
    .par_err        (par_err)

);

Start_C D_U_T_Start_C (

    .strt_chk_en    (strt_chk_en),
    .sampled_pit    (sampled_pit),
    .strt_glitch    (strt_glitch)

);

Stop_C D_U_T_Stop_C (

    .new_frame      (new_frame),
    .stp_chk_en     (stp_chk_en),
    .sampled_pit    (sampled_pit),
    .RST            (RST),
    .CLK            (CLK),
    .edge_cnt       (edge_cnt),
    .Prescale       (Prescale),
    .stp_err        (stp_err)

);

deserializer D_U_T_deserializer (

    .sampled_pit    (sampled_pit),
    .edge_cnt       (edge_cnt),
    .bit_cnt        (bit_cnt),
    .Prescale       (Prescale),
    .frame_valid    (frame_valid),
    .RST            (RST),
    .CLK            (CLK),
    .P_DATA         (P_DATA),
    .Q              (Q),
    .new_frame      (new_frame)

);

endmodule
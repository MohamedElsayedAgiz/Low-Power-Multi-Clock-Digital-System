module Start_C (

    input        strt_chk_en,sampled_pit,
    output reg   strt_glitch

);

always @(*) begin
    
    if (!strt_chk_en) begin
        strt_glitch=0;
    end
    else begin
        if (sampled_pit == 0) begin
            strt_glitch = 0;
        end
        else begin
            strt_glitch = 1;
        end
    end
end
endmodule

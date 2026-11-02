// for tinytapeout input output 

`default_nettype none

module tt_um_tommasomarchetti99_umtv_asic (
    input  wire [7:0] ui_in,    // 8 Dedicated inputs
    output wire [7:0] uo_out,   // 8 Dedicated outputs
    input  wire [7:0] uio_in,   // 8 Bidirectional pins (Input path)
    output wire [7:0] uio_out,  // 8 Bidirectional pins (Output path)
    output wire [7:0] uio_oe,   // 8 Bidirectional Output Enables (1 = Output, 0 = Input)
    input  wire       ena,      // Always 1 when design is powered on chip
    input  wire       clk,      // System clk
    input  wire       rst_n     // System rst (active low)
);

    // Bidirectional pins config
    // 5/8 used as outputs. 
    // Setting uio_oe to 1 to force pad into output mode.
    assign uio_oe = 8'b0001_1111; 

    // unused outputs tied to avoid floating
    assign uio_out[7:5] = 3'b000;

    // ASIC core
    toplevel_UMTV asic_core (
        .ASIC_clk(clk),
        .rst_n(rst_n),

        // INPUT MAP
        .CS(ui_in[0]),
        .SPI_clk(ui_in[1]),
        .MOSI(ui_in[2]),
        .async_adc_done(ui_in[3]),
        .async_slow_trig(ui_in[4]),

        // OUTPUT MAP A
        .status_out(uo_out[5:0]),   // Uses uo_out[0] through uo_out[5]
        .dac_trig_out(uo_out[6]),   
        .adc_trig_out(uo_out[7]),   

        // OUTPUT MAP B: Overflow 
        .address_out(uio_out[3:0]), // Uses uio_out[0] through uio_out[3]
        .enable_slow_out(uio_out[4])
    );

endmodule

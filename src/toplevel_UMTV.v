`timescale 1ns / 1ps

module toplevel_UMTV (

    input  wire        ASIC_clk,         // 50 MHz clk
    input  wire        rst_n,            // Asynchronous active-low reset

    // SPI inputs
    input  wire        CS,
    input  wire        SPI_clk,
    input  wire        MOSI,

    // Asynchronous trig
    input  wire        async_adc_done,   // From external ADC
    input  wire        async_slow_trig,  // From external long-term timer

    // Outputs to ext hardware
    output wire [3:0]  address_out,      // To analog multiplexer (masked)
    output wire        dac_trig_out,     // To NEOS test DAC (masked)
    output wire        adc_trig_out,     // To external ADC (masked)
    output wire        enable_slow_out,  // To start external long-term timer

    // Status output
    output wire [5:0]  status_out
);

    // =========================================================================
    // Internal Interconnect Wires
    // =========================================================================

    // CDC to internal SPI logic
    wire        sync_CS;
    wire        sync_SPI_clk;
    wire        sync_MOSI;

    // Edge detector to SIPO
    wire        SPI_clk_rise;

    // SIPO to hold reg & FSM
    wire [15:0] data_word_16b;
    wire        WE;

    // Hold tegister to datapath & FSM
    wire        parity_bit; // floating, used internally by hold_register logic
    wire [1:0]  mode;
    wire [3:0]  address;
    wire [8:0]  pulse_width;
    wire        parity_error;

    // timers to/from FSM
    wire        enable_fixed;
    wire        fixed_trig;
    wire        enable_fast;
    wire        fast_trig;

    // Synchronizer to FSM
    wire        sync_adc_done;
    wire        sync_slow_trig;

    // FSM to output router
    wire [3:0]  current_state;
    wire        dac_trig;
    wire        adc_trig;

    // =========================================================================
    // Module Instantiations
    // =========================================================================

    cdc u_cdc (
        .ASIC_clk(ASIC_clk),
        .rst_n(rst_n),
        .CS(CS),
        .SPI_clk(SPI_clk),
        .MOSI(MOSI),
        .sync_CS(sync_CS),
        .sync_SPI_clk(sync_SPI_clk),
        .sync_MOSI(sync_MOSI)
    );

    edge_detector u_edge_detector (
        .ASIC_clk(ASIC_clk),
        .rst_n(rst_n),
        .sync_SPI_clk(sync_SPI_clk),
        .SPI_clk_rise(SPI_clk_rise)
    );

    spi_sipo u_spi_sipo (
        .ASIC_clk(ASIC_clk),
        .rst_n(rst_n),
        .sync_CS(sync_CS),
        .sync_MOSI(sync_MOSI),
        .SPI_clk_rise(SPI_clk_rise),
        .data_word_16b(data_word_16b),
        .WE(WE)
    );

    hold_register u_hold_register (
        .ASIC_clk(ASIC_clk),
        .rst_n(rst_n),
        .WE(WE),
        .data_word_16b(data_word_16b),
        .parity_bit(parity_bit),
        .mode(mode),
        .address(address),
        .pulse_width(pulse_width),
        .parity_error(parity_error)
    );

    fixed_micro_timer u_fixed_timer (
        .ASIC_clk(ASIC_clk),
        .rst_n(rst_n),
        .enable_fixed(enable_fixed),
        .fixed_trig(fixed_trig)
    );

    variable_fast_timer u_fast_timer (
        .ASIC_clk(ASIC_clk),
        .rst_n(rst_n),
        .pulse_width(pulse_width),
        .enable_fast(enable_fast),
        .fast_trig(fast_trig)
    );

    input_synch u_input_synch (
        .ASIC_clk(ASIC_clk),
        .rst_n(rst_n),
        .async_adc_done(async_adc_done),
        .async_slow_trig(async_slow_trig),
        .sync_adc_done(sync_adc_done),
        .sync_slow_trig(sync_slow_trig)
    );

    fsm u_fsm (
        .ASIC_clk(ASIC_clk),
        .rst_n(rst_n),
        .WE(WE),
        .parity_error(parity_error),
        .mode(mode),
        .fixed_trig(fixed_trig),
        .fast_trig(fast_trig),
        .slow_trig(sync_slow_trig),
        .adc_done(sync_adc_done),
        .enable_fixed(enable_fixed),
        .enable_fast(enable_fast),
        .enable_slow(enable_slow_out), // Routed directly to top-level output
        .current_state(current_state),
        .dac_trig(dac_trig),
        .adc_trig(adc_trig)
    );

    output_router u_output_router (
        .ASIC_clk(ASIC_clk),
        .rst_n(rst_n),
        .mode(mode),
        .address(address),
        .current_state(current_state),
        .dac_trig(dac_trig),
        .adc_trig(adc_trig),
        .status_out(status_out),
        .address_out(address_out),
        .dac_trig_out(dac_trig_out),
        .adc_trig_out(adc_trig_out)
    );

endmodule

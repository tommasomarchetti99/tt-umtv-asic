`timescale 1ns / 1ps

module input_synch (
    input  wire ASIC_clk,         // 50 MHz clk
    input  wire rst_n,            // Asynchronous active-low reset

    // Asynchronous inputs from external hardware
    input  wire async_adc_done,   // Raw signal from external ADC
    input  wire async_slow_trig,  // Raw signal from external long-term timer

    // Synchronized outputs to the FSM
    output wire sync_adc_done,    
    output wire sync_slow_trig    
);

    //2 stage shift reg
    reg [1:0] adc_done_ff;
    reg [1:0] slow_trig_ff;

    always @(posedge ASIC_clk or negedge rst_n) begin
        if (!rst_n) begin
            // Default states
            adc_done_ff  <= 2'b00;
            slow_trig_ff <= 2'b00;
        end else begin
            // Shift sampled values
            adc_done_ff  <= {adc_done_ff[0], async_adc_done};
            slow_trig_ff <= {slow_trig_ff[0], async_slow_trig};
        end
    end

    // assign outputs to stable second stage
    assign sync_adc_done  = adc_done_ff[1];
    assign sync_slow_trig = slow_trig_ff[1];

endmodule

`timescale 1ns / 1ps

module fixed_micro_timer #(
    // 5 cycles at 50MHz = 100ns of settling time for loading/unloading to avoid analogue transients
    parameter DELAY_CYCLES = 5 
)(
    input  wire ASIC_clk,
    input  wire rst_n,
    
    input  wire enable_fixed,  // HIGH from FSM to start settling delay
    output reg  fixed_trig     // HIGH when delay is complete
);

    // 4-bit counter for up to 15 clock cycles (300ns max)
    reg [3:0] counter;

    always @(posedge ASIC_clk or negedge rst_n) begin
        if (!rst_n) begin
            counter    <= 4'd0;
            fixed_trig <= 1'b0;
        end else begin
            if (enable_fixed == 1'b0) begin
                counter    <= 4'd0;
                fixed_trig <= 1'b0;
            end else begin
                if (counter >= DELAY_CYCLES) begin
                    fixed_trig <= 1'b1; // counter finish
                end else begin
                    counter    <= counter + 1'b1;
                    fixed_trig <= 1'b0;
                end
            end
        end
    end

endmodule

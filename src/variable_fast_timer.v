`timescale 1ns / 1ps

module variable_fast_timer (
    input  wire       ASIC_clk,      // 50 MHz clk
    input  wire       rst_n,         // Asynchronous active-low reset
    
    // Input from  Hold Register
    input  wire [8:0] pulse_width,   // Target value (0 to 511)
    
    // Handshake with FSM
    input  wire       enable_fast,   // HIGH to start the timer
    output reg        fast_trig      // HIGH when countdown is finished
);

    // 9-bit counter to match 9-bit pulse_width
    reg [8:0] counter;

    always @(posedge ASIC_clk or negedge rst_n) begin
        if (!rst_n) begin
            counter   <= 9'd0;
            fast_trig <= 1'b0;
        end else begin
            if (enable_fast == 1'b0) begin
                // FSM signal low
                // reset counter
                counter   <= 9'd0;
                fast_trig <= 1'b0;
            end else begin
                // The FSM holding enable_fast HIGH.
                
                if (counter >= pulse_width) begin
                    // counter finished
                    fast_trig <= 1'b1;
                end else begin
                    // incremental counter
                    counter   <= counter + 1'b1;
                    fast_trig <= 1'b0;
                end
            end
        end
    end

endmodule

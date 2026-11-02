`timescale 1ns / 1ps

// edge detector to translate continuous high signal from ext. microctrl. into a single clk cycle high pulse

module edge_detector (
    input  wire ASIC_clk,       // 50 MHz system clock
    input  wire rst_n,          // Asynchronous active-low reset
    input  wire sync_SPI_clk,   // Synchronized SPI clck from CDC block
    output wire SPI_clk_rise    // 1-clock-cycle pulse on rising edge
);

    // Register to store previous state of sync_SPI_clk
    reg [1:0] sync_SPI_clk_d;

    always @(posedge ASIC_clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_SPI_clk_d <= 2'b00;
        end else begin
            sync_SPI_clk_d <= {sync_SPI_clk_d[0], sync_SPI_clk};
        end
    end

    // outputs 1 for one ASIC_clk cycle when previous was 0 and current is 1
    assign SPI_clk_rise = sync_SPI_clk_d[0] & ~sync_SPI_clk_d[1];

endmodule

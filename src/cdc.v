`timescale 1ns / 1ps            // base unit of time / precision

module cdc (
    input  wire ASIC_clk,      // System clock (50 MHz)
    input  wire rst_n,         // Asynchronous active-low reset
    
    // Raw inputs directly from Tiny Tapeout physical pins
    input  wire CS,            // Raw Chip Select
    input  wire SPI_clk,       // Raw SPI Clock
    input  wire MOSI,          // Raw Master-Out-Slave-In Data
    
    // Synchronized outputs going to SPI register & edge detector
    output wire sync_CS,
    output wire sync_SPI_clk,
    output wire sync_MOSI
);

    // Internal 2-stage shift registers
    // [0] the first stage for input
    // [1] the second stage for output
    reg [1:0] cs_ff;
    reg [1:0] spi_clk_ff;
    reg [1:0] mosi_ff;

    always @(posedge ASIC_clk or negedge rst_n) begin  //ASIC clk timing | asynch reset button 
        if (!rst_n) begin
            // default states for reset
            cs_ff      <= 2'b11; // CS is active-low, default to 1 (inactive)
            spi_clk_ff <= 2'b00; // Clock default low
            mosi_ff    <= 2'b00; // Data default low
        end else begin
            // Sample raw data from input pins
            // Shift sampled value to stable output
            // [0,0] -> [0,new] -> [new,new+1] -> [new+1, new+2] ...
            cs_ff      <= {cs_ff[0], CS};
            spi_clk_ff <= {spi_clk_ff[0], SPI_clk};
            mosi_ff    <= {mosi_ff[0], MOSI};
        end
    end

    // Assign the outputs to the second stage of the flip-flops
    assign sync_CS      = cs_ff[1];
    assign sync_SPI_clk = spi_clk_ff[1];
    assign sync_MOSI    = mosi_ff[1];

endmodule

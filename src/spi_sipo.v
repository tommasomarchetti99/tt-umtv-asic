`timescale 1ns / 1ps

module spi_sipo (
    input  wire        ASIC_clk,      // 50 MHz clk
    input  wire        rst_n,         // Asynchronous active-low reset
    
    // Inputs from the CDC and Edge Detector 
    input  wire        sync_CS,       
    input  wire        sync_MOSI,     
    input  wire        SPI_clk_rise,  
    
    // Outputs to the Hold Register
    output reg  [15:0] data_word_16b, // 16 bit data word containing:
                                      // [15] parity
                                      // [14:13] Opcode
                                      // [12:9]
                                      // [8:0] pulse width
                                      
    output reg         WE             // Write Enable 1-cycle pulse
);

    // Internal registers
    reg [15:0] shift_reg;
    reg [4:0]  bit_count;             // count 0 to 15

    always @(posedge ASIC_clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg     <= 16'd0;
            bit_count     <= 5'd0;
            data_word_16b <= 16'd0;
            WE            <= 1'b0;
        end else begin
            //WE resets after one clk cycle by default
            WE <= 1'b0;

            if (sync_CS == 1'b1) begin
                //CS selection condition
                bit_count <= 5'd0;
            end 
            else if (SPI_clk_rise == 1'b1) begin

                // -> assumes standard MSB-first SPI transmission <-
                shift_reg <= {shift_reg[14:0], sync_MOSI};
                bit_count <= bit_count + 1'b1;

                // bit count check
                if (bit_count == 5'd15) begin
                    // data word complete
                    data_word_16b <= {shift_reg[14:0], sync_MOSI};
                    
                    // trigger for hold register
                    WE <= 1'b1;
                    
                    // Reset counter
                    bit_count <= 5'd0;
                end
            end
        end
    end

endmodule

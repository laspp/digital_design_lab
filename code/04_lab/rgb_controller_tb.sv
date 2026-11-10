// `timescale 1ns / 1ps
// `include "rgb_controller.sv" 

module rgb_controller_tb;

    // Declare testbench signals
    logic clock;
    logic reset;
    logic [7:0] SW;
    logic [2:0] RGB;
    logic pwm_out;

    // Instantiate the rgb_controller module
    rgb_controller uut (
        .clock(clock),
        .reset(reset),
        .SW(SW),
        .RGB(RGB),
        .pwm_out(pwm_out)
    );

    integer i;
    // Parameters
    localparam CL = 10; // Clock period in ns

    // Clock generation
    initial begin
        clock = 0;
        forever #(CL/2) clock = ~clock; // 100 MHz clock
    end

    // Test sequence
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars;
        // Initialize signals
        reset = 1;

        #(CL*2);
        reset = 0;

        // Red at 12.5%, oscilloscope select = red (SW[7:6] = 00)
        for (i = 0; i < 32*3125; i=i+1)
        begin
            SW = 8'b00_000001;
            #((CL));
        end

        // Green at 25%, oscilloscope select = green (SW[7:6] = 01)
        for (i = 0; i < 32*3125; i=i+1)
        begin
            SW = 8'b01_001000;
            #((CL));
        end

        // Blue at 50%, oscilloscope select = blue (SW[7:6] = 10)
        for (i = 0; i < 32*3125; i=i+1)
        begin
            SW = 8'b10_110000;
            #((CL));
        end

        // All three active, oscilloscope select = 11 (unused value,
        // pwm_out should be forced to 0 by the default branch)
        for (i = 0; i < 32*3125; i=i+1)
        begin
            SW = 8'b11_110110;
            #((CL));
        end

        // $finish;
    end

   

endmodule
///////////////////////////////////////////////////////////////////////
// uarttx_tb
//
// Purpose: Self-checking testbench for uarttx. Uses a fast baud rate
//          (LIMIT = 10 clock cycles per bit) so frames are short in
//          the waveform. A receiver task decodes the Tx line by
//          sampling the middle of every bit and compares each frame
//          with the byte that was sent.
//          Run with: anvil test tb/uarttx_tb.sv
// Author:  Ratko Pilipovic
// Date:    16 November 2026
///////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module uarttx_tb;

  localparam CLK_FREQ  = 100_000_000;
  localparam BAUD_RATE = 10_000_000;
  localparam LIMIT     = CLK_FREQ / BAUD_RATE;  // 10 clock cycles per bit

  logic       clk, reset;
  logic       Start, Tx, Busy, Done;
  logic [7:0] Data;
  logic [7:0] Received;
  integer     Errors;

  uarttx #(CLK_FREQ, BAUD_RATE) dut(.clk(clk), .reset(reset), .Start(Start), .Data(Data),
                                    .Tx(Tx), .Busy(Busy), .Done(Done));

  // 100 MHz clock
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // watchdog: stop a simulation that waits forever for a frame
  initial begin
    #200_000;
    $display("FAIL: timeout after 200 us, no complete frame seen on the line");
    $finish;
  end

  // decode one 8N1 frame from Tx
  task automatic rxframe(output logic [7:0] Byte);
    integer i;
    begin
      @(negedge Tx);                           // falling edge of the start bit
      repeat (LIMIT / 2) @(posedge clk);       // middle of the start bit
      if (Tx !== 1'b0) begin
        $display("ERROR: start bit is not low at mid-bit");
        Errors = Errors + 1;
      end
      for (i = 0; i < 8; i = i + 1) begin      // LSB first
        repeat (LIMIT) @(posedge clk);
        Byte[i] = Tx;
      end
      repeat (LIMIT) @(posedge clk);           // middle of the stop bit
      if (Tx !== 1'b1) begin
        $display("ERROR: stop bit is not high");
        Errors = Errors + 1;
      end
    end
  endtask

  // send one byte and check what appears on the line
  task automatic sendandcheck(input logic [7:0] Byte);
    begin
      @(negedge clk);
      Data  = Byte;
      Start = 1'b1;
      @(negedge clk);
      Start = 1'b0;
      if (Busy !== 1'b1) begin
        $display("ERROR: Busy is not high after Start");
        Errors = Errors + 1;
      end
      rxframe(Received);
      @(posedge Done);
      if (Received === Byte)
        $display("OK:    sent 0x%h, received 0x%h", Byte, Received);
      else begin
        $display("ERROR: sent 0x%h, received 0x%h", Byte, Received);
        Errors = Errors + 1;
      end
      @(posedge clk);                          // FSM returns to IDLE
      @(negedge clk);
      if (Busy !== 1'b0) begin
        $display("ERROR: Busy is still high after Done");
        Errors = Errors + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("tb/uarttx_tb.vcd");
    $dumpvars(0, uarttx_tb);

    Errors = 0;
    Start  = 1'b0;
    Data   = 8'h00;
    reset  = 1'b1;
    repeat (2) @(posedge clk);
    reset  = 1'b0;

    if (Tx !== 1'b1) begin
      $display("ERROR: Tx is not high (idle) after reset");
      Errors = Errors + 1;
    end

    repeat (5) @(posedge clk);
    sendandcheck(8'h55);   // alternating bits, easy to read in the waveform
    sendandcheck(8'hA3);
    sendandcheck(8'h48);   // 'H'
    sendandcheck(8'h00);
    sendandcheck(8'hFF);

    repeat (20) @(posedge clk);
    if (Errors == 0) $display("PASS: all frames correct");
    else             $display("FAIL: %0d error(s)", Errors);
    $finish;
  end

endmodule

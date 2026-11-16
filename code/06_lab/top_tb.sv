///////////////////////////////////////////////////////////////////////
// top_tb
//
// Purpose: System testbench for top. Releases the reset, presses BTNC
//          once and decodes the uart_tx line at the real 115200 baud
//          (868 clock cycles per bit). The received characters are
//          printed as text and compared with "Hello World!\r\n".
//          The whole message takes about 1.2 ms of simulated time.
//          Run with: anvil test tb/top_tb.sv
// Author:  Ratko Pilipovic
// Date:    16 November 2026
///////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module top_tb;

  localparam LIMIT   = 100_000_000 / 115_200;  // 868 clock cycles per bit
  localparam MSG_LEN = 14;

  logic       clk, cpu_resetn, btnc;
  logic       uart_tx, ja1;
  logic [1:0] led;
  logic [7:0] Expected [0:MSG_LEN-1];
  logic [7:0] Byte;
  integer     i, n, Errors;

  top dut(.clk(clk), .cpu_resetn(cpu_resetn), .btnc(btnc), .uart_tx(uart_tx), .ja1(ja1),
          .led(led));

  // 100 MHz clock
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // watchdog: stop a simulation that waits forever for a frame
  initial begin
    #3_000_000;
    $display("FAIL: timeout after 3 ms, no complete frame seen on the line");
    $finish;
  end

  initial begin
    // dump only the board-level pins, the full design makes a very large file
    $dumpfile("tb/top_tb.vcd");
    $dumpvars(1, top_tb);

    Expected[0]  = "H";  Expected[1]  = "e";  Expected[2]  = "l";  Expected[3]  = "l";
    Expected[4]  = "o";  Expected[5]  = " ";  Expected[6]  = "W";  Expected[7]  = "o";
    Expected[8]  = "r";  Expected[9]  = "l";  Expected[10] = "d";  Expected[11] = "!";
    Expected[12] = 8'h0D; Expected[13] = 8'h0A;

    Errors     = 0;
    btnc       = 1'b0;
    cpu_resetn = 1'b0;   // hold the red reset button
    repeat (10) @(posedge clk);
    cpu_resetn = 1'b1;
    repeat (10) @(posedge clk);

    // press BTNC for 1 us. The first start bit begins while the button is
    // still held, so the receiver runs in parallel with the button press.
    fork
      begin
        btnc = 1'b1;
        repeat (100) @(posedge clk);
        btnc = 1'b0;
      end
      begin
        $write("Received: \"");
        for (n = 0; n < MSG_LEN; n = n + 1) begin
          @(negedge uart_tx);                  // start bit
          repeat (LIMIT / 2) @(posedge clk);
          for (i = 0; i < 8; i = i + 1) begin
            repeat (LIMIT) @(posedge clk);
            Byte[i] = uart_tx;
          end
          repeat (LIMIT) @(posedge clk);       // stop bit
          if (uart_tx !== 1'b1) Errors = Errors + 1;
          if (Byte >= 8'h20) $write("%c", Byte);
          else if (Byte == 8'h0D) $write("\\r");
          else if (Byte == 8'h0A) $write("\\n");
          else $write("<%h>", Byte);
          if (Byte !== Expected[n]) Errors = Errors + 1;
        end
      end
    join
    $display("\"");

    repeat (2 * LIMIT) @(posedge clk);
    if (led !== 2'b00) begin
      $display("ERROR: LEDs still lit after the message");
      Errors = Errors + 1;
    end
    if (Errors == 0) $display("PASS: message received correctly");
    else             $display("FAIL: %0d error(s)", Errors);
    $finish;
  end

endmodule

///////////////////////////////////////////////////////////////////////
// btnpulse
//
// Purpose: Turns a push button into a single-cycle pulse. Two flip-
//          flops synchronise the asynchronous button into the clock
//          domain. A third flip-flop remembers the previous level, and
//          Pulse is high for one cycle when the level goes from 0
//          to 1. Holding the button down produces only one pulse.
//          There is no debouncing: a bouncing contact can still give
//          more than one pulse.
// Author:  Ratko Pilipovic
// Date:    16 November 2026
///////////////////////////////////////////////////////////////////////

module btnpulse (input  logic clk, reset,
                 input  logic Btn,
                 output logic Pulse);

  logic BtnMeta, BtnSync, BtnPrev;

  always_ff @(posedge clk)
    if (reset) begin
      BtnMeta <= 1'b0;
      BtnSync <= 1'b0;
      BtnPrev <= 1'b0;
    end else begin
      BtnMeta <= Btn;
      BtnSync <= BtnMeta;
      BtnPrev <= BtnSync;
    end

  assign Pulse = BtnSync & ~BtnPrev;

endmodule

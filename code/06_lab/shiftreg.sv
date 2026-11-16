///////////////////////////////////////////////////////////////////////
// shiftreg
//
// Purpose: Parallel-in, serial-out shift register. Load captures D,
//          Shift moves the contents one place towards bit 0. The bit
//          on SerialOut is always Q[0], so the LSB goes out first, as
//          the UART frame requires. Built structurally from the
//          generic mux2 and flopenr cells.
// Author:  <your name>
// Date:    <date>
///////////////////////////////////////////////////////////////////////

module shiftreg #(parameter WIDTH = 8) (
  input  logic             clk, reset,
  input  logic             Load, Shift,
  input  logic [WIDTH-1:0] D,
  output logic             SerialOut);

  logic [WIDTH-1:0] Q, ShiftedQ, NextQ;
  logic             En;

  // TODO: ShiftedQ is Q shifted right by one place, with a 0 entering at the top

  // TODO: instantiate mux2 #(WIDTH) loadmux
  //   selects D when Load is high, ShiftedQ otherwise, result on NextQ

  // TODO: En is high when the register should update (Load or Shift)

  // TODO: instantiate flopenr #(WIDTH) datareg
  //   stores NextQ into Q when En is high

  // TODO: SerialOut is the lowest bit of Q

endmodule

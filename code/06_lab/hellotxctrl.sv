///////////////////////////////////////////////////////////////////////
// hellotxctrl
//
// Purpose: Message sender FSM. A pulse on Send walks Addr through the
//          MSG_LEN characters of msgrom. For every character it pulses
//          TxStart for one cycle, then waits for TxDone from the UART
//          transmitter before moving to the next one. Send is ignored
//          while a message is being sent.
// Author:  <your name>
// Date:    <date>
///////////////////////////////////////////////////////////////////////

module hellotxctrl #(parameter MSG_LEN = 14) (
  input  logic       clk, reset,
  input  logic       Send, TxDone,
  output logic [3:0] Addr,
  output logic       TxStart, Busy);

  localparam logic [3:0] LAST_ADDR = 4'(MSG_LEN - 1);

  typedef enum logic [1:0] {IDLE, START, WAIT} statetype;

  statetype State, NextState;
  logic     LastChar;

  // state register
  always_ff @(posedge clk)
    if (reset) State <= IDLE;
    else       State <= NextState;

  // TODO: character address register Addr (always_ff)
  //   - cleared on reset and when Send arrives in IDLE
  //   - incremented when TxDone arrives in WAIT

  // TODO: LastChar is high while Addr equals LAST_ADDR

  // TODO: next state logic (always_comb, case on State)
  //   IDLE  -> START when Send
  //   START -> WAIT  always (START lasts exactly one cycle)
  //   WAIT  -> IDLE  when TxDone and this was the last character
  //   WAIT  -> START when TxDone otherwise
  //   add a default branch

  // TODO: outputs (assign)
  //   TxStart high in START
  //   Busy    high in every state except IDLE

endmodule

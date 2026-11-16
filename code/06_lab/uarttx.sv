///////////////////////////////////////////////////////////////////////
// uarttx
//
// Purpose: UART transmitter, 8N1 (8 data bits, no parity, 1 stop
//          bit). A one-cycle pulse on Start sends the byte on Data.
//          Busy is high while a frame is on the line. Done pulses for
//          one cycle at the end of the stop bit. Structural: baud rate
//          generator, shift register and control FSM.
// Author:  <your name>
// Date:    <date>
///////////////////////////////////////////////////////////////////////

module uarttx #(parameter CLK_FREQ = 100_000_000, BAUD_RATE = 115_200) (
  input  logic       clk, reset,
  input  logic       Start,
  input  logic [7:0] Data,
  output logic       Tx,
  output logic       Busy, Done);

  // clock cycles per bit, 868 for 100 MHz and 115200 baud
  localparam LIMIT = CLK_FREQ / BAUD_RATE;

  logic Tick, BaudClear;
  logic Load, Shift, SerialBit;

  // TODO: instantiate baudgen #(LIMIT) baud
  //   ports: clk, reset, Clear(BaudClear), Tick(Tick)

  // TODO: instantiate shiftreg #(8) datareg
  //   ports: clk, reset, Load, Shift, D(Data), SerialOut(SerialBit)

  // TODO: instantiate uarttxctrl #(8) ctrl
  //   ports: clk, reset, Start, Tick, SerialBit, Load, Shift, BaudClear,
  //          Busy, Done, Tx

endmodule

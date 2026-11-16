///////////////////////////////////////////////////////////////////////
// top
//
// Purpose: Nexys A7-100T wrapper for the "Hello World!" UART sender.
//          Pressing BTNC sends "Hello World!\r\n" over the USB-UART
//          bridge at 115200 baud, 8N1. LED0 is lit while the message
//          is being sent and LED1 while a single character is on the
//          line. The serial line is also mirrored to Pmod pin JA1, so
//          it can be probed with the oscilloscope.
//          The red CPU_RESET button is the reset. It is active low, so
//          it is inverted into the active-high reset the modules use.
// Author:  <your name>
// Date:    <date>
///////////////////////////////////////////////////////////////////////

module top (input  logic       clk,          // 100 MHz board oscillator
            input  logic       cpu_resetn,   // red CPU_RESET button, active low
            input  logic       btnc,         // centre button, sends the message
            output logic       uart_tx,      // to the USB-UART bridge (pin D4)
            output logic       ja1,          // copy of uart_tx for the oscilloscope
            output logic [1:0] led);         // LED0: message busy, LED1: transmitter busy

  logic       Reset;
  logic       Send, TxStart, TxDone, TxBusy, MsgBusy;
  logic [3:0] Addr;
  logic [7:0] Char;

  // active-low button -> active-high reset
  assign Reset = ~cpu_resetn;

  // one pulse per press of BTNC
  btnpulse sendbtn(.clk(clk), .reset(Reset), .Btn(btnc), .Pulse(Send));

  // TODO: instantiate hellotxctrl #(14) sender
  //   ports: clk, reset(Reset), Send, TxDone, Addr, TxStart, Busy(MsgBusy)

  // TODO: instantiate msgrom rom
  //   ports: Addr, Char

  // TODO: instantiate uarttx #(100_000_000, 115_200) tx
  //   ports: clk, reset(Reset), Start(TxStart), Data(Char), Tx(uart_tx),
  //          Busy(TxBusy), Done(TxDone)

  // TODO: ja1 copies uart_tx, led[0] shows MsgBusy, led[1] shows TxBusy

endmodule

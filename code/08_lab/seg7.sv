///////////////////////////////////////////////////////////////////////
// seg7
//
// Purpose: OBI slave that puts the seven-segment display core
//          (SevSegDisplay) on the HIPV bus.
//          Register map (byte offsets within the region):
//            0x00 CONFIG  bit 0 enables the display
//            0x04 DIGIT0  bits 3:0 hex value of the rightmost digit
//            0x08 DIGIT1
//            0x0C DIGIT2
//            0x10 DIGIT3
//            0x14 DIGIT4
//            0x18 DIGIT5
//            0x1C DIGIT6
//            0x20 DIGIT7  bits 3:0 hex value of the leftmost digit
//          All registers can be read back. Writes ignore the byte
//          enables (word accesses only).
//          Every access takes one cycle: Gnt is always high, Rvalid
//          follows an accepted request one cycle later.
///////////////////////////////////////////////////////////////////////

// ObiAddr/ObiWdata are only partly used: registers sit at word offsets
// below 0x80 and are narrower than 32 bits.
/* verilator lint_off UNUSEDSIGNAL */
module seg7 (
  input  logic        clk, reset,
  // OBI slave port
  input  logic        ObiReq,
  output logic        ObiGnt,
  input  logic [31:0] ObiAddr,
  input  logic        ObiWe,
  input  logic [3:0]  ObiBe,
  input  logic [31:0] ObiWdata,
  output logic        ObiRvalid,
  output logic [31:0] ObiRdata,
  // pins (active low)
  output logic [7:0]  SegAnode,
  output logic [6:0]  SegCathode);
/* verilator lint_on UNUSEDSIGNAL */

  // register word indices (ObiAddr[6:2])
  localparam logic [4:0] CONFIG = 5'd0;
  localparam logic [4:0] DIGIT0 = 5'd1;   // DIGIT7 is index 8

  logic       Accept, WeQ;
  logic [4:0] AddrQ;

  logic       Enable;                     // CONFIG bit 0
  logic [3:0] Digit0, Digit1, Digit2, Digit3, Digit4, Digit5, Digit6, Digit7;

  // ---------------------------------------------------------------
  // OBI slave interface (given)
  // ---------------------------------------------------------------
  // Every access completes in one cycle, so a new request can always
  // be accepted. Gnt does not depend on Req.
  assign ObiGnt = 1'b1;
  assign Accept = ObiReq & ObiGnt;

  // the response follows the accepted request one cycle later
  flopenr #(1) validreg(.clk(clk), .reset(reset), .en(1'b1),
                        .D(Accept), .Q(ObiRvalid));
  flopenr #(1) wereg(.clk(clk), .reset(reset), .en(Accept),
                     .D(ObiWe), .Q(WeQ));
  flopenr #(5) addrreg(.clk(clk), .reset(reset), .en(Accept),
                       .D(ObiAddr[6:2]), .Q(AddrQ));

  // ---------------------------------------------------------------
  // TODO 1: write logic, decoded in the address phase
  //   - one write enable per register: Accept & ObiWe & (index match)
  //   - one flopenr per register (CONFIG is 1 bit, a digit is 4 bits)
  //   - the register outputs are Enable and Digit0 ... Digit7
  // ---------------------------------------------------------------


  // ---------------------------------------------------------------
  // TODO 2: read logic, selected in the response phase
  //   - ObiRdata is zero unless there is a read response:
  //       if (ObiRvalid & ~WeQ) case (AddrQ) ...
  //   - return the register selected by AddrQ, zero-extended
  // ---------------------------------------------------------------
  always_comb begin
    ObiRdata = '0;
  end

  // ---------------------------------------------------------------
  // TODO 3: instantiate the display core
  //   SevSegDisplay has ports clock, reset, enable_7seg,
  //   digit1 ... digit8, anode_select and segs.
  //   digit1 is the rightmost digit, so it takes Digit0.
  // ---------------------------------------------------------------

endmodule

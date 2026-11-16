///////////////////////////////////////////////////////////////////////
// msgrom
//
// Purpose: Read-only message memory. Returns the ASCII code of the
//          character at position Addr of "Hello World!\r\n". The
//          carriage return and line feed move the terminal cursor to
//          the start of the next line.
// Author:  <your name>
// Date:    <date>
///////////////////////////////////////////////////////////////////////

module msgrom (input  logic [3:0] Addr,
               output logic [7:0] Char);

  always_comb
    case (Addr)
      4'd0:    Char = 8'h48;  // H
      4'd1:    Char = 8'h65;  // e
      // TODO: addresses 2 to 11, the rest of "llo World!"
      4'd12:   Char = 8'h0D;  // carriage return
      4'd13:   Char = 8'h0A;  // line feed
      default: Char = 8'h00;
    endcase

endmodule

module BranchComp(
    output logic BrEq, BrLT,
    input logic [31:0] RD1, RD2,
    input logic BrUn              // 1 at Unsigned compare
);

   logic	  NotEqual;
   logic [31:0] XORResult;
// Equal part

   assign XORResult = (RD1 ^ RD2);
   assign NotEqual = |XORResult;

   assign BrEq = ~NotEqual;

// COMP part
   COMP32b COMPARE(BrLT, RD1, RD2, BrUn);

endmodule
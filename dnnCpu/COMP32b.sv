module COMP32b(    // unsigned
    output Less,
    input [31:0] A, B,
    input uMod      // 1:UnsignedMode, 0:SignedMode
);

   wire [31:0] ubitCompare;   // unsigned
   wire [31:0] sbitCompare;
   wire	    uresult, sresult;
   wire	SignCompare;
   genvar i;

   assign uresult = |ubitCompare;
   assign sbitCompare = {SignCompare, ubitCompare[30:0]};
   assign sresult = |sbitCompare;

   assign Less = ~(uMod ? uresult : sresult);

   assign SignCompare = (A[31] == B[31]) ? 1'b0 : ((A[31]) ? 1'b0 : 1'b1);
   for(i = 0; i < 32; i = i + 1) begin
      assign ubitCompare[i] = (A[i] == B[i]) ? 1'b0 : ((A[i]) ? 1'b1 : 1'b0);
   end
   
endmodule
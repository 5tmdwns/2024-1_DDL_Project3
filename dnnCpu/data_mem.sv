module data_mem(
    output logic [31:0] ReadData,
    input logic  [31:0] ADDR, WriteData,
    input logic  clk, rst, MemWrite
);

   reg [7:0] MEM_Data [0:254*4];

   assign ReadData = {MEM_Data[ADDR+3], MEM_Data[ADDR+2], MEM_Data[ADDR+1], MEM_Data[ADDR+0]};

   always @ (posedge clk) begin
       if (MemWrite) begin
          MEM_Data[ADDR+3] <= WriteData[31-:8];
          MEM_Data[ADDR+2] <= WriteData[23-:8];
          MEM_Data[ADDR+1] <= WriteData[15-:8];
          MEM_Data[ADDR+0] <= WriteData[7-:8];
       end
   end

endmodule
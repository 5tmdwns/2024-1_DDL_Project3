module dnn_cpu(
    output logic [31:0] WB_o,
    input logic  [31:0] inst_data, 
    input logic  [6:0]  inst_addr,
    input logic  clk, rst, inst_wen, enb
);

   logic [8:0] PC;
   logic [31:0] Imm, instruction, instruction_to_dnn, WB, DataA, DataB, WB_cut;
   logic [31:0] DMEM, WB_Half, WB_Byte, RD3, RD4;
   logic	    PCsel, RegWEn, BrUn, ASel, BSel, MemRW, BrEq, BrLT;
   logic [1:0]  WBSel, DnnSel;
   logic [2:0]  ImmSel, WordSizeSel;
   logic [3:0]  ALUSel;

   logic [8:0]  PC_Next;
   logic [8:0]  PCp4 = PC + 7'd4;

   logic [31:0] ALU_o, ALU_A, ALU_B, WDD;

   logic [15:0] x1, x2, x3, w1, w2, w3, f;
   logic done1, done2, done3, neuron_done, ready, DnnWrite, notPC;
   logic [4:0] WR2;

   always_comb begin
    PC_Next = PCsel ? ALU_o : PCp4;
    ALU_A = ASel ? PC : DataA;
    ALU_B = BSel ? Imm : DataB;

    WB = (WBSel == 2'd2) ? PCp4 : ((WBSel == 2'd1) ? ALU_o : DMEM);
    WB_Half = WordSizeSel[2] ? {16'b0, WB[15:0]} : {{16{WB[15]}}, WB[15:0]};
    WB_Byte = WordSizeSel[2] ? {24'b0, WB[7:0]}  : {{24{WB[7]}},  WB[7:0]};
    WB_cut = (WordSizeSel[1:0] == 2'b0) ? WB_Byte : ((WordSizeSel[1:0] == 2'b1) ? WB_Half : WB);
   end

   inst_mem IMEM(.inst(instruction),
    .inst_data(inst_data),
    .PC(PC[8 -: 7]), .inst_addr(inst_addr),
    .clk(clk), .rst(rst), .inst_wen(inst_wen), .ready(ready)
	);

   register_file REGFILE(
    .RD1(DataA), .RD2(DataB), .RD3(RD3), .RD4(RD4), 
    .RR1(instruction[19:15]), .RR2(instruction[24:20]), .RR3(instruction[16:12]), .RR4(instruction[11:7]),
    .WR(instruction[11:7]), .WR2(WR2), .DnnSel(DnnSel),
    .WD(WB_cut), .WDD(WDD),       
    .RegWrite(RegWEn), .clk(clk), .rst(rst), .DnnWrite(DnnWrite)
	);

   BranchComp BrCOMP(
    .BrEq(BrEq), .BrLT(BrLT),
    .RD1(DataA), .RD2(DataB), 
    .BrUn(BrUn)
		  );

   ImmGen IMMGEN(
    .Imm(Imm),
    .inst_Imm(instruction[31:7]),
    .ImmSel(ImmSel)
	      );

   data_mem DATAMEM(
    .ReadData(DMEM),
    .ADDR(ALU_o), .WriteData(DataB),
    .clk(clk), .rst(rst), .MemWrite(MemRW)
		 );

   control CTRL(
    .PCsel(PCsel), .RegWEn(RegWEn), .BrUn(BrUn),
    .ImmSel(ImmSel), .WordSizeSel(WordSizeSel),
    .BSel(BSel), .ASel(ASel), .MemRW(MemRW), 
    .ALUSel(ALUSel), .DnnSel(DnnSel),
    .WBSel(WBSel),
    .instruction(instruction), .instruction_to_dnn(instruction_to_dnn),
    .BrEq(BrEq), .BrLT(BrLT), .clk(clk)
	     );

   ALU ALU_riscV(
    .ALU_o(ALU_o),
    .A(ALU_A), .B(ALU_B), .ALUSel(ALUSel)
	      );

    cpu_wire_dnn cwd(
        .WDD(WDD),
        .x1(x1), .x2(x2), .x3(x3), .w1(w1), .w2(w2), .w3(w3),
        .WR2(WR2),
        .DnnWrite(DnnWrite), .notPC(notPC), .done1(done1), .done2(done2), .done3(done3),
        .instruction(instruction_to_dnn), .RD3(RD3), .RD4(RD4), .y(f), .DnnSel(DnnSel),
        .neuron_done(neuron_done), .ready(ready), .clk(clk)
    );

    neuron_top neu(
        .clk(clk), .reset(rst),
        .x1(x1), .x2(x2), .x3(x3),
        .w1(w1), .w2(w2), .w3(w3),
        .done1(done1), .done2(done2), .done3(done3),
        .ready(ready),
        .neuron_done(neuron_done),
        .f(f)
    );

   always @ (posedge clk) begin
       if (rst) begin
	      PC <= 9'b0;
       end
       else if (enb) begin
        if (notPC) begin
            PC <= PC;
        end
        else
          PC <= PC_Next;
       end
   end

endmodule
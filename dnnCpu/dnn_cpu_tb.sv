`timescale 1ns/1ps
`include "ALU.sv"
`include "BranchComp.sv"
`include "buffer.sv"
`include "COMP32b.sv"
`include "control.sv"
`include "cpu_wire_dnn.sv"
`include "data_mem.sv"
`include "div11x11.sv"
`include "dnn_cpu.sv"
`include "fadd.sv"
`include "fdiv.sv"
`include "fmul.sv"
`include "ImmGen.sv"
`include "inst_mem.sv"
`include "mult11x11.sv"
`include "neuron_control.sv"
`include "neuron_top.sv"
`include "register_file.sv"
`include "sigmoid.sv"

module dnn_cpu_tb();

reg clk, rst, inst_wen, enb;
reg [31:0] inst_data;
reg [6:0] inst_addr;
wire [31:0] WB_o;

initial begin
    rst = 1;
    clk = 1;
    inst_wen = 0;
    inst_addr = 0;
    inst_data = 0;
    #11
    rst = 0;
    #10
    enb = 1;
    $readmemh("/home/ddl2024_1/ddl2024_2021110119/systemv_folder/prj3/code2.txt", TEST.IMEM.inst_reg);
    #3569
    $display("%32h", {TEST.DATAMEM.MEM_Data[87], TEST.DATAMEM.MEM_Data[86], TEST.DATAMEM.MEM_Data[85], TEST.DATAMEM.MEM_Data[84]});
    // $display("%32h", TEST.DATAMEM.MEM_Data[88]);
    // $display("%32h", TEST.DATAMEM.MEM_Data[56]);
    // $display("%32h", TEST.DATAMEM.MEM_Data[57]);
end

dnn_cpu TEST(
    WB_o, inst_data, inst_addr, clk, rst, inst_wen, enb
);

always #5 clk <= ~clk;

endmodule
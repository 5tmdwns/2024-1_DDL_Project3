`timescale 1ns/1ns
`include "neuron_top.v"
`include "fmul.v"
`include "mult11x11.v"
`include "fadd.v"
`include "neuron_control.v"
`include "buffer.v"
`include "sigmoid.v"
`include "fdiv.v"
`include "div11x11.v"
module neuron_top_tb;
    reg clk, reset;
    reg [15:0] x1, x2, x3, w1, w2, w3;
    reg done1, done2, done3;
    wire neuron_done;
    wire [15:0] f;

    reg [15:0] w_mem[0:24];

    initial
        begin
            $display("Reading Rom");
            $readmemb("weight.txt", w_mem);
        end //weight.txt의 값을 w_mem에 저장한다

    neuron_top i0(clk, reset, x1, x2, x3, w1, w2, w3, done1, done2, done3, neuron_done,f);

    always
        #10 clk=~clk;

    initial
        begin
            $dumpfile ("neuron_top_tb.vcd");
            $dumpvars (0, neuron_top_tb);
            clk=0;
            x1=16'b0_00010_0000011100;
            w1=16'b0_00001_0000011010;
            x2=16'b0_00011_0010100001;
            w2=16'b0_00110_0010001101;
            x3=16'b0_00111_0000011111;
            w3=16'b0_01000_1100111111;
            done1=1;
            done2=1;
            done3=1;
            reset=1;
            #40 reset=0;
            #10000;
            $finish;
        end // initial begin

endmodule // neuron_top_tb
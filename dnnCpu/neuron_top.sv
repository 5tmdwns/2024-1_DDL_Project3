module neuron_top(clk, reset, x1, x2, x3, w1, w2, w3, done1, done2, done3, ready, neuron_done, f);
    input logic clk, reset;
    input logic [15:0] x1, x2, x3;
    input logic [15:0] w1, w2, w3;
    input logic done1, done2, done3;
    output logic ready;
    output logic neuron_done;
    output logic [15:0] f;

    logic [15:0] zero=16'b0_00000_0000000000;

    logic [1:0] sel;
    logic mul_done, add_done, sig_done;
    logic mul_enable, add_enable, sig_enable;
    logic buf_rst, mul_rst, add_rst, sig_rst, nueron_done;
    logic [15:0] x, w;
    logic v1, ovf, unf;
    logic [15:0] f1, sigout;


    neuron_control neur(clk, reset, ready, mul_done, add_done, sig_done, sel,
    mul_enable, add_enable, sig_enable, buf_rst, mul_rst, add_rst, sig_rst,
    nueron_done);

    fmul mul1(clk, mul_rst, mul_enable, x, w, v1, f1, mul_done);

    fadd add1(clk, add_enable, add_rst, add_done, ovf, unf, f1, zero , sigout);

    buffer buff(clk, reset, x1, x2, x3, w1, w2, w3, done1, done2, done3, sel, nueron_done, x, w, ready);

    sigmoid sigm(clk, reset, sig_enable, sigout, f, neuron_done);

endmodule // neuron_top
module neuron_top(clk, reset, x1, x2, x3, w1, w2, w3, done1, done2, done3,
neuron_done, f);
    input clk, reset;
    input [15:0] x1, x2, x3;
    input [15:0] w1, w2, w3;
    input done1, done2, done3;
    output wire neuron_done;
    output wire [15:0] f;

    reg [15:0] zero=16'b0_00000_0000000000;

    wire [1:0] sel;
    wire ready, mul_done, add_done, sig_done;
    wire mul_enable, add_enable, sig_enable;
    wire buf_rst, mul_rst, add_rst, sig_rst, nueron_done;
    wire [15:0] x, w;
    wire v1, ovf, unf;
    wire [15:0] f1, sigout;

    neuron_control neur(clk, reset, ready, mul_done, add_done, sig_done, sel,
    mul_enable, add_enable, sig_enable, buf_rst, mul_rst, add_rst, sig_rst,
    nueron_done);

    fmul mul1(clk, mul_rst, mul_enable, x, w, v1, f1, mul_done);

    fadd add1(clk, add_enable, add_rst, add_done, ovf, unf, f1, zero , sigout);

    buffer buff(clk, reset, x1, x2, x3, w1, w2, w3, done1, done2, done3, sel, x, w, ready);

    sigmoid sigm(clk, reset, sig_enable, sigout, f, neuron_done);

endmodule // neuron_top
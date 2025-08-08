module sigmoid(clk,reset,enable, h1, out_h,done);
    input clk,reset,enable;
    input [15:0] h1;
    output [15:0] out_h;
    output done;

    reg [15:0] out_h;
    reg done;
    reg signed [4:0] e1;
    reg signed [4:0] e2;//<=5'b11111;
    reg signed [4:0] e;
    reg [15:0] in_one=16'b0_00000_0000000000;//1표현
    //adder1
    wire [15:0] one_plus_x;//adder_output
    wire a_done, ovf1, unf1;
    //divider
    wire [15:0] div_output;// x/1+abs(x)
    wire d_done;
    //adder2
    wire [15:0] plus_div_output; //2sigmoid
    wire aplus_done, ovf2, unf2;
    //입력값을 절댓값 취한다
    reg [15:0] abs_add_value;

    always@(*)
        begin
            if(h1[15]==1)
                abs_add_value<={1'b0, h1[14:0]};
            else
                abs_add_value<=h1;
        end
    //enable 신호 컨트롤

    reg [2:0] state;
    reg d_enable, a_enable;
    reg d_reset, a_reset;

    always@(posedge clk)
        begin
            if(reset)
                begin
                    state<=0;
                    d_enable<=0;
                    a_enable<=0;
                    d_reset<=1;
                    a_reset<=1;
                    done<=0;
                    e1<=5'b00000;
                    e2<=5'b11111;
                    e<=5'b00000;
                    out_h<=0;
                end
            else
                begin
                    state<=state;
                    case(state)
                        0:begin
                            d_reset<=0;
                            a_reset<=0;
                            if(a_done==1)
                                begin
                                // d_reset<=1;
                                    state<=1;
                                end
                            else//a_done!=1
                                state<=state;
                        end

                        1:begin
                            // d_reset<=0;
                            d_enable<=1;
                            state<=2;
                        end

                        2:begin
                            if(d_done==1)
                                begin
                                    d_enable<=0;
                                    // a_reset<=1;
                                    state<=3;
                                end
                            else//d_done==0
                                state<=state;
                        end

                        3:begin
                            // a_reset<=0;
                            a_enable<=1;
                            state<=4;
                        end

                        4:begin
                            if(aplus_done==1)
                                begin
                                    e1<=plus_div_output[14:0];//10
                                    state<=5;
                                    e<=e1+e2;
                                end
                            else
                                state<=state;
                        end

                        5:begin
                            out_h<={plus_div_output[15],e,plus_div_output[9:0]};
                            done<=1;
                            state<=6;
                        end
                    endcase // case (state)
                end // else: !if(reset)
        end // always@ (posedge clk)

    fadd fadder(clk,enable,reset,a_done,ovf1,unf1,in_one,abs_add_value,one_plus_x);
    fdiv fdivid(clk,d_reset,d_enable,h1,one_plus_x,div_output,d_done);
    //d_reset이 divider를 reset시키고, d_enable신호가 divider를 동작시킨다...
    fadd fadder2(clk, a_enable, a_reset, aplus_done, ovf2, unf2, in_one,
    div_output,/*out_h*/ plus_div_output);
    //a_reset신호가 adder를 reset시키고, a_enable신호가 adder를 동작시킨다...
endmodule // sigmoid
module neuron_control(clk, reset, ready, mul_done, add_done, sig_done,sel, mul_enable,
add_enable, sig_enable,buf_rst,mul_rst,add_rst, sig_rst, nueron_done);
    input logic clk, reset, ready, mul_done, add_done, sig_done;
    output logic [1:0] sel;
    output logic mul_enable,add_enable,sig_enable;
    output logic buf_rst, mul_rst, add_rst, sig_rst, nueron_done;

    logic [3:0] state;

    always@(posedge clk)
        if (reset)
            begin
                state<=0;
                sel=0;
                mul_enable=0;
                add_enable=0;
                sig_enable=0;
                buf_rst=1;
                mul_rst=1;
                add_rst=1;
                sig_rst=1;
                nueron_done=0;
            end
        else
            begin
                case (state)
                    0:begin
                        buf_rst=0;
                        mul_rst=0;
                        add_rst=0;
                        sig_rst=0;
                        if(ready)
                            begin
                                state<=1;
                                sel=1; //x1, w1 을 곱해라
                                mul_enable=1;
                            end
                    end

                    1:begin
                        if(mul_done)//곱셈종료
                            begin
                                state <=2;
                                sel=0;
                                mul_rst=1;
                                mul_enable=0;
                                add_enable=1;
                            end
                    end

                    2:begin //rst을 끄기위해
                        mul_rst=0;
                        state<=3;
                    end

                    3:begin
                        if(add_done) //덧셈 종료, 덧셈기 리셋, 곱셈시작
                            begin
                                add_enable=0;
                                add_rst=1;
                                sel=2;
                                mul_enable=1;
                                state <= 4;
                            end
                    end

                    4:begin //rst을 끄기위해
                        add_rst=0;
                        state<=5;
                    end

                    5:begin
                        if(mul_done) //곱셈 종료, 덧셈시작
                            begin
                                state <= 6;
                                sel=0;
                                mul_rst=1;
                                mul_enable=0;
                                add_enable=1;
                            end
                        end

                    6:begin //rst을 끄기위해
                        mul_rst=0;
                        state<=7;
                    end

                    7:begin
                        if(add_done) //덧셈 종료, 덧셈기 리셋, 곱셈시작
                            begin
                                add_enable=0;
                                add_rst=1;
                                sel=3;
                                mul_enable=1;
                                state <=8;
                            end
                    end

                    8:begin
                        add_rst=0;
                        state<=9;
                    end

                    9:begin
                        if(mul_done) //곱셈 종료, 덧셈시작
                            begin
                                state <= 10;
                                sel=0;
                                mul_rst=1;
                                mul_enable=0;
                                add_enable=1;
                            end
                    end

                    10:begin //리셋종료
                        mul_rst=0;
                        state<=11;
                    end

                    11:begin
                        if(add_done) //덧셈 종료, 덧셈기 리셋, 시그모이드 연산시작
                            begin
                                add_enable=0;
                                add_rst=1;
                                sig_enable=1;
                                state <= 12;
                            end
                    end

                    12:begin //rst를 끄기위해
                        add_rst=0;
                        state<=13;
                    end

                    13:begin
                        if(sig_done)
                            begin
                                sig_enable=0;
                                sig_rst=1;
                                state<=14;
                            end
                    end

                    14:begin
                        sig_rst=0;
                        nueron_done=1; //13번 state에서 해도될지도?
                        state <= 15;
                    end

                    15:begin //초기화
                        state<=0;
                        sel=0;
                        mul_enable=0;
                        add_enable=0;
                        sig_enable=0;
                        buf_rst=1;
                        mul_rst=1;
                        add_rst=1;
                        sig_rst=1;
                        nueron_done=0;
                    end
                endcase
            end
            
endmodule
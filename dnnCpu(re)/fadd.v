module fadd(clk, st, reset, done, ovf, unf, sig1, sig2, sigout);
    input clk, st, reset; //클록과 스타트 신호 리셋신호
    output done, ovf, unf;
    input [15:0] sig1, sig2;
    output [15:0] sigout;

    reg [15:0] sigout;
    reg done, ovf, unf; //완료, 지수 오버플로우, 지수 언더플로우
    reg signed [5:0] e1,e2;
    reg signed [5:0] over, under;
    reg [12:0] f1,f2;
    reg s1,s2;

    wire [14:0] f1comp;
    wire [14:0] f2comp;
    wire [14:0] addout;
    wire [14:0] fsum;
    wire fv,fu; //기수 오버플로우, 기수 부호비트 판단

    reg [2:0] state;

    assign f1comp = (s1==1'b1) ? ~({2'b00, f1})+1 : {2'b00, f1};
    assign f2comp = (s2==1'b1) ? ~({2'b00, f2})+1 : {2'b00, f2};
    assign addout = f1comp + f2comp;
    assign fsum = ( (addout[14]) == 1'b0) ? addout : ~addout+1;
    assign fv = fsum[14] ^ fsum[13];
    assign fu = ~f1[12];

    always@(posedge clk)
        begin
            if(reset)
                begin
                    e1<=0;
                    e2<=0;
                    f1<=0;
                    f2<=0;
                    s1<=0;
                    s2<=0;
                    state<=0;
                    done<=0;
                    ovf<=0;
                    unf<=0;
                    under<=6'b110000;
                    over<=6'b001111;
                    sigout<=16'b0_00000_0000000000;
                end // if (reset)
            else
                begin
                    case (state)
                        0 : begin
                            if(st==1)
                                begin
                                    f1<={sig1[9:0], 2'b00};
                                    f2<={sig2[9:0], 2'b00};
                                    if(sig1[14]==0)
                                        e1<={2'b0, sig1[14:10] };
                                    else
                                        e1<={2'b1, sig1[14:10] };
                                    if(sig2[14]==0)
                                        e2<={2'b0, sig2[14:10] };
                                    else
                                        e2<={2'b1, sig2[14:10] };
                                        s1<=sig1[15];
                                        s2<=sig2[15];
                                    if(sig1==0)
                                        begin
                                            f1[12]<=1'b1;//1'b0->1'b1 6/23수정
                                        end
                                    else
                                        begin
                                            f1[12]<=1'b1;
                                        end
                                    if(sig2==0)
                                        begin
                                            f2[12]<=1'b1; //1'b0->1'b1
                                        end
                                    else
                                        begin
                                            f2[12]<=1'b1;
                                        end
                                    done<=1'b0;
                                    ovf<=1'b0;
                                    unf<=1'b0;
                                    state<=1;
                                end // if (st==1)
                        end // case: 0

                        1 : begin
                            if(e1==e2)
                                begin
                                    state<=2;
                                end
                            else if(e1<e2)
                                begin
                                    if(e2-e1>8)//지수차이 많이나면 쉬프트 의미x
                                        begin
                                            f1<=f2;
                                            e1<=e2;
                                            state<=5;
                                        end
                                    else
                                        begin
                                            f1<={1'b0, f1[12:1]};
                                            e1<=e1+1;
                                        end
                                end
                            else
                                begin
                                    if(e1-e2>8)//지수 차이 많이 나면 쉬프트 의미x
                                        begin
                                            state<=5;
                                        end
                                    else
                                        begin
                                            f2<={1'b0, f2[12:1]};
                                            e2<=e2+1;
                                    end
                                end
                        end // case: 1

                        2 : begin
                            s1<=addout[14];
                            if(fv==1'b0) //정상동작인경우 fsum의 2개의 부호비트는 00이라서 버린후 f1에 다시 저장한다
                                begin
                                    f1<=fsum[12:0];
                                end
                            else //기수 오버플로우 fv=1, fsum의 부호비트가 01인 경우라서 xor로 판단하여 조건준다. 오버플로우라면 쉬프트하고 지수 1 증가
                                begin
                                    f1<=fsum[13:1];
                                    e1<=e1+1;
                                end
                            state<=3;
                        end

                        3:begin
                            if(f1==0)//덧셈결과가 0이면 10~~이므로 지수 1 상승해야함
                                begin
                                    e1<=e1+1;
                                    state<=5;
                                end
                            else //덧셈결과 0 아니라면 state 변경
                                begin
                                    state<=4;
                                end
                        end

                        4 : begin
                            if(e1<under) //지수의 범위가 -16~15이므로 지수가 -17이라면 언더플로이다
                                begin
                                    unf<=1'b1;
                                    state<=5;
                                end
                            else if(fu==1'b0) //f1 (이전엔 fsum)의 최상위 비트값이 1이면 된다... (정규화된 상황을 의미)
                                begin
                                    state<=5;
                                end
                            else //f1이 정규화 되지 않았다면 왼쪽 시프트를 통해 정규화하고 지수를 줄인다
                                begin
                                    f1<={f1[11:0],1'b1};
                                    e1<=e1-1;
                                end
                        end

                        5: begin
                            if(e1>over) //지수가 15이상이라면 지수 오버플로이므로 ovf=1
                                begin
                                    ovf<=1'b1;
                                    state<=0;
                                end
                            else
                                begin
                                    done<=1'b1;
                                    sigout<={s1,e1[4:0],f1[11:2]};
                                    state<=0;
                                end
                        end // case: 5
                        
                        /*6: begin
                        mul_reg<=mul_reg+sigout;
                        state<=0;
                        end*/
                    endcase // case (state)
                end // else: !if(reset)
        end
endmodule
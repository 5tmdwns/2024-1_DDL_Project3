module fmul(clk, reset, enable, f1,f2, v, f, done);
    input logic clk, reset;
    input logic enable;
    input logic [15:0] f1, f2;
    output logic done,v;
    output logic [15:0] f;

    logic st;
    logic s1,s2;
    logic [4:0] e1,e2;
    logic [5:0] ee;

    logic [9:0] ff1, ff2;

    assign ff1=f1[9:0];
    assign ff2=f2[9:0];

    logic [21:0] mulf;
    logic mdone;

    logic [10:0] reg_f;

    localparam M=26;

    logic [2:0] state, nextstate;

    mult11x11 i0 (clk,reset,st,ff1,ff2,mdone,mulf);

    always@(posedge clk) //state
        begin
            if(reset)
                begin
                    state<=0;
                    st=0;
                    v=0;
                    done=0;
                end
            else begin
                case(state)
                    0: if(enable)
                        begin
                            state<=1;
                            st=1;
                        end
                    else
                        begin
                            state<=state;
                            st=0;
                        end

                    1: begin
                        st=0;
                        if(mdone)
                            begin
                                if(mulf[21] || (mulf[21]&~mulf[20]))//정규화 필요
                                    begin
                                        state<=2;//정규화단계
                                    end
                                else //정규화 필요없으면
                                    state<=3; //오버플로 검출단계
                            end
                        else
                            begin
                                state<=state;
                            end
                    end

                    2: //지수 한칸 옮기는 단계
                        state <= 3; //정규화 끝

                    3: //오버플로 검사
                        if(ee[5]!=ee[4])
                            v=1;
                        else
                            begin
                                v=0;
                                state<=4;
                            end
                        
                    4:if(v)
                        done=0;
                    else
                        done=1;
                endcase
            end
        end

            always@(posedge clk) //sign
                begin
                    if(reset)
                        f[15]=0;
                    else
                        begin
                            f[15]=0;
                            if(state==4) //출력
                                f[15]=f1[15]^f2[15];
                        end
                end

            always@(posedge clk) //ee
                begin
                    if(reset)
                        ee<=0;
                    else
                        begin
                            ee<=ee;
                            case (state)
                                0: begin
                                    ee<=0;
                                end

                                1:begin
                                    ee<={f1[14],f1[14:10]} + {f2[14],f2[14:10]};
                                end

                                2:begin //정규화
                                    ee<=ee+1;
                                end
                            endcase
                        end
                end

            always@(posedge clk) //지수부 가수부
                begin
                    if(reset)
                        begin
                            f[14:0]=0;
                            reg_f=0;
                        end
                    else
                        begin
                            f[14:0]=0;
                            case (state)
                                0:reg_f=0;
                                1:reg_f=mulf[20:10];
                                2:reg_f=reg_f>>1;
                            endcase
                            if(state==4) //출력
                                begin
                                    f[14:10] = ee[4:0];
                                    f[9:0] = reg_f[9:0];
                                end
                        end
                end
                
endmodule
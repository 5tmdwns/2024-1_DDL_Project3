module fdiv(clk, reset, enable, f1,f2,f,done);
    input logic clk, reset;
    input logic enable;
    input logic [15:0] f1, f2;
    output logic done;
    output logic [15:0] f;

    logic st;
    logic s1,s2;
    logic [4:0] e1,e2;
    logic [5:0] ee;
    logic [2:0] state, nextstate;

    logic ddone;
    logic [10:0] divf;

    logic [10:0] reg_f;

    logic [9:0] ff1, ff2;

    assign ff1=f1[9:0];
    assign ff2=f2[9:0];

    div11x11 i0(clk, reset,st,ff1,ff2,ddone, divf);

    always@(posedge clk) //state
        begin
            if(reset)
                begin
                    state<=0;
                    st=0;
                    done=0;
                end
            else
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
                        if(ddone)
                            begin
                                if(~divf[10])//정규화 필요
                                    begin
                                        state<=2;//정규화단계
                                    end
                                else //정규화 필요없으면
                                    state<=3;
                            end
                        else
                            begin
                                state<=state;
                            end
                    end

                    2: //지수 한칸 옮기는 단계
                        state <= 3; //정규화 끝

                    3:begin
                        done=1;
                    end

                endcase
        end

    always@(posedge clk) //sign
        begin
            if(reset)
                f[15]=0;
            else
                begin
                    f[15]=0;
                    if(state==3)
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
                            ee<={f1[14],f1[14:10]} - {f2[14],f2[14:10]};
                        end

                        2:begin //정규화
                            ee<=ee-1;
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
                        1:reg_f=divf;
                        2:reg_f=reg_f<<1;
                    endcase
                if(state==3) //출력
                    begin
                        f[14:10] = ee[4:0];
                        f[9:0] = reg_f[9:0];
                    end
                end
        end
        
endmodule
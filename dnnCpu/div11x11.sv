module div11x11(clk, reset, st, f1, f2, done, f);
    input logic clk, reset, st;
    input logic [9:0] f1, f2; // f1/f2할거임
    output logic done;
    output logic [10:0] f;

    logic [10:0] quotient;

    logic q;
    logic [9:0] r;

    assign q = quotient[10];
    assign r = quotient[9:0];
    assign f = {q,r[9:0]};

    logic [1:0] main_state;
    logic [1:0] state; //각 나눗셈 과정 상태를 나타냄
    logic [21:0] remainder;
    logic [21:0] divisor;
    logic [3:0] count;
    logic div_done;

    always@(posedge clk) //main_state
        begin
            if(reset)
                begin
                    main_state<=0;
                end
            else
                begin
                    if(st && main_state==0)
                        main_state<=1;
                    if(main_state==1 && count == 11)
                        main_state<=2;
                    if(main_state==2 && st)
                        main_state<=0;
                end
        end

    always@(main_state) //done
        begin
            done=0;
            if(main_state==2)
                done=1;
        end

    always@(posedge clk) //state, divisor, remainder, count, div_done
        begin
            if(reset)
                begin
                    state<=0;
                    divisor=0;
                    remainder=0;
                    count=0;
                    div_done=0;
                end
            else if (main_state==1)
                begin
                    state<=1;
                    if(state==0)
                        begin
                            remainder=0;
                            remainder[21]=1;
                            remainder[20:11]=f1; //dividen
                            divisor=0;
                            divisor[21]=1;
                            divisor[20:11]=f2; //divisor
                            quotient=0; //몫 초기화
                            count=0;
                            state <= 1;
                        end
                    if(state==1)
                        begin
                            if(count==11)
                                state<=0;
                            else
                                begin
                                    remainder = remainder - divisor;
                                    state <= 3;
                                    quotient = quotient << 1;
                                    quotient[0]=1;
                                    count = count + 1;
                                    if(remainder[21]==1) //복구필요
                                        begin
                                            state <= 2;
                                            quotient[0]=0;
                                        end
                                end
                        end
                    if(state==2)
                        begin
                            remainder = remainder + divisor; //복구
                            state <= 3;
                        end
                    if(state==3) //shift 함.
                        begin
                            divisor = divisor >> 1;
                            state <=1;
                        end
                end
        end
        
endmodule
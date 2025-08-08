`define M ACC[0]

module mult11x11 (clk,reset,st,f1,f2,done,result);
    input logic clk,reset, st;
    input logic [9:0] f1, f2;
    output logic done;
    output logic [21:0] result;

    logic [22:0] ACC;
    logic [3:0] count;
    logic [3:0] loop_count;
    logic started;

    logic [10:0] mplier, mcand;

    assign mplier = {1'b1,f1};
    assign mcand = {1'b1,f2};

    always@(posedge clk)
        begin
            if (reset)
                begin
                    ACC=0;
                    result=0;
                    done=0;
                    count=0;
                    loop_count=0;
                    started=0;
                end
            else
                begin
                    if (st==1)
                        started<=1;
                    if (st || started)
                        begin
                            count<=count+1;
                            if (count==0)
                                begin
                                    ACC[10:0]<=mplier;
                                end
                            else if (count==1)
                                begin
                                    if (`M==1)
                                        ACC[22:11]<=ACC[22:11]+mcand;
                                end
                            else if (count==2)
                                begin
                                    ACC<=ACC>>1;
                                    if (loop_count<10)
                                        count<=1;
                                    loop_count<=loop_count+1;
                                end
                            else if (count==10)
                                begin
                                    result<=ACC[21:0];
                                    done<=1;
                                    started<=0;
                                    count<=0;
                                end
                        end // if (st || started)
                end // else: !if(reset)
        end // always@ (posedge clk)

endmodule // mult11x11
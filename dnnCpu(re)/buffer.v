module buffer(clk,reset,x1,x2,x3,w1,w2,w3,done1,done2,done3,sel,x,w, ready);
    input clk, reset;
    input [15:0] x1,x2,x3,w1,w2,w3;
    input done1,done2,done3;
    input [1:0] sel;
    output reg [15:0] x,w;
    output ready;

    reg [15:0] reg_x1, reg_x2, reg_x3;
    reg reg_1,reg_2,reg_3;

    assign ready = reg_1&reg_2&reg_3;

    always@(posedge clk) begin //reg_x1, reg_x2, reg_x3, reg_1, reg_2, reg_3
        if(reset)
            begin
                reg_x1 <=0;
                reg_x2 <=0;
                reg_x3 <=0;
                reg_1 <= 0;
                reg_2 <= 0;
                reg_3 <= 0;
            end
        else
            begin
                reg_x1 <= reg_x1;
                reg_x2 <= reg_x2;
                reg_x3 <= reg_x3;
                reg_1 <= reg_1;
                reg_2 <= reg_2;
                reg_3 <= reg_3;
                if(done1)
                    begin
                        reg_x1 <= x1;
                        reg_1 <= 1;
                    end
                if(done2)
                    begin
                        reg_x2 <= x2;
                        reg_2 <= 1;
                    end
                if(done3)
                    begin
                        reg_x3 <= x3;
                        reg_3 <= 1;
                    end
                if(reg_1 && reg_2 && reg_3)
                    begin
                        reg_1 <=0;
                        reg_2 <=0;
                        reg_3 <=0;
                    end
            end
    end

    always@(*) //x, w
        begin
            x=0;
            w=0;
            case (sel)
                0:begin
                    x =0;
                    w = 0;
                end

                1:begin
                    x=x1;
                    w=w1;
                end

                2:begin
                    x=x2;
                    w=w2;
                end

                3:begin
                    x=x3;
                    w=w3;
                end
            endcase
        end
        
endmodule
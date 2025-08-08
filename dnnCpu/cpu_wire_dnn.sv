module cpu_wire_dnn(
    output logic [31:0] WDD,
    output logic [15:0] x1, x2, x3, w1, w2, w3,
    output logic [4:0] WR2,
    output logic DnnWrite = 0, notPC = 0, done1, done2, done3,
    input logic [31:0] instruction, RD3, RD4, 
    input logic [15:0] y,
    input logic [1:0] DnnSel,
    input logic neuron_done, ready, clk
);

always@ (posedge clk) begin
    if (DnnSel == 1) begin
        if (instruction[18] == 0) begin
            if (instruction[17] == 0) begin
                x1 <= {RD3[11:0], 4'b0000};
                x2 <= {RD4[11:0], 4'b0000};
                done1 <= 1;
                done2 <= 1;
            end
            else if (instruction[17] == 1) begin
                x3 <= {RD3[11:0], 4'b0000};
                done3 <= 1;
            end
        end
        else if (instruction[18] == 1) begin
            if (instruction[17] == 0) begin
                w1 <= {RD3[11:0], 4'b0000};
                w2 <= {RD4[11:0], 4'b0000};
            end
            else if (instruction[17] == 1) begin
                w3 <= {RD3[11:0], 4'b0000};
            end
        end
    end
    else if (DnnSel == 2) begin
        notPC <= 0;
        if(neuron_done == 1) begin
            DnnWrite <= 1;
            WR2 <= instruction[12:7];
            WDD <= y;        
        end
    end
    else if (ready == 1) begin
        notPC <= 1;
    end
end

endmodule
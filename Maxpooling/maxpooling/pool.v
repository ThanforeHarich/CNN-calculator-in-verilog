module pool (
    input clk,
    input rstn,

    input [7:0] data0,
    input [7:0] data1,
    input [7:0] data2,
    input [7:0] data3,
    input data_valid,
    output data_ready,

    output reg [7:0] ans_data,
    output reg ans_valid,
    input ans_ready
);
    parameter pool_idle = 3'd0;
    parameter pool_work1 = 3'd1;
    parameter pool_work2 = 3'd2;
    parameter pool_wait = 3'd3;
    parameter pool_send = 3'd4;
    reg [2:0] state, nextstate;
    reg [7:0] data_reg1;
    reg [7:0] data_reg2;

    assign data_ready = (nextstate == pool_work1);
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            ans_data <= 0;
            ans_valid <= 0;
            data_reg1 <= 0;
            data_reg2 <= 0;
        end
        else case (nextstate)
            pool_work1: begin
                data_reg1 <= (data0>data1)? data0: data1;
                data_reg2 <= (data2>data3)? data2: data3;
            end
            pool_work2: begin
                ans_data <= (data_reg1>data_reg2)? data_reg1: data_reg2;
                ans_valid <= 1;
            end
            pool_send: begin
                ans_valid <= 0;
            end
            pool_idle: begin
                ans_data <= 0;
                ans_valid <= 0;
                data_reg1 <= 0;
                data_reg2 <= 0;
            end
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn)
            state <= pool_idle;
        else
            state <= nextstate;
    end

    always @(*) begin
        case (state)
            pool_idle:
                if (data_valid)
                    nextstate = pool_work1;
                else
                    nextstate = pool_idle;
            pool_work1:
                    nextstate = pool_work2;
            pool_work2:
                if (ans_ready)
                    nextstate = pool_send;
                else
                    nextstate = pool_wait;
            pool_wait:
                if (ans_ready)
                    nextstate = pool_send;
                else
                    nextstate = pool_wait;
            pool_send:
                if (data_valid)
                    nextstate = pool_work1;
                else
                    nextstate = pool_idle;
        endcase
    end

endmodule //pool
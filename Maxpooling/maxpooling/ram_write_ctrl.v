module ram_write_ctrl #(
    parameter H = 6,
    parameter W = 6
)(
    input clk,
    input rstn,

    output reg intr,

    input [7:0] ans,
    input valid,
    output ready,

    output ram_en,
    output reg [31:0] ram_addr,
    output ram_we,
    output [7:0] ram_wr,
    input [7:0] ram_rd
);
    parameter ans_size = H * W / 4;
    parameter ram_ctrl_idle = 2'd0;
    parameter ram_ctrl_write = 2'd1;
    parameter ram_ctrl_wait = 2'd2;
    parameter ram_ctrl_done = 2'd3;
    reg [1:0] state, nextstate;
    reg [7:0] cnt;

    assign ram_we = 1'b1;
    assign ready = (nextstate == ram_ctrl_write);
    assign ram_en = (nextstate == ram_ctrl_write);
    assign ram_wr = ans;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cnt <= 0;
            ram_addr <= 0;
            intr <= 0;
        end
        else case (nextstate)
            ram_ctrl_write: begin
                cnt <= cnt + 1'b1;
                ram_addr <= ram_addr + 1'b1;
            end
            ram_ctrl_done: begin
                cnt <= 0;
                ram_addr <= 0;
                intr <= 1;
            end
            ram_ctrl_idle: begin
                cnt <= 0;
                ram_addr <= 0;
                intr <= 0;
            end
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn)
            state <= ram_ctrl_idle;
        else
            state <= nextstate;
    end

    always @(*) begin
        case (state)
            ram_ctrl_idle:
                if (valid)
                    nextstate = ram_ctrl_write;
                else
                    nextstate = ram_ctrl_idle;
            ram_ctrl_write:
                if (cnt == ans_size)
                    nextstate = ram_ctrl_done;
                else
                    nextstate = ram_ctrl_wait;
            ram_ctrl_wait:
                if (valid)
                    nextstate = ram_ctrl_write;
                else
                    nextstate = ram_ctrl_wait;
            ram_ctrl_done:
                    nextstate = ram_ctrl_idle;
        endcase
    end

endmodule //ram_write_ctrl
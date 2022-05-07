module ram_read_ctrl #(
    parameter H = 6,
    parameter W = 6
)(
    input clk,
    input rstn,

    input start,

    output [7:0] data,
    output reg valid,
    input ready,

    output ram_en,
    output reg [31:0] ram_addr,
    output ram_we,
    output reg [7:0] ram_wr,
    input [7:0] ram_rd
);
    reg [7:0] cnt;
    parameter matrix_size = H * W;
    parameter ram_ctrl_idle = 2'd0;
    parameter ram_ctrl_read = 2'd1;
    parameter ram_ctrl_send = 2'd2;
    reg [1:0] state,nextstate;

    assign data = ram_rd;
    assign ram_we = 1'b0;
    assign ram_en = (nextstate == ram_ctrl_read);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            valid <= 0;
            ram_addr <= 0;
            cnt <= 0;
        end
        else case (nextstate)
            ram_ctrl_read: begin
                valid <= 1'b1;
            end
            ram_ctrl_send: begin
                valid <= 0;
                cnt <= cnt + 1'b1;
                ram_addr <= ram_addr + 1'b1;
            end
            ram_ctrl_idle: begin
                valid <= 0;
                cnt <= 0;
                ram_addr <= 0;
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
                if (start)
                    nextstate = ram_ctrl_read;
                else
                    nextstate = ram_ctrl_idle;
            ram_ctrl_read:
                if (ready)
                    nextstate = ram_ctrl_send;
                else
                    nextstate = ram_ctrl_read;
            ram_ctrl_send:
                if (cnt == matrix_size)
                    nextstate = ram_ctrl_idle;
                else
                    nextstate = ram_ctrl_read;
            default:
                    nextstate = ram_ctrl_idle;
        endcase
    end

endmodule
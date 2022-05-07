module data_window #(
    parameter H = 6,
    parameter W = 6
)(
    input clk,
    input rstn,

    input [7:0] ram_data,
    input ram_valid,
    output ram_ready,

    output [7:0] data0,
    output [7:0] data1,
    output [7:0] data2,
    output [7:0] data3,
    output reg data_valid,
    input data_ready
);
    parameter data_idle = 3'd0;
    parameter data_fill = 3'd1;
    parameter ram_wait = 3'd2;
    parameter mac_available = 3'd3;
    parameter mac_wait = 3'd4;
    parameter data_send = 3'd5;
    parameter row_done = 3'd6;
    reg [2:0] state, nextstate;

    parameter NUM_window = W + 2;
    parameter ROW_valid = W / 2;
    parameter COL_valid = H / 2;

    reg [NUM_window*8-1:0] data_reg;
    reg shift_cnt;
    reg [7:0] fill_cnt;
    reg [7:0] row_valid_cnt;
    reg [7:0] col_valid_cnt;
    // reg [7:0] send_cnt;

    assign data0 = data_reg[7:0];
    assign data1 = data_reg[15:8];
    assign data2 = data_reg[W*8+7 : W*8];
    assign data3 = data_reg[W*8+15: W*8+8];
    assign ram_ready = (nextstate == data_fill);

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            data_valid <= 0;
            data_reg <= 0;

            shift_cnt <= 0;
            fill_cnt <= 0;
            row_valid_cnt <= 0;
            col_valid_cnt <= 0;
        end
        else case (nextstate)
            data_fill: begin
                shift_cnt <= ~shift_cnt;
                fill_cnt <= fill_cnt + 1'b1;
                data_reg <= {ram_data, data_reg[NUM_window*8-1:8]};
            end
            mac_available: begin
                row_valid_cnt <= row_valid_cnt + 1'b1;
            end
            mac_wait: begin
                data_valid <= 1'b1;
            end
            row_done: begin
                data_valid <= 0;
                data_reg <= 0;

                shift_cnt <= 0;
                fill_cnt <= 0;
                row_valid_cnt <= 0;
                col_valid_cnt <= col_valid_cnt + 1'b1;
            end
            data_send: begin
                data_valid <= 0;
            end
            data_idle: begin
                data_valid <= 0;
                data_reg <= 0;

                fill_cnt <= 0;
                row_valid_cnt <= 0;
            end
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn)
            state <= data_idle;
        else
            state <= nextstate;
    end

    always @(*) begin
        case (state)
            data_idle:
                if (ram_valid)
                    nextstate = data_fill;
                else
                    nextstate = data_idle;
            data_fill:
                if (fill_cnt >= NUM_window) begin
                    if (shift_cnt)
                        nextstate = ram_wait;
                    else
                        nextstate = mac_available;
                end
                else
                    nextstate = ram_wait;
            ram_wait:
                if (ram_valid)
                    nextstate = data_fill;
                else
                    nextstate = ram_wait;
            mac_available:
                    nextstate = mac_wait;
            row_done:
                if (ram_valid)
                    nextstate = data_fill;
                else
                    nextstate = ram_wait;
            mac_wait:
                if (data_ready)
                    nextstate = data_send;
                else
                    nextstate = mac_wait;
            data_send:
                if (col_valid_cnt < COL_valid-1'b1) begin
                    if (row_valid_cnt < ROW_valid) begin
                        if (ram_valid)
                            nextstate = data_fill;
                        else
                            nextstate = ram_wait;
                    end
                    else
                        nextstate = row_done;
                end
                else begin
                    if (row_valid_cnt < ROW_valid) begin
                        if (ram_valid)
                            nextstate = data_fill;
                        else
                            nextstate = ram_wait;
                    end
                    else
                        nextstate = data_idle;
                end
            default:
                    nextstate = data_idle;
        endcase
    end

endmodule //data_window
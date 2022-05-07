`include "ram_8bits.v"
`include "ram_read_ctrl.v"
`include "data_window.v"
`include "pool.v"
`include "ram_write_ctrl.v"
module top #(
    parameter H = 6,
    parameter W = 6
)(
    input clk,
    input rstn,
    input start,
    
    output intr
);

// ram of data_ram_ctrl start
    wire [7:0] data_ram_data;
    wire data_ram_valid;
    wire data_ram_ready;

    wire data_ram_en;
    wire [31:0] data_ram_addr;
    wire data_ram_we;
    wire [7:0] data_ram_wr;
    wire [7:0] data_ram_rd;

    ram_read_ctrl #(H, W) u_data_ctrl
    (
    .clk(clk),
    .rstn(rstn),
    .start(start),

    .data(data_ram_data),
    .valid(data_ram_valid),
    .ready(data_ram_ready),

    .ram_en(data_ram_en),
    .ram_addr(data_ram_addr),
    .ram_we(data_ram_we),
    .ram_wr(data_ram_wr),
    .ram_rd(data_ram_rd)
);

    ram_8bits u_data_ram(
    .clk(clk),
    .rstn(rstn),
    .en(data_ram_en),
    .addr(data_ram_addr),
    .we(data_ram_we),
    .write(data_ram_wr),
    .read(data_ram_rd)
);

// ram of data_ram_ctrl end
// window of data start

    wire [7:0] data0;
    wire [7:0] data1;
    wire [7:0] data2;
    wire [7:0] data3;
    wire data_mac_valid;
    wire data_mac_ready;

    data_window #(H, W) u_data_window(
    .clk(clk),
    .rstn(rstn),

    .ram_data(data_ram_data),
    .ram_valid(data_ram_valid),
    .ram_ready(data_ram_ready),

    .data0(data0),
    .data1(data1),
    .data2(data2),
    .data3(data3),
    .data_valid(data_mac_valid),
    .data_ready(data_mac_ready)
);

// window of data end
// pooling start

    wire [7:0] ans_data;
    wire ans_valid;
    wire ans_ready;

    pool u_pool(
    .clk(clk),
    .rstn(rstn),

    .data0(data0),
    .data1(data1),
    .data2(data2),
    .data3(data3),
    .data_valid(data_mac_valid),
    .data_ready(data_mac_ready),

    .ans_data(ans_data),
    .ans_valid(ans_valid),
    .ans_ready(ans_ready)
);
// pooling end

    wire ans_ram_en;
    wire [31:0] ans_ram_addr;
    wire ans_ram_we;
    wire [7:0] ans_ram_wr;
    wire [7:0] ans_ram_rd;

    ram_write_ctrl #(H, W) u_ans_ctrl(
    .clk(clk),
    .rstn(rstn),
    .intr(intr),

    .ans(ans_data),
    .valid(ans_valid),
    .ready(ans_ready),

    .ram_en(ans_ram_en),
    .ram_addr(ans_ram_addr),
    .ram_we(ans_ram_we),
    .ram_wr(ans_ram_wr),
    .ram_rd(ans_ram_rd)
);

    ram_8bits u_ans_ram(
    .clk(clk),
    .rstn(rstn),

    .en(ans_ram_en),
    .addr(ans_ram_addr),
    .we(ans_ram_we),
    .write(ans_ram_wr),
    .read(ans_ram_rd)
);

endmodule // top
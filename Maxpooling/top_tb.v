`timescale 1ns/1ns
`define clk_period 10
`include "top.v"
module top_tb ();
    reg clk;
    reg rstn;
    reg start;
    wire intr;

    parameter H_in = 10;
    parameter W_in = 10;
    parameter H_out = H_in / 2;
    parameter W_out = W_in / 2;
    parameter matrix_size = H_out * W_out;

    integer i;
    integer handle;

    initial begin
        clk = 1'b1;
        start = 1'b0;
        rstn = 1'b1; #1;
        rstn = 1'b0; #(`clk_period*2);
        rstn = 1'b1; #(`clk_period*2);
        $readmemh("data.ram",u_tb.u_data_ram.store);

        start = 1'b1; #(`clk_period);
        start = 1'b0; #(`clk_period * 500);

        handle = $fopen("answer.txt");
        $fdisplay(handle, "The answer is: ");
        // for (i = 0; i <= 6; i = i + 3)
        //     $fdisplay(handle, "%0h %0h %0h", u_tb.u_ans_ram.store[i],
        //     u_tb.u_ans_ram.store[i+1], u_tb.u_ans_ram.store[i+2] );
        for (i=0; i<matrix_size; i=i+1) begin
            $fwrite(handle, "%0h ", u_tb.u_ans_ram.store[i]);
            if (i%W_out == W_out - 1)
                $fwrite(handle, "\n");
        end
        $fclose(handle);
        $finish;
    end

    always #(`clk_period/2) clk <= ~clk;
    initial begin            
        $dumpfile("wave.vcd");        //生成的vcd文件名称
        $dumpvars(0, top_tb);    //tb模块名称
    end

    top #(H_in, W_in) u_tb(
    .clk(clk),
    .rstn(rstn),
    .start(start),
    .intr(intr)
);
endmodule //top_tb
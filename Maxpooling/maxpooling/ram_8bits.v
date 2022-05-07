module ram_8bits (
    input clk,
    input rstn,
    input en,
    input [31:0] addr,
    input we,  // 1:write into ram; 0:read from ram
    input [7:0] write,  // the data for writing into the ram
    
    output reg [7:0] read  // the data for reading from the ram
);
    reg [7:0] store[0:2047];
    integer i;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < 2048; i = i + 1)
                store[i] <= 0;
        end
        else if (en) begin
            if (we)
                store[addr] <= write;
            else
                read <= store[addr];
        end
    end

endmodule //ram_8bits
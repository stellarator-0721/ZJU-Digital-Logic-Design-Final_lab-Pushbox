// box_memory.v
module box_memory (
    input wire clk,
    input wire [9:0] addr,            // 32x32 = 1024像素，10位地址
    output reg [11:0] rgb_data        // RGB444: R[11:8], G[7:4], B[3:0]
);

    reg [11:0] rom [0:1023];

    initial begin
        $readmemh("box_32x32.mem", rom);  // 确保路径正确
    end

    always @(posedge clk) begin
        rgb_data <= rom[addr];
    end

endmodule

module win_memory (
    input wire clk,
    input wire [15:0] addr,  // 更新地址宽度为 16 位
    output reg [11:0] rgb_data
);
    // 更新 ROM 的大小为 65536 (256x256 像素)
    reg [11:0] rom [0:65535];  // 65536 个存储单元

    initial begin
        // 读取包含 256x256 像素的 .mem 文件
        $readmemh("win_256x256.mem", rom);  // 假设 wall_256x256.mem 存储的是 RGB444 格式的数据
    end

    always @(posedge clk) begin
        // 使用 addr 访问 ROM
        rgb_data <= rom[addr];
    end
endmodule

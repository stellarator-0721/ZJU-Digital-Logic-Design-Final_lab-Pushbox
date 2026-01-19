module vga_ctrl (
    input wire clk,         // 25MHz 时钟输入
    input wire rst_n,       // 低有效复位
    output reg [9:0] h_cnt, // 水平像素计数器
    output reg [9:0] v_cnt, // 垂直像素计数器
    output wire video_on,   // 有效显示区域使能信号
    output wire vga_hs,     // VGA 行同步信号（低有效）
    output wire vga_vs      // VGA 场同步信号（低有效）
);

    // VGA 640x480 @60Hz 时序参数
    parameter H_SYNC  = 96;   // 行同步脉冲宽度
    parameter H_BACK  = 48;   // 行显示后肩（同步脉冲后至显示开始）
    parameter H_DISP  = 640;  // 行有效显示区域宽度
    parameter H_FRONT = 16;   // 行显示前肩（显示结束至下一行同步）

    parameter V_SYNC  = 2;    // 场同步脉冲宽度
    parameter V_BACK  = 33;   // 场显示后肩
    parameter V_DISP  = 480;  // 场有效显示区域高度
    parameter V_FRONT = 10;   // 场显示前肩

    parameter H_TOTAL = H_SYNC + H_BACK + H_DISP + H_FRONT; // 一行总像素数
    parameter V_TOTAL = V_SYNC + V_BACK + V_DISP + V_FRONT; // 一帧总行数

    // 水平计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            h_cnt <= 0;
        else if (h_cnt == H_TOTAL - 1)
            h_cnt <= 0;
        else
            h_cnt <= h_cnt + 1;
    end

    // 垂直计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            v_cnt <= 0;
        else if (h_cnt == H_TOTAL - 1) begin
            if (v_cnt == V_TOTAL - 1)
                v_cnt <= 0;
            else
                v_cnt <= v_cnt + 1;
        end
    end

    // 生成同步信号（低有效）
    assign vga_hs = (h_cnt < H_SYNC) ? 1'b0 : 1'b1;
    assign vga_vs = (v_cnt < V_SYNC) ? 1'b0 : 1'b1;

    // 有效显示区域使能信号
    assign video_on = (h_cnt >= H_SYNC + H_BACK && h_cnt < H_SYNC + H_BACK + H_DISP) &&
                      (v_cnt >= V_SYNC + V_BACK && v_cnt < V_SYNC + V_BACK + V_DISP);

endmodule

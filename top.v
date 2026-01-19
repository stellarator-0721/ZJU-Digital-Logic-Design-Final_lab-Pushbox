module top (
    input wire clk,         // 板载 100MHz 主时钟
    input wire rst_n,       // 高有效时vga进行显示
    input wire rst,         //AF10为1时刷新地图
    input wire map_sel,     //选择关卡
    input wire [4:1] sw,    // sw[4]=右，sw[3]=左，sw[2]=下，sw[1]=上
    output wire [3:0] vga_red,
    output wire [3:0] vga_green,
    output wire [3:0] vga_blue,
    output wire vga_hs,
    output wire vga_vs,
    output wire buzzer,
    output [3:0] AN,
    output [7:0] SEGMENT
);

    // ---------------------------------
    // 输入时钟缓冲 + 全局缓冲
    // ---------------------------------
    wire clk_ibuf;
    wire clk_bufg;

    IBUF u_ibuf (
        .I(clk),
        .O(clk_ibuf)
    );

    BUFG u_bufg (
        .I(clk_ibuf),
        .O(clk_bufg)
    );

    // ---------------------------------
    // PLL：生成 VGA 25MHz 时钟
    // ---------------------------------
    wire clk_25m;
    wire locked;

    vga_clk u_vga_clk (
        .clk_in(clk_bufg),    // 100MHz 全局主时钟输入
        .clk_out(clk_25m),    // 25MHz VGA 时钟输出
        .resetn(rst_n),
        .locked(locked)
    );

    // ---------------------------------
    // 按键消抖 + 上升沿检测，基于 100MHz 时钟
    // ---------------------------------
    wire move_up, move_down, move_left, move_right;

    key_edge key_up (
        .clk(clk_bufg),
        .rst_n(rst_n),
        .key(sw[1]),
        .key_pos(move_up)
    );

    key_edge key_down (
        .clk(clk_bufg),
        .rst_n(rst_n),
        .key(sw[2]),
        .key_pos(move_down)
    );

    key_edge key_left (
        .clk(clk_bufg),
        .rst_n(rst_n),
        .key(sw[3]),
        .key_pos(move_left)
    );

    key_edge key_right (
        .clk(clk_bufg),
        .rst_n(rst_n),
        .key(sw[4]),
        .key_pos(move_right)
    );

    // ---------------------------------
    // 地图更新逻辑，基于 100MHz
    // 输出 map_data_out 为 4*56 = 224bit，表示 7x8 格地图
    // ---------------------------------
    wire [4*56-1:0] map_data_out;
    wire win_flag;  // <- 添加 win_flag 信号

    
     victory_sound u_victory_sound(
        .clk(clk_ibuf),          // 系统时钟 (建议100MHz)
        .rst_n(~rst),        // 低有效复位
        .victory(win_flag),      // 胜利信号(上升沿触发)
        .beep(buzzer)     // 蜂鸣器PWM输出
    );

    wire [15:0] stage_step_display;  // 来自 map_display 模块

    map_display u_map_display (
        .clk(clk_bufg),
        .rst_n(~rst),
        .map_sel(map_sel),
        .move_up(move_up),
        .move_down(move_down),
        .move_left(move_left),
        .move_right(move_right),
        .map_data_out(map_data_out),
        .win_flag(win_flag),  // <- 添加输出连接
        .stage_step_display(stage_step_display)
    );
    
    DisplayNumber display_inst (
        .clk(clk_bufg),
        .hexs(stage_step_display),
        .points(4'b1000),
        .rst(1'b0),
        .LEs(4'b0000),
        .AN(AN),
        .SEGMENT(SEGMENT)
    );




    // ---------------------------------
    // VGA 控制模块（25MHz）
    // ---------------------------------
    wire [9:0] h_cnt, v_cnt;
    wire video_on;

    vga_ctrl u_vga_ctrl (
        .clk(clk_25m),
        .rst_n(rst_n & locked),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .video_on(video_on),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs)
    );

    // ---------------------------------
    // VGA 显示模块（25MHz）
    // ---------------------------------
    vga_drive u_vga_drive (
        .clk(clk_25m),
        .rst_n(rst_n),
        .video_on(video_on),
        .h_cnt(h_cnt),
        .v_cnt(v_cnt),
        .map_data_flat(map_data_out),  // 来自 map_display
        .win_flag(win_flag),           // <- 添加 win_flag 输入
        .vga_red(vga_red),
        .vga_green(vga_green),
        .vga_blue(vga_blue)
    );

endmodule

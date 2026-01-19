`timescale 1ns / 1ps

module map_display_tb;

  reg clk = 0;
  reg rst = 1;
  reg move_up = 0, move_down = 0, move_left = 0, move_right = 0;
  wire [4*56-1:0] map_out_flat;
  wire map_sel=0;        // 关卡选择：0 为第一关，1 为第二关
  wire [15:0] stage_step_display;
  wire win_flag= 0;

  // 实例化 DUT
  map_display uut (
    .clk(clk),
    .rst_n(rst),
    .move_up(move_up),
    .move_down(move_down),
    .move_left(move_left),
    .move_right(move_right),
    .map_data_out(map_out_flat),
    .map_sel(map_sel),
    .stage_step_display(stage_step_display),
    .win_flag(win_flag)
  );

  // 产生时钟
  always #10 clk = ~clk;

  initial begin
    $display("Starting map_display_tb...");
    #50 rst = 0;
    #50 rst = 1;

    // 向右移动
    #100 move_right = 1;
    #20 move_right = 0;

    // 向下移动
    #100 move_down = 1;
    #20 move_down = 0;
    
    // 向右移动
    #100 move_right = 1;
    #20 move_right = 0;

    // 向左移动
    #100 move_left = 1;
    #20 move_left = 0;
    
    // 向左移动
    #100 move_left = 1;
    #20 move_left = 0;
    
    // 向下移动
    #100 move_down = 1;
    #20 move_down = 0;

    // 向上移动
    #100 move_up = 1;
    #20 move_up = 0;

    // 停止仿真
    #500;
    $stop;
  end

endmodule

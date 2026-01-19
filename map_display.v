module map_display (
    input wire clk,
    input wire rst_n,
    input wire map_sel,        // 关卡选择：0 为第一关，1 为第二关
    input wire move_up,
    input wire move_down,
    input wire move_left,
    input wire move_right,
    output reg [4*56-1:0] map_data_out,
    output reg win_flag,
    output reg [15:0] stage_step_display
);

    reg [3:0] map [0:55];
    reg [3:0] player_x;
    reg [3:0] player_y;
    reg has_key;

    integer i;

    reg signed [4:0] dx, dy; // 有符号偏移量
    reg [3:0] tile_next, tile_push;
    reg [5:0] idx_now, idx_next, idx_push;

    reg signed [5:0] sx, sy;
    reg signed [5:0] px_s, py_s;

    wire move = move_up | move_down | move_left | move_right;
    reg [9:0] step_counter;           // 记录移动步数（最大999）
    reg move_dly;                     // 用于检测移动上升沿
    wire move_posedge = move & ~move_dly;

    
    initial begin
            map[0]  <= 3; map[1]  <= 3; map[2]  <= 3; map[3]  <= 3; map[4]  <= 3; map[5]  <= 3; map[6]  <= 3;
            map[7]  <= 3; map[8]  <= 3; map[9]  <= 3; map[10] <= 3; map[11] <= 3; map[12] <= 3; map[13] <= 3;
            map[14] <= 3; map[15] <= 3; map[16] <= 3; map[17] <= 3; map[18] <= 3; map[19] <= 3; map[20] <= 3;
            map[21] <= 3; map[22] <= 3; map[23] <= 3; map[24] <= 3; map[25] <= 3; map[26] <= 3; map[27] <= 3;
            map[28] <= 3; map[29] <= 3; map[30] <= 3; map[31] <= 3; map[32] <= 3; map[33] <= 3; map[34] <= 3;
            map[35] <= 3; map[36] <= 3; map[37] <= 3; map[38] <= 3; map[39] <= 3; map[40] <= 3; map[41] <= 3;
            map[42] <= 3; map[43] <= 3; map[44] <= 3; map[45] <= 3; map[46] <= 3; map[47] <= 3; map[48] <= 3;
            map[49] <= 3; map[50] <= 3; map[51] <= 3; map[52] <= 3; map[53] <= 3; map[54] <= 3; map[55] <= 3;
            end

    // 记录移动上升沿（注意独立时序块）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            move_dly <= 1'b0;
        else
            move_dly <= move;
    end
    assign move_posedge = move & ~move_dly;
    
    // 步数统计（建议独立）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            step_counter <= 0;
            stage_step_display <= 0;
        end else if (move_posedge) begin
            if (step_counter < 999)
                step_counter <= step_counter + 1;
        end
    
        // 实时更新关卡与步数输出
        stage_step_display[15:12] <= map_sel ? 4'd2 : 4'd1;                   // 千位：关卡号
        stage_step_display[11:8]  <= (step_counter / 100) % 10;               // 百位
        stage_step_display[7:4]   <= (step_counter / 10)  % 10;               // 十位
        stage_step_display[3:0]   <= step_counter % 10;                       // 个位
    end



    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        player_x <= 4'd0;
        player_y <= 4'd0;
        has_key <= 1'b0;
        win_flag <= 1'b0;
    
        if (map_sel == 1'b0) begin
            // 第一关
            player_x <= 4'd1;
            player_y <= 4'd0;
    
        map[ 0] <= 4'd0; map[ 1] <= 4'd6; map[ 2] <= 4'd1; map[ 3] <= 4'd3; map[ 4] <= 4'd1; map[ 5] <= 4'd0; map[ 6] <= 4'd0;
        map[ 7] <= 4'd0; map[ 8] <= 4'd3; map[ 9] <= 4'd1; map[10] <= 4'd3; map[11] <= 4'd0; map[12] <= 4'd0; map[13] <= 4'd0;
        map[14] <= 4'd0; map[15] <= 4'd1; map[16] <= 4'd1; map[17] <= 4'd1; map[18] <= 4'd1; map[19] <= 4'd1; map[20] <= 4'd8;
        map[21] <= 4'd0; map[22] <= 4'd3; map[23] <= 4'd3; map[24] <= 4'd1; map[25] <= 4'd3; map[26] <= 4'd2; map[27] <= 4'd8;
        map[28] <= 4'd0; map[29] <= 4'd3; map[30] <= 4'd3; map[31] <= 4'd1; map[32] <= 4'd3; map[33] <= 4'd1; map[34] <= 4'd8;
        map[35] <= 4'd0; map[36] <= 4'd1; map[37] <= 4'd1; map[38] <= 4'd3; map[39] <= 4'd0; map[40] <= 4'd0; map[41] <= 4'd0;
        map[42] <= 4'd0; map[43] <= 4'd4; map[44] <= 4'd1; map[45] <= 4'd3; map[46] <= 4'd3; map[47] <= 4'd0; map[48] <= 4'd0;
        map[49] <= 4'd0; map[50] <= 4'd0; map[51] <= 4'd3; map[52] <= 4'd4; map[53] <= 4'd0; map[54] <= 4'd0; map[55] <= 4'd0;

        end else begin
            // 第二关
            player_x <= 4'd5;
            player_y <= 4'd0;
    
            map[ 0]<=4'd0; map[ 1]<=4'd0; map[ 2]<=4'd3; map[ 3]<=4'd1; map[ 4]<=4'd3; map[ 5]<=4'd6; map[ 6]<=4'd0;
            map[ 7]<=4'd0; map[ 8]<=4'd3; map[ 9]<=4'd1; map[10]<=4'd3; map[11]<=4'd1; map[12]<=4'd0; map[13]<=4'd0;
            map[14]<=4'd0; map[15]<=4'd1; map[16]<=4'd3; map[17]<=4'd1; map[18]<=4'd3; map[19]<=4'd4; map[20]<=4'd0;
            map[21]<=4'd0; map[22]<=4'd3; map[23]<=4'd1; map[24]<=4'd3; map[25]<=4'd1; map[26]<=4'd3; map[27]<=4'd0;
            map[28]<=4'd0; map[29]<=4'd1; map[30]<=4'd3; map[31]<=4'd1; map[32]<=4'd3; map[33]<=4'd1; map[34]<=4'd0;
            map[35]<=4'd0; map[36]<=4'd3; map[37]<=4'd1; map[38]<=4'd1; map[39]<=4'd2; map[40]<=4'd0; map[41]<=4'd0;
            map[42]<=4'd0; map[43]<=4'd0; map[44]<=4'd1; map[45]<=4'd3; map[46]<=4'd3; map[47]<=4'd0; map[48]<=4'd0;
            map[49]<=4'd0; map[50]<=4'd3; map[51]<=4'd3; map[52]<=4'd8; map[53]<=4'd0; map[54]<=4'd0; map[55]<=4'd0;
        end
    end else begin
            dx = 0; dy = 0;
            if (move_up) dy = -1;
            else if (move_down) dy = 1;
            else if (move_left) dx = -1;
            else if (move_right) dx = 1;

            if (move) begin
                idx_now = player_y * 7 + player_x;
                sx = $signed(player_x) + dx;
                sy = $signed(player_y) + dy;

                if (sx >= 0 && sx < 7 && sy >= 0 && sy < 8) begin
                    idx_next = sy * 7 + sx;
                    tile_next = map[idx_next];

                    // **先判断胜利条件：目标格是终点 8**
                    if (tile_next == 8) begin
                        win_flag <= 1'b1;
                        // 不移动，保持原位置，胜利后你可以根据需求处理
                    end else begin
                        win_flag <= 1'b0;

                        if (tile_next == 0) begin
                            // 墙壁，不移动
                        end else if (tile_next == 2) begin
                            // chest，需钥匙打开
                            if (has_key) begin
                                map[idx_now] <= 3;
                                map[idx_next] <= 6;
                                player_x <= sx[3:0];
                                player_y <= sy[3:0];
                            end
                        end else if (tile_next == 1 || tile_next == 5) begin
                            px_s = sx + dx;
                            py_s = sy + dy;

                            if (px_s >= 0 && px_s < 7 && py_s >= 0 && py_s < 8) begin
                                idx_push = py_s * 7 + px_s;
                                tile_push = map[idx_push];

                                if (tile_push != 0 && tile_push != 2 && tile_push != 1 && tile_push != 5) begin
                                    map[idx_push] <= tile_next;   // 推箱子
                                    map[idx_next] <= 6;           // 玩家占箱子原格
                                    map[idx_now] <= 3;            // 玩家原格变地板
                                    player_x <= sx[3:0];
                                    player_y <= sy[3:0];
                                end else if (tile_next == 5) begin
                                    map[idx_next] <= 3;           // 箱子不能推变空地
                                end
                            end else if (tile_next == 5) begin
                                map[idx_next] <= 3;               // 越界箱子变空地
                            end
                        end else begin
                            // 普通地板或钥匙
                            map[idx_now] <= 3;
                            map[idx_next] <= 6;
                            player_x <= sx[3:0];
                            player_y <= sy[3:0];

                            if (tile_next == 4) has_key <= 1'b1; // 拾钥匙
                        end
                    end
                end
            end else begin
                // 没有移动时不改变胜利状态，保持不变
            end
        end
    end

    always @(*) begin
        for (i = 0; i < 56; i = i + 1)
            map_data_out[i*4 +: 4] = map[i];
    end

endmodule

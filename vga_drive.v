module vga_drive (
    input wire clk,
    input wire rst_n,
    input wire video_on,
    input wire [9:0] h_cnt,
    input wire [9:0] v_cnt,
    input wire [4*56-1:0] map_data_flat,
    input wire win_flag,

    output reg [3:0] vga_red,
    output reg [3:0] vga_green,
    output reg [3:0] vga_blue
);

    localparam TILE_SIZE = 32;
    localparam MAP_W = 7;
    localparam MAP_H = 8;
    localparam DISP_W = 640;
    localparam DISP_H = 480;
    localparam START_X = (DISP_W - MAP_W * TILE_SIZE) / 2;
    localparam START_Y = (DISP_H - MAP_H * TILE_SIZE) / 2;

    wire [9:0] disp_x = h_cnt - (160 + START_X);
    wire [9:0] disp_y = v_cnt - (45 + START_Y);

    wire inside_map = video_on &&
                      (disp_x < MAP_W * TILE_SIZE) &&
                      (disp_y < MAP_H * TILE_SIZE);

    wire [3:0] tile_x = disp_x / TILE_SIZE;
    wire [3:0] tile_y = disp_y / TILE_SIZE;
    wire [5:0] tile_idx = tile_y * MAP_W + tile_x;
    wire [3:0] tile_type = inside_map ? map_data_flat[tile_idx*4 +: 4] : 4'd0;

    wire [4:0] pixel_x = disp_x % TILE_SIZE;
    wire [4:0] pixel_y = disp_y % TILE_SIZE;
    wire [9:0] pixel_addr = pixel_y * TILE_SIZE + pixel_x;

    wire [11:0] wall_rgb, box_rgb, chest_rgb, floor_rgb, key_rgb;
    wire [11:0] monster_rgb, player_rgb, spike_rgb, final_rgb;

    wall_memory    u_wall    (.clk(clk), .addr(pixel_addr), .rgb_data(wall_rgb));
    box_memory     u_box     (.clk(clk), .addr(pixel_addr), .rgb_data(box_rgb));
    chest_memory   u_chest   (.clk(clk), .addr(pixel_addr), .rgb_data(chest_rgb));
    floor_memory   u_floor   (.clk(clk), .addr(pixel_addr), .rgb_data(floor_rgb));
    key_memory     u_key     (.clk(clk), .addr(pixel_addr), .rgb_data(key_rgb));
    monster_memory u_monster (.clk(clk), .addr(pixel_addr), .rgb_data(monster_rgb));
    player_memory  u_player  (.clk(clk), .addr(pixel_addr), .rgb_data(player_rgb));
    spike_memory   u_spike   (.clk(clk), .addr(pixel_addr), .rgb_data(spike_rgb));
    final_memory   u_final   (.clk(clk), .addr(pixel_addr), .rgb_data(final_rgb));

    // You Win 图片显示
    wire show_win_pic = win_flag &&
                        (h_cnt >= (160 + START_X)) && (h_cnt < (160 + START_X + 256)) &&
                        (v_cnt >= (45 + START_Y)) && (v_cnt < (45 + START_Y + 256));
    
    wire [7:0] win_x = h_cnt - (160 + START_X);
    wire [7:0] win_y = v_cnt - (45 + START_Y);
    wire [15:0] win_addr = win_y * 256 + win_x;
    wire [11:0] win_rgb;
    
    win_memory u_win_mem (
        .clk(clk),
        .addr(win_addr),
        .rgb_data(win_rgb)
    );


    reg [11:0] rgb_data;

    always @(*) begin
        if (show_win_pic) begin
            rgb_data = win_rgb;
        end else if (!inside_map) begin
            rgb_data = 12'h000;
        end else begin
            case (tile_type)
                4'd0: rgb_data = wall_rgb;
                4'd1: rgb_data = box_rgb;
                4'd2: rgb_data = chest_rgb;
                4'd3: rgb_data = floor_rgb;
                4'd4: rgb_data = key_rgb;
                4'd5: rgb_data = monster_rgb;
                4'd6: rgb_data = player_rgb;
                4'd7: rgb_data = spike_rgb;
                4'd8: rgb_data = final_rgb;
                default: rgb_data = 12'h000;
            endcase
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            vga_red   <= 0;
            vga_green <= 0;
            vga_blue  <= 0;
        end else begin
            vga_red   <= rgb_data[11:8];
            vga_green <= rgb_data[7:4];
            vga_blue  <= rgb_data[3:0];
        end
    end

endmodule
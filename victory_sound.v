module victory_sound(
    input clk,          // 系统时钟 (建议100MHz)
    input rst_n,        // 低有效复位
    input victory,      // 胜利信号(上升沿触发)
    output reg beep     // 蜂鸣器PWM输出
);

    // 音符频率定义 (基于C大调音阶)
    localparam [19:0] NOTE_FREQ_C4 = 262;
    localparam [19:0] NOTE_FREQ_D4 = 294;
    localparam [19:0] NOTE_FREQ_E4 = 330;
    localparam [19:0] NOTE_FREQ_F4 = 349;
    localparam [19:0] NOTE_FREQ_G4 = 392;
    localparam [19:0] NOTE_FREQ_A4 = 440;
    localparam [19:0] NOTE_FREQ_B4 = 494;
    localparam [19:0] NOTE_FREQ_C5 = 523;

    // 改进胜利旋律 (Do-Mi-Sol-Do5-Mi-Do)
    localparam [2:0] MELODY0 = 3'd0; // C4
    localparam [2:0] MELODY1 = 3'd2; // E4
    localparam [2:0] MELODY2 = 3'd4; // G4
    localparam [2:0] MELODY3 = 3'd7; // C5
    localparam [2:0] MELODY4 = 3'd2; // E4
    localparam [2:0] MELODY5 = 3'd0; // C4

    localparam NOTE_DURATION = 25_000_000; // 每个音符持续时间0.25秒 (100MHz 时钟)
    
    reg [2:0] state;
    reg [31:0] counter;
    reg [2:0] note_index;
    reg [31:0] freq_counter;
    reg [31:0] half_period;

    localparam IDLE = 3'd0;
    localparam PLAYING = 3'd1;

    // 获取当前音符频率
    function [19:0] get_note_freq;
        input [2:0] note;
        begin
            case(note)
                3'd0: get_note_freq = NOTE_FREQ_C4;
                3'd1: get_note_freq = NOTE_FREQ_D4;
                3'd2: get_note_freq = NOTE_FREQ_E4;
                3'd3: get_note_freq = NOTE_FREQ_F4;
                3'd4: get_note_freq = NOTE_FREQ_G4;
                3'd5: get_note_freq = NOTE_FREQ_A4;
                3'd6: get_note_freq = NOTE_FREQ_B4;
                3'd7: get_note_freq = NOTE_FREQ_C5;
                default: get_note_freq = 20'd0;
            endcase
        end
    endfunction

    // 获取旋律对应的音符
    function [2:0] get_melody;
        input [2:0] idx;
        begin
            case(idx)
                3'd0: get_melody = MELODY0;
                3'd1: get_melody = MELODY1;
                3'd2: get_melody = MELODY2;
                3'd3: get_melody = MELODY3;
                3'd4: get_melody = MELODY4;
                3'd5: get_melody = MELODY5;
                default: get_melody = 3'd0;
            endcase
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            beep <= 0;
            counter <= 0;
            note_index <= 0;
            freq_counter <= 0;
            half_period <= (100_000_000 / get_note_freq(get_melody(0))) / 2;
        end else begin
            case (state)
                IDLE: begin
                    beep <= 0;
                    if (victory) begin
                        state <= PLAYING;
                        note_index <= 0;
                        counter <= 0;
                        freq_counter <= 0;
                        half_period <= (100_000_000 / get_note_freq(get_melody(0))) / 2;
                    end
                end

                PLAYING: begin
                    // 音符计时器
                    if (counter >= NOTE_DURATION) begin
                        counter <= 0;
                        if (note_index == 5) begin // 播放完最后一个音符
                            state <= IDLE;
                            beep <= 0;
                        end else begin
                            note_index <= note_index + 1;
                            half_period <= (100_000_000 / get_note_freq(get_melody(note_index + 1))) / 2;
                        end
                    end else begin
                        counter <= counter + 1;
                    end

                    // 方波信号发生器
                    if (freq_counter >= half_period - 1) begin
                        freq_counter <= 0;
                        beep <= ~beep;
                    end else begin
                        freq_counter <= freq_counter + 1;
                    end
                end
            endcase
        end
    end

endmodule

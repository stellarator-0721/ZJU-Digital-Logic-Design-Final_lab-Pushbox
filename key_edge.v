module key_edge (
    input wire clk,
    input wire rst_n,
    input wire key,
    output reg key_pos
);

    reg key_d0, key_d1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key_d0 <= 0;
            key_d1 <= 0;
        end else begin
            key_d0 <= key;
            key_d1 <= key_d0;
        end
    end

    // 上升沿：前为0，现为1
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            key_pos <= 0;
        else
            key_pos <= (~key_d1) & key_d0;
    end

endmodule

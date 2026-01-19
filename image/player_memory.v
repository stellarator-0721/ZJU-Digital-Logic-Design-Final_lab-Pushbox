module player_memory (
    input wire clk,
    input wire [9:0] addr,
    output reg [11:0] rgb_data
);
    reg [11:0] rom [0:1023];
    initial begin
        $readmemh("player_32x32.mem", rom);
    end
    always @(posedge clk) begin
        rgb_data <= rom[addr];
    end
endmodule

module DisplayNumber(
    input        clk,
    input        rst,
    input [15:0] hexs,
    input [ 3:0] points,
    input [ 3:0] LEs,
    output [ 3:0] AN,
    output [ 7:0] SEGMENT
);
    wire [1:0] scan;
    wire [31:0] div_res;
    wire [3:0] HEX;
    wire point;
    wire LE;

    // Clock divider
    clkdiv clkdiv_inst (
        .clk(clk),
        .rst(rst),
        .div_res(div_res)
    );

    assign scan = div_res[18:17];

    // DisplaySync
    DisplaySync DisplaySync_inst (
        .scan(scan),
        .hexs(hexs),
        .points(points),
        .LEs(LEs),
        .HEX(HEX),
        .AN(AN),
        .point(point),
        .LE(LE)
    );

    // MyMC14495
    MyMC14495 MyMC14495_inst (
        .D0(HEX[0]),
        .D1(HEX[1]),
        .D2(HEX[2]),
        .D3(HEX[3]),
        .LE(LE),
        .point(point),
        .a(SEGMENT[0]),
        .b(SEGMENT[1]),
        .c(SEGMENT[2]),
        .d(SEGMENT[3]),
        .e(SEGMENT[4]),
        .f(SEGMENT[5]),
        .g(SEGMENT[6]),
        .p(SEGMENT[7])
    );
endmodule
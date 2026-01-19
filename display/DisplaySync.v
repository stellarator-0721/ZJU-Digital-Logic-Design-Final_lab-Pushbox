module DisplaySync(
    input [ 1:0] scan,
    input [15:0] hexs,
    input [ 3:0] points,
    input [ 3:0] LEs,
    output[ 3:0] HEX,
    output[ 3:0] AN,
    output       point,
    output       LE
);
    // Mux for HEX
    Mux4to1b4 mux_hexs (
        .S(scan),
        .D0(hexs[3:0]),    // D0 对应最低 4 位
        .D1(hexs[7:4]),    // D1 对应次低 4 位
        .D2(hexs[11:8]),   // D2 对应次高 4 位
        .D3(hexs[15:12]),  // D3 对应最高 4 位
        .Y(HEX)
    );

    // Mux for points
    Mux4to1 mux_points (
        .S(scan),
        .D0(points[0]),    // D0 对应 points[0]
        .D1(points[1]),    // D1 对应 points[1]
        .D2(points[2]),    // D2 对应 points[2]
        .D3(points[3]),    // D3 对应 points[3]
        .Y(point)
    );

    // Mux for LEs
    Mux4to1 mux_LE (
        .S(scan),
        .D0(LEs[0]),       // D0 对应 LEs[0]
        .D1(LEs[1]),       // D1 对应 LEs[1]
        .D2(LEs[2]),       // D2 对应 LEs[2]
        .D3(LEs[3]),       // D3 对应 LEs[3]
        .Y(LE)
    );

    // Mux for AN
    Mux4to1b4 mux_AN (
        .S(scan),
        .D0(4'b1110),      // AN[3] 亮，其他灭
        .D1(4'b1101),      // AN[2] 亮，其他灭
        .D2(4'b1011),      // AN[1] 亮，其他灭
        .D3(4'b0111),      // AN[0] 亮，其他灭
        .Y(AN)
    );
endmodule
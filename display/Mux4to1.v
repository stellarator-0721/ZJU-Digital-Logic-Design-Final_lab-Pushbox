module Mux4to1(
    input [1:0] S,
    input D0,
    input D1,
    input D2,
    input D3,
    output Y
);
    // 原理图等效实现
    assign Y = (~S[1] & ~S[0] & D0) |
               (~S[1] &  S[0] & D1) |
               ( S[1] & ~S[0] & D2) |
               ( S[1] &  S[0] & D3);
endmodule
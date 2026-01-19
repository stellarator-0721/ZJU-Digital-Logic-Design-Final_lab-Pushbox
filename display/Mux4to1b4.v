module Mux4to1b4(
    input  [1:0] S,
    input  [3:0] D0,
    input  [3:0] D1,
    input  [3:0] D2,
    input  [3:0] D3,
    output [3:0] Y
);
    assign Y[0] = (S == 2'b00) ? D0[0] :
                  (S == 2'b01) ? D1[0] :
                  (S == 2'b10) ? D2[0] : D3[0];
    assign Y[1] = (S == 2'b00) ? D0[1] :
                  (S == 2'b01) ? D1[1] :
                  (S == 2'b10) ? D2[1] : D3[1];
    assign Y[2] = (S == 2'b00) ? D0[2] :
                  (S == 2'b01) ? D1[2] :
                  (S == 2'b10) ? D2[2] : D3[2];
    assign Y[3] = (S == 2'b00) ? D0[3] :
                  (S == 2'b01) ? D1[3] :
                  (S == 2'b10) ? D2[3] : D3[3];
endmodule
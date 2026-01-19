module MyMC14495(
    input D0, D1, D2, D3,
    input LE,
    input point,
    output reg p,
    output reg a, b, c, d, e, f, g
);

    always @(*) begin
        if (LE) begin
            {a, b, c, d, e, f, g} = 7'b1111111;
        end else begin
            case ({D3, D2, D1, D0})
                4'h0: {a,b,c,d,e,f,g} = 7'b0000001; // 0
                4'h1: {a,b,c,d,e,f,g} = 7'b1001111; // 1
                4'h2: {a,b,c,d,e,f,g} = 7'b0010010; // 2
                4'h3: {a,b,c,d,e,f,g} = 7'b0000110; // 3
                4'h4: {a,b,c,d,e,f,g} = 7'b1001100; // 4
                4'h5: {a,b,c,d,e,f,g} = 7'b0100100; // 5
                4'h6: {a,b,c,d,e,f,g} = 7'b0100000; // 6
                4'h7: {a,b,c,d,e,f,g} = 7'b0001111; // 7
                4'h8: {a,b,c,d,e,f,g} = 7'b0000000; // 8
                4'h9: {a,b,c,d,e,f,g} = 7'b0000100; // 9
                4'hA: {a,b,c,d,e,f,g} = 7'b0001000; // A
                4'hB: {a,b,c,d,e,f,g} = 7'b1100000; // b
                4'hC: {a,b,c,d,e,f,g} = 7'b0110001; // C
                4'hD: {a,b,c,d,e,f,g} = 7'b1000010; // d
                4'hE: {a,b,c,d,e,f,g} = 7'b0110000; // E
                4'hF: {a,b,c,d,e,f,g} = 7'b0111000; // F
                default: {a,b,c,d,e,f,g} = 7'b1111111;
            endcase
        end
        p = point ? 1'b0 : 1'b1;
    end

endmodule
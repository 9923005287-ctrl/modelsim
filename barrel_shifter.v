// 1.3 Barrel Shifter: log2(WIDTH)-stage mux network, combinational
// mode: 00=SLL 01=SRL 10=SRA 11=ROL
module barrel_shifter #(parameter WIDTH = 8) (
    input  wire [WIDTH-1:0]         din,
    input  wire [$clog2(WIDTH)-1:0] shamt,
    input  wire [1:0]               mode,
    output wire [WIDTH-1:0]         dout
);
    localparam N = $clog2(WIDTH);
    wire fill = (mode == 2'b10) & din[WIDTH-1];
    wire [WIDTH-1:0] stage [0:N];
    assign stage[0] = din;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : g
            localparam S = 1 << i;
            wire [WIDTH-1:0] sh_l = {stage[i][WIDTH-1-S:0], {S{1'b0}}};
            wire [WIDTH-1:0] sh_r = {{S{fill}}, stage[i][WIDTH-1:S]};
            wire [WIDTH-1:0] rot  = {stage[i][WIDTH-1-S:0], stage[i][WIDTH-1:WIDTH-S]};
            wire [WIDTH-1:0] moved = (mode==2'b00) ? sh_l : (mode==2'b11) ? rot : sh_r;
            assign stage[i+1] = shamt[i] ? moved : stage[i];
        end
    endgenerate
    assign dout = stage[N];
endmodule

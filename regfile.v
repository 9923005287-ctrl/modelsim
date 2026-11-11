// 1.4 Register File: 32 x 32, 2 async read ports, 1 sync write port, x0 = 0
module regfile #(parameter WIDTH = 32, parameter DEPTH = 32) (
    input  wire                     clk, we,
    input  wire [$clog2(DEPTH)-1:0] raddr1, raddr2, waddr,
    input  wire [WIDTH-1:0]         wdata,
    output wire [WIDTH-1:0]         rdata1, rdata2
);
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    integer k;
    initial for (k=0;k<DEPTH;k=k+1) mem[k] = 0;
    always @(posedge clk) if (we && waddr != 0) mem[waddr] <= wdata;
    // write-through bypass: a same-cycle read of the written register sees new data
    assign rdata1 = (raddr1 == 0) ? 0 : (we && raddr1==waddr) ? wdata : mem[raddr1];
    assign rdata2 = (raddr2 == 0) ? 0 : (we && raddr2==waddr) ? wdata : mem[raddr2];
endmodule

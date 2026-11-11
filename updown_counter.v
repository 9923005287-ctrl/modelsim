// 1.2 Up/Down Counter with synchronous load, enable, wrap flag
module updown_counter #(parameter WIDTH = 4) (
    input  wire             clk, rst_n, en, up, load,
    input  wire [WIDTH-1:0] load_val,
    output reg  [WIDTH-1:0] count,
    output wire             wrap      // high when next count wraps around
);
    assign wrap = en & ~load & (up ? (count == {WIDTH{1'b1}}) : (count == 0));
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)       count <= 0;
        else if (load)    count <= load_val;
        else if (en)      count <= up ? count + 1'b1 : count - 1'b1;
    end
endmodule

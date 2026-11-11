`timescale 1ns/1ps
module barrel_shifter_tb;
    parameter W = 8;
    reg [W-1:0] din; reg [$clog2(W)-1:0] sh; reg [1:0] mode;
    wire [W-1:0] dout;
    barrel_shifter #(W) dut(din,sh,mode,dout);
    reg [W-1:0] exp; reg signed [W-1:0] sd; reg [2*W-1:0] dbl;
    integer errors=0, tests=0, i, m, s;
    task check; begin
        sd = din; dbl = {din,din};
        case (mode)
            0: exp = din << sh;
            1: exp = din >> sh;
            2: exp = sd >>> sh;
            3: exp = (sh==0) ? din : (dbl >> (W-sh));
        endcase
        #1; tests=tests+1;
        if (dout !== exp) begin errors=errors+1;
            $display("FAIL mode=%0d din=%b sh=%0d dout=%b exp=%b",mode,din,sh,dout,exp); end
    end endtask
    initial begin
        $dumpfile("shifter.vcd"); $dumpvars(0, barrel_shifter_tb);
        for (m=0;m<4;m=m+1) for (s=0;s<W;s=s+1) begin   // all modes x all shifts
            mode=m; sh=s;
            din=8'hA5; check; din=8'h80; check; din=8'h01; check; din=8'hFF; check;
            for (i=0;i<50;i=i+1) begin din=$random; check; end
        end
        $display("SHIFTER TEST: %0d tests, %0d errors -> %s",tests,errors,errors==0?"PASS":"FAIL");
        $finish;
    end
endmodule

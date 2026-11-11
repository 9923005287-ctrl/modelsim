`timescale 1ns/1ps
module regfile_tb;
    reg clk=0, we=0; reg [4:0] ra1=0, ra2=0, wa=0; reg [31:0] wd=0;
    wire [31:0] rd1, rd2;
    regfile dut(clk,we,ra1,ra2,wa,wd,rd1,rd2);
    always #5 clk=~clk;
    reg [31:0] model [0:31];
    integer errors=0, tests=0, i;
    task chk; input [31:0] got, exp; begin
        tests=tests+1;
        if (got!==exp) begin errors=errors+1; $display("FAIL t=%0t got=%h exp=%h",$time,got,exp); end
    end endtask
    initial begin
        $dumpfile("regfile.vcd"); $dumpvars(0, regfile_tb);
        for (i=0;i<32;i=i+1) model[i]=0;
        // write every register with unique data, then read back
        for (i=0;i<32;i=i+1) begin @(negedge clk); we=1; wa=i; wd=32'hA000_0000+i*7; 
            if (i!=0) model[i]=wd; end
        @(negedge clk); we=0;
        for (i=0;i<32;i=i+1) begin ra1=i; ra2=31-i; #1; chk(rd1,model[i]); chk(rd2,model[31-i]); @(negedge clk); end
        // x0 must stay zero
        we=1; wa=0; wd=32'hDEADBEEF; ra1=0; #1; chk(rd1,0); @(negedge clk); we=0; ra1=0; #1; chk(rd1,0);
        // write-through bypass
        @(negedge clk); we=1; wa=5'd10; wd=32'h1234_5678; ra1=10; ra2=10; #1; chk(rd1,wd); chk(rd2,wd);
        @(negedge clk); model[10]=32'h1234_5678;
        // we=0 must not write
        we=0; wa=5'd11; wd=32'hFFFF_FFFF; @(negedge clk); ra1=11; #1; chk(rd1,model[11]);
        // random traffic
        for (i=0;i<2000;i=i+1) begin
            @(negedge clk); we=$random; wa=$random; wd=$random; ra1=$random; ra2=$random; 
            #1;
            chk(rd1, (ra1==0)?0 : (we&&ra1==wa)? wd : model[ra1]);
            chk(rd2, (ra2==0)?0 : (we&&ra2==wa)? wd : model[ra2]);
            @(posedge clk); #1; if (we && wa!=0) model[wa]=wd;
        end
        $display("REGFILE TEST: %0d checks, %0d errors -> %s",tests,errors,errors==0?"PASS":"FAIL");
        $finish;
    end
endmodule

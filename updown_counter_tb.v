`timescale 1ns/1ps
module updown_counter_tb;
    parameter W = 4;
    reg clk=0, rst_n=0, en=0, up=1, load=0; reg [W-1:0] load_val=0;
    wire [W-1:0] count; wire wrap;
    updown_counter #(W) dut(clk,rst_n,en,up,load,load_val,count,wrap);
    always #5 clk = ~clk;
    reg [W-1:0] model = 0; reg exp_wrap;
    integer errors=0, i, cycles=0;
    // Reference model + checker: both sample pre-edge values at posedge
    // (nonblocking updates land after this block reads), avoiding stimulus races.
    always @(posedge clk) begin
        cycles = cycles + 1;
        exp_wrap = en & ~load & (up ? (model=={W{1'b1}}) : (model==0));
        if (cycles > 1 && (count !== model || wrap !== exp_wrap)) begin
            errors = errors + 1;
            $display("FAIL t=%0t count=%0d exp=%0d wrap=%b exp=%b", $time,count,model,wrap,exp_wrap);
        end
    end
    // Model mirrors the DUT's asynchronous active-low reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) model <= 0;
        else if (load) model <= load_val;
        else if (en) model <= up ? model+1 : model-1;
    end
    initial begin
        $dumpfile("counter.vcd"); $dumpvars(0, updown_counter_tb);
        #12 rst_n = 1;
        en=1; up=1; repeat (20) @(posedge clk);          // up through wrap
        up=0;       repeat (20) @(posedge clk);          // down through wrap
        en=0;       repeat (3)  @(posedge clk);          // hold
        load=1; load_val=4'd9; @(posedge clk); load=0;   // load
        en=1; up=0; repeat (4) @(posedge clk);
        for (i=0;i<300;i=i+1) begin                      // random stimulus
            @(negedge clk); en=$random; up=$random; load=($urandom%10==0); load_val=$random;
            if ($urandom%97==0) rst_n=0; else rst_n=1;
        end
        @(negedge clk); @(negedge clk);
        $display("COUNTER TEST: %0d cycles, %0d errors -> %s", cycles, errors, errors==0?"PASS":"FAIL");
        $finish;
    end
endmodule

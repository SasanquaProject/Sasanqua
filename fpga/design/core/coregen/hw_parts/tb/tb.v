`timescale 1ns/1ps

module sasanqua_tb;

/* ----- クロック ----- */
localparam integer FERQ_MHZ = 100;
localparam integer STEP = 1000 / FERQ_MHZ;

reg CLK;
reg RST;

always begin
    CLK = 0; #(STEP/2);
    CLK = 1; #(STEP/2);
end

/* ----- テストベンチ本体 ----- */
`include "setup.vh"
`include "monitor.vh"
`include "task.vh"

initial begin
    test;
    $stop;
end

endmodule

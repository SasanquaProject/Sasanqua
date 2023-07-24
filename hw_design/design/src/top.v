module top (
    /* 制御 */
    input   wire        CLK,
    input   wire        RST,

    /* 状態 */
    output  wire [31:0] STAT
);

    assign STAT = 32'b0;

endmodule

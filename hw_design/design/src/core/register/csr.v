module csr
    (
        /* ----- 制御 ----- */
        input wire CLK,
        input wire RST,

        /* ----- レジスタアクセス ----- */
        // 読み
        input wire  [11:0]  RADDR,
        output wire         RVALID,
        output wire [31:0]  RDATA,

        // 書き
        input wire          WREN,
        input wire  [11:0]  WADDR,
        input wire  [31:0]  WDATA
    );

    assign RVALID = 1'b1;
    assign RDATA  = 32'b0;

endmodule

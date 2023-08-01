module csrs_user
    (
        /* ----- 制御 ----- */
        input wire CLK,
        input wire RST,

        /* ----- CSRアクセス ----- */
        // 読み
        input wire          RDEN,
        input wire  [11:0]  RADDR,
        output reg          RVALID,
        output reg  [31:0]  RDATA,

        // 書き
        input wire          WREN,
        input wire  [11:0]  WADDR,
        input wire  [31:0]  WDATA
    );

    // reg [31:0] csr [0:1023];

    always @ (posedge CLK) begin
        RVALID <= RDEN;
        RDATA <= 32'b0;
    end

endmodule

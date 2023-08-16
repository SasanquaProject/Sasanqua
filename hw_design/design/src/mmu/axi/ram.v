module ram
    (
        /* ----- 制御 ------ */
        input wire          CLK,
        input wire          RST,

        /* ----- アクセスポート ----- */
        // ポートA
        input wire          A_RDEN,
        input wire  [9:0]   A_RADDR,
        output wire [31:0]  A_RDATA,
        input wire          A_WREN,
        input wire  [9:0]   A_WADDR,
        input wire  [31:0]  A_WDATA,

        // ポートB
        input wire          B_RDEN,
        input wire  [9:0]   B_RADDR,
        output wire [31:0]  B_RDATA,
        input wire          B_WREN,
        input wire  [9:0]   B_WADDR,
        input wire  [31:0]  B_WDATA
    );

    (* ram_style = "block" *)
    reg [31:0]  ram [0:1023];

    wire        wren;
    wire [9:0]  raddr, waddr;
    wire [31:0] wdata;
    reg         cache_wren;
    reg  [31:0] rdata, cache_wdata;

    assign raddr   = B_RDEN ? B_RADDR : A_RADDR;
    assign A_RDATA = cache_wren ? cache_wdata : rdata;
    assign B_RDATA = cache_wren ? cache_wdata : rdata;
    assign wren    = A_WREN || B_WREN;
    assign waddr   = B_WREN ? B_WADDR : A_WADDR;
    assign wdata   = B_WREN ? B_WDATA : A_WDATA;

    always @ (posedge CLK) begin
        cache_wren <= wren;
        cache_wdata <= wdata;
        rdata <= ram[raddr];
        if (wren)
            ram[waddr] <= wdata;
    end

endmodule

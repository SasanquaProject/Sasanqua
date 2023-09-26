module ram_dualport
    # (
        parameter WIDTH = 10,
        parameter SIZE  = 1024
    )
    (
        /* ----- 制御 ------ */
        input wire          CLK,
        input wire          RST,

        /* ----- アクセスポート ----- */
        // ポートA
        input wire                  A_RDEN,
        input wire  [(WIDTH-1+2):0] A_RADDR,
        output wire [31:0]          A_RDATA,
        input wire                  A_WREN,
        input wire  [3:0]           A_WSTRB,
        input wire  [(WIDTH-1+2):0] A_WADDR,
        input wire  [31:0]          A_WDATA,

        // ポートB
        input wire                  B_RDEN,
        input wire  [(WIDTH-1+2):0] B_RADDR,
        output wire [31:0]          B_RDATA,
        input wire                  B_WREN,
        input wire  [3:0]           B_WSTRB,
        input wire  [(WIDTH-1+2):0] B_WADDR,
        input wire  [31:0]          B_WDATA
    );

    (* ram_style = "block" *)
    reg [31:0] ram [0:(SIZE-1)];

    wire                    wren;
    wire [3:0]              wstrb;
    wire [(WIDTH-1+2):0]    raddr, waddr;
    wire [31:0]             wdata;

    reg                     cache_wren;
    reg  [3:0]              cache_wstrb;
    reg  [(WIDTH-1+2):0]    cache_waddr;
    reg  [31:0]             rdata, rdata_for_w, cache_wdata;

    assign raddr   = B_RDEN ? B_RADDR : A_RADDR;
    assign wren    = B_WREN || A_WREN;
    assign wstrb   = B_WREN ? B_WSTRB : A_WSTRB;
    assign waddr   = B_WREN ? B_WADDR : A_WADDR;
    assign wdata   = B_WREN ? B_WDATA : A_WDATA;
    assign A_RDATA = cache_wren ? gen_wrdata(cache_waddr, cache_wstrb, rdata_for_w, cache_wdata) : rdata;
    assign B_RDATA = cache_wren ? gen_wrdata(cache_waddr, cache_wstrb, rdata_for_w, cache_wdata) : rdata;

    always @ (posedge CLK) begin
        cache_wren <= wren;
        cache_wstrb <= wstrb;
        cache_waddr <= waddr;
        cache_wdata <= wdata;

        rdata <= ram[raddr[(WIDTH-1+2):2]];
        rdata_for_w <= ram[waddr[(WIDTH-1+2):2]];

        if (cache_wren)
            ram[cache_waddr[(WIDTH-1+2):2]] <= gen_wrdata(cache_waddr, cache_wstrb, rdata_for_w, cache_wdata);
    end

    function [31:0] gen_wrdata;
        input [(WIDTH-1+2):0] ADDR;
        input [3:0]           STRB;
        input [31:0]          DST;
        input [31:0]          SRC;

        case ((STRB << ADDR[1:0]))
            4'b0001: gen_wrdata = (DST & 32'hffff_ff00) | { 24'b0, SRC[7:0] };
            4'b0010: gen_wrdata = (DST & 32'hffff_00ff) | { 16'b0, SRC[7:0], 8'b0 };
            4'b0100: gen_wrdata = (DST & 32'hff00_ffff) | { 8'b0, SRC[7:0], 16'b0 };
            4'b1000: gen_wrdata = (DST & 32'h00ff_ffff) | { SRC[7:0], 24'b0 };
            4'b0011: gen_wrdata = (DST & 32'hffff_0000) | { 16'b0, SRC[15:0] };
            4'b0110: gen_wrdata = (DST & 32'hff00_00ff) | { 8'b0, SRC[15:0], 8'b0 };
            4'b1100: gen_wrdata = (DST & 32'h0000_ffff) | { SRC[15:0], 16'b0 };
            default: gen_wrdata = SRC;
        endcase
    endfunction

endmodule

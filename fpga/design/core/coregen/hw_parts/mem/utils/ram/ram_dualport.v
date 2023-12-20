module ram_dualport
    # (
        // サイズ
        parameter ADDR_WIDTH = 10,
        parameter SIZE = 1 << ADDR_WIDTH,

        // データ幅
        parameter DATA_WIDTH_2POW = 0,
        parameter DATA_32CNT = 1 << DATA_WIDTH_2POW,
        parameter DATA_WIDTH = 32 * DATA_32CNT
    )
    (
        /* ----- 制御 ------ */
        input wire                       CLK,
        input wire                       RST,

        /* ----- アクセスポート ----- */
        // ポートA
        input wire                       A_RDEN,
        input wire  [(ADDR_WIDTH-1+2):0] A_RADDR,
        output wire [(DATA_WIDTH-1):0]   A_RDATA,
        input wire                       A_WREN,
        input wire  [3:0]                A_WSTRB,
        input wire  [(ADDR_WIDTH-1+2):0] A_WADDR,
        input wire  [(DATA_WIDTH-1):0]   A_WDATA,

        // ポートB
        input wire                       B_RDEN,
        input wire  [(ADDR_WIDTH-1+2):0] B_RADDR,
        output wire [(DATA_WIDTH-1):0]   B_RDATA,
        input wire                       B_WREN,
        input wire  [(4*DATA_32CNT-1):0] B_WSTRB,
        input wire  [(ADDR_WIDTH-1+2):0] B_WADDR,
        input wire  [(DATA_WIDTH-1):0]   B_WDATA
    );

    (* ram_style = "block" *)
    reg [(DATA_WIDTH-1):0] ram [0:(SIZE-1)];

    wire                      wren;
    wire [(4*DATA_32CNT-1):0] wstrb;
    wire [(ADDR_WIDTH-1+2):0] raddr, waddr;
    wire [(DATA_WIDTH-1):0]   wdata, combined_wdata;
    reg  [(DATA_WIDTH-1):0]   rdata, rdata_for_w;

    reg  [1:0]                cache_wren;
    reg  [(4*DATA_32CNT):0]   cache_wstrb;
    reg  [(ADDR_WIDTH-1+2):0] cache_waddr [0:1];
    reg  [(DATA_WIDTH-1):0]   cache_wdata [0:1];

    ram_dualport_combine_wrdata #(
        .ADDR_WIDTH         (ADDR_WIDTH),
        .DATA_WIDTH_2POW    (DATA_WIDTH_2POW)
    ) combine (
        .ADDR   (cache_waddr[0]),
        .STRB   (cache_wstrb),
        .DST    (rdata_for_w),
        .SRC    (cache_wdata[0]),
        .RESULT (combined_wdata)
    );

    assign raddr   = B_RDEN ? B_RADDR : A_RADDR;
    assign wren    = B_WREN || A_WREN;
    assign wstrb   = B_WREN ? B_WSTRB : A_WSTRB;
    assign waddr   = B_WREN ? B_WADDR : A_WADDR;
    assign wdata   = B_WREN ? B_WDATA : A_WDATA;
    assign A_RDATA = (cache_wren[0] && raddr == cache_waddr[0]) ? combined_wdata : (
                     (cache_wren[1] && raddr == cache_waddr[1]) ? cache_wdata[1] :
                                                                  rdata);
    assign B_RDATA = A_RDATA;

    always @ (posedge CLK) begin
        cache_wren <= { cache_wren[0], wren };
        cache_wstrb <= wstrb;
        cache_waddr[1] <= cache_waddr[0];
        cache_waddr[0] <= waddr;
        cache_wdata[1] <= combined_wdata;
        cache_wdata[0] <= wdata;

        rdata <= ram[raddr[(ADDR_WIDTH-1+2):2]];
        rdata_for_w <= ram[waddr[(ADDR_WIDTH-1+2):2]];

        if (cache_wren[0])
            ram[cache_waddr[0][(ADDR_WIDTH-1+2):2]] <= combined_wdata;
    end
endmodule

module ram_dualport_combine_wrdata #
    (
        // サイズ
        parameter ADDR_WIDTH = 10,
        parameter SIZE = 1 << ADDR_WIDTH,

        // データ幅
        parameter DATA_WIDTH_2POW = 0,
        parameter DATA_32CNT = 1 << DATA_WIDTH_2POW,
        parameter DATA_WIDTH = 32 * DATA_32CNT
    )
    (
        input wire  [(ADDR_WIDTH-1+2):0] ADDR,
        input wire  [(4*DATA_32CNT-1):0] STRB,
        input wire  [(DATA_WIDTH-1):0]   DST,
        input wire  [(DATA_WIDTH-1):0]   SRC,
        output wire [(DATA_WIDTH-1):0]   RESULT
    );

    genvar i;
    generate
        for (i = 0; i < (1 << DATA_WIDTH_2POW); i = i + 1) begin
            assign RESULT[(32*(i+1)-1):(32*i)] = inner_32(
                ADDR + i,
                STRB[(4*(i+1)-1):(4*i)],
                DST[(32*(i+1)-1):(32*i)],
                SRC[(32*(i+1)-1):(32*i)]
            );
        end
    endgenerate

    function [31:0] inner_32;
        input [(ADDR_WIDTH-1+2):0] ADDR;
        input [3:0]                STRB;
        input [31:0]               DST;
        input [31:0]               SRC;

        case ((STRB << ADDR[1:0]))
            4'b0001: inner_32 = (DST & 32'hffff_ff00) | { 24'b0, SRC[7:0] };
            4'b0010: inner_32 = (DST & 32'hffff_00ff) | { 16'b0, SRC[7:0], 8'b0 };
            4'b0100: inner_32 = (DST & 32'hff00_ffff) | { 8'b0, SRC[7:0], 16'b0 };
            4'b1000: inner_32 = (DST & 32'h00ff_ffff) | { SRC[7:0], 24'b0 };
            4'b0011: inner_32 = (DST & 32'hffff_0000) | { 16'b0, SRC[15:0] };
            4'b0110: inner_32 = (DST & 32'hff00_00ff) | { 8'b0, SRC[15:0], 8'b0 };
            4'b1100: inner_32 = (DST & 32'h0000_ffff) | { SRC[15:0], 16'b0 };
            default: inner_32 = SRC;
        endcase
    endfunction
endmodule

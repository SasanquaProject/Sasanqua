module interconnect_axi
    (
        /* ----- 制御 ----- */
        // クロック, リセット
        input wire          CLK,
        input wire          RST,

        /* ----- AXIバス ----- */
        // Master
        output wire         M_AXI_AWID,
        output wire [31:0]  M_AXI_AWADDR,
        output wire [7:0]   M_AXI_AWLEN,
        output wire [2:0]   M_AXI_AWSIZE,
        output wire [1:0]   M_AXI_AWBURST,
        output wire [1:0]   M_AXI_AWLOCK,
        output wire [3:0]   M_AXI_AWCACHE,
        output wire [2:0]   M_AXI_AWPROT,
        output wire [3:0]   M_AXI_AWQOS,
        output wire         M_AXI_AWUSER,
        output wire         M_AXI_AWVALID,
        input  wire         M_AXI_AWREADY,
        output wire [31:0]  M_AXI_WDATA,
        output wire [3:0]   M_AXI_WSTRB,
        output wire         M_AXI_WLAST,
        output wire         M_AXI_WUSER,
        output wire         M_AXI_WVALID,
        input  wire         M_AXI_WREADY,
        input  wire         M_AXI_BID,
        input  wire [1:0]   M_AXI_BRESP,
        input  wire         M_AXI_BUSER,
        input  wire         M_AXI_BVALID,
        output wire         M_AXI_BREADY,
        output wire         M_AXI_ARID,
        output wire [31:0]  M_AXI_ARADDR,
        output wire [7:0]   M_AXI_ARLEN,
        output wire [2:0]   M_AXI_ARSIZE,
        output wire [1:0]   M_AXI_ARBURST,
        output wire [1:0]   M_AXI_ARLOCK,
        output wire [3:0]   M_AXI_ARCACHE,
        output wire [2:0]   M_AXI_ARPROT,
        output wire [3:0]   M_AXI_ARQOS,
        output wire         M_AXI_ARUSER,
        output wire         M_AXI_ARVALID,
        input  wire         M_AXI_ARREADY,
        input  wire         M_AXI_RID,
        input  wire [31:0]  M_AXI_RDATA,
        input  wire [1:0]   M_AXI_RRESP,
        input  wire         M_AXI_RLAST,
        input  wire         M_AXI_RUSER,
        input  wire         M_AXI_RVALID,
        output wire         M_AXI_RREADY,

        // Slave1
        input  wire [31:0]  S1_AXI_AWADDR,
        input  wire [7:0]   S1_AXI_AWLEN,
        input  wire [2:0]   S1_AXI_AWSIZE,
        input  wire [1:0]   S1_AXI_AWBURST,
        input  wire         S1_AXI_AWVALID,
        output wire         S1_AXI_AWREADY,
        input  wire [31:0]  S1_AXI_WDATA,
        input  wire [3:0]   S1_AXI_WSTRB,
        input  wire         S1_AXI_WLAST,
        input  wire         S1_AXI_WVALID,
        output wire         S1_AXI_WREADY,
        output wire         S1_AXI_BID,
        output wire [1:0]   S1_AXI_BRESP,
        output wire         S1_AXI_BVALID,
        input  wire [31:0]  S1_AXI_ARADDR,
        input  wire [7:0]   S1_AXI_ARLEN,
        input  wire [2:0]   S1_AXI_ARSIZE,
        input  wire [1:0]   S1_AXI_ARBURST,
        input  wire         S1_AXI_ARVALID,
        output wire         S1_AXI_ARREADY,
        output wire         S1_AXI_RID,
        output wire [31:0]  S1_AXI_RDATA,
        output wire [1:0]   S1_AXI_RRESP,
        output wire         S1_AXI_RLAST,
        output wire         S1_AXI_RVALID,

        // Slave2
        input  wire [31:0]  S2_AXI_AWADDR,
        input  wire [7:0]   S2_AXI_AWLEN,
        input  wire [2:0]   S2_AXI_AWSIZE,
        input  wire [1:0]   S2_AXI_AWBURST,
        input  wire         S2_AXI_AWVALID,
        output wire         S2_AXI_AWREADY,
        input  wire [31:0]  S2_AXI_WDATA,
        input  wire [3:0]   S2_AXI_WSTRB,
        input  wire         S2_AXI_WLAST,
        input  wire         S2_AXI_WVALID,
        output wire         S2_AXI_WREADY,
        output wire         S2_AXI_BID,
        output wire [1:0]   S2_AXI_BRESP,
        output wire         S2_AXI_BVALID,
        input  wire [31:0]  S2_AXI_ARADDR,
        input  wire [7:0]   S2_AXI_ARLEN,
        input  wire [2:0]   S2_AXI_ARSIZE,
        input  wire [1:0]   S2_AXI_ARBURST,
        input  wire         S2_AXI_ARVALID,
        output wire         S2_AXI_ARREADY,
        output wire         S2_AXI_RID,
        output wire [31:0]  S2_AXI_RDATA,
        output wire [1:0]   S2_AXI_RRESP,
        output wire         S2_AXI_RLAST,
        output wire         S2_AXI_RVALID
    );

    /* ----- アクセス制御 ----- */
    // AR, Rチャネル
    parameter AC_R_IDLE = 2'b00;
    parameter AC_R_S1   = 2'b01;
    parameter AC_R_S2   = 2'b10;

    reg [1:0] ac_r_state, ac_r_next_state;

    always @ (posedge CLK) begin
        if (RST)
            ac_r_state <= AC_R_IDLE;
        else
            ac_r_state <= ac_r_next_state;
    end

    always @* begin
        case (ac_r_state)
            AC_R_IDLE:
                if (S1_AXI_ARVALID)
                    ac_r_next_state <= AC_R_S1;
                else if (S2_AXI_ARVALID)
                    ac_r_next_state <= AC_R_S2;
                else
                    ac_r_next_state <= AC_R_IDLE;

            default:
                if (M_AXI_RLAST && M_AXI_RVALID)
                    ac_r_next_state <= AC_R_IDLE;
                else
                    ac_r_next_state <= ac_r_state;
        endcase
    end

    // AW, W, Bチャネル
    parameter AC_W_IDLE = 2'b00;
    parameter AC_W_S1   = 2'b01;
    parameter AC_W_S2   = 2'b10;

    reg [1:0] ac_w_state, ac_w_next_state;

    always @ (posedge CLK) begin
        if (RST)
            ac_w_state <= AC_W_IDLE;
        else
            ac_w_state <= ac_w_next_state;
    end

    always @* begin
        case (ac_w_state)
            AC_W_IDLE:
                if (S1_AXI_AWVALID)
                    ac_w_next_state <= AC_W_S1;
                else if (S2_AXI_AWVALID)
                    ac_w_next_state <= AC_W_S2;
                else
                    ac_w_next_state <= AC_W_IDLE;

            default:
                if (M_AXI_BVALID)
                    ac_w_next_state <= AC_W_IDLE;
                else
                    ac_w_next_state <= ac_w_state;
        endcase
    end

    /* ----- AXIバス設定 ----- */
    // 定数
    assign M_AXI_AWID       = 'b0;
    assign M_AXI_AWLOCK     = 2'b00;
    assign M_AXI_AWCACHE    = 4'b0011;
    assign M_AXI_AWPROT     = 3'h0;
    assign M_AXI_AWQOS      = 4'h0;
    assign M_AXI_AWUSER     = 'b0;
    assign M_AXI_WUSER      = 'b0;
    assign M_AXI_BREADY     = 1'b1;
    assign M_AXI_ARID       = 'b0;
    assign M_AXI_ARLOCK     = 1'b0;
    assign M_AXI_ARCACHE    = 4'b0011;
    assign M_AXI_ARPROT     = 3'h0;
    assign M_AXI_ARQOS      = 4'h0;
    assign M_AXI_ARUSER     = 'b0;
    assign M_AXI_RREADY     = 1'b1;

    // 接続バス選択
    assign M_AXI_AWADDR     = ac_w_state == AC_W_S1 ? S1_AXI_AWADDR : S2_AXI_AWADDR;
    assign M_AXI_AWLEN      = ac_w_state == AC_W_S1 ? S1_AXI_AWLEN : S2_AXI_AWLEN;
    assign M_AXI_AWSIZE     = ac_w_state == AC_W_S1 ? S1_AXI_AWSIZE : S2_AXI_AWSIZE;
    assign M_AXI_AWBURST    = ac_w_state == AC_W_S1 ? S1_AXI_AWBURST : S2_AXI_AWBURST;
    assign M_AXI_AWVALID    = ac_w_state == AC_W_S1 ? S1_AXI_AWVALID : S2_AXI_AWVALID;
    assign M_AXI_WDATA      = ac_w_state == AC_W_S1 ? S1_AXI_WDATA : S2_AXI_WDATA;
    assign M_AXI_WSTRB      = ac_w_state == AC_W_S1 ? S1_AXI_WSTRB : S2_AXI_WSTRB;
    assign M_AXI_WLAST      = ac_w_state == AC_W_S1 ? S1_AXI_WLAST : S2_AXI_WLAST;
    assign M_AXI_WVALID     = ac_w_state == AC_W_S1 ? S1_AXI_WVALID : S2_AXI_WVALID;
    assign M_AXI_ARADDR     = ac_r_state == AC_R_S1 ? S1_AXI_ARADDR : S2_AXI_ARADDR;
    assign M_AXI_ARLEN      = ac_r_state == AC_R_S1 ? S1_AXI_ARLEN : S2_AXI_ARLEN;
    assign M_AXI_ARSIZE     = ac_r_state == AC_R_S1 ? S1_AXI_ARSIZE : S2_AXI_ARSIZE;
    assign M_AXI_ARBURST    = ac_r_state == AC_R_S1 ? S1_AXI_ARBURST : S2_AXI_ARBURST;
    assign M_AXI_ARVALID    = ac_r_state == AC_R_S1 ? S1_AXI_ARVALID : S2_AXI_ARVALID;

    assign S1_AXI_AWREADY   = ac_w_state == AC_W_S1 ? M_AXI_AWREADY : 1'b0;
    assign S1_AXI_WREADY    = ac_w_state == AC_W_S1 ? M_AXI_WREADY : 1'b0;
    assign S1_AXI_BID       = ac_w_state == AC_W_S1 ? M_AXI_BID : 1'b0;
    assign S1_AXI_BRESP     = ac_w_state == AC_W_S1 ? M_AXI_BRESP : 2'b0;
    assign S1_AXI_BVALID    = ac_w_state == AC_W_S1 ? M_AXI_BVALID : 1'b0;
    assign S1_AXI_ARREADY   = ac_r_state == AC_R_S1 ? M_AXI_ARREADY : 1'b0;
    assign S1_AXI_RID       = ac_r_state == AC_R_S1 ? M_AXI_RID : 1'b0;
    assign S1_AXI_RDATA     = ac_r_state == AC_R_S1 ? M_AXI_RDATA : 32'b0;
    assign S1_AXI_RRESP     = ac_r_state == AC_R_S1 ? M_AXI_RRESP : 2'b0;
    assign S1_AXI_RLAST     = ac_r_state == AC_R_S1 ? M_AXI_RLAST : 2'b0;
    assign S1_AXI_RVALID    = ac_r_state == AC_R_S1 ? M_AXI_RVALID : 1'b0;

    assign S2_AXI_AWREADY   = ac_w_state == AC_W_S2 ? M_AXI_AWREADY : 1'b0;
    assign S2_AXI_WREADY    = ac_w_state == AC_W_S2 ? M_AXI_WREADY : 1'b0;
    assign S2_AXI_BID       = ac_w_state == AC_W_S2 ? M_AXI_BID : 1'b0;
    assign S2_AXI_BRESP     = ac_w_state == AC_W_S2 ? M_AXI_BRESP : 2'b0;
    assign S2_AXI_BVALID    = ac_w_state == AC_W_S2 ? M_AXI_BVALID : 1'b0;
    assign S2_AXI_ARREADY   = ac_r_state == AC_R_S2 ? M_AXI_ARREADY : 1'b0;
    assign S2_AXI_RID       = ac_r_state == AC_R_S2 ? M_AXI_RID : 1'b0;
    assign S2_AXI_RDATA     = ac_r_state == AC_R_S2 ? M_AXI_RDATA : 32'b0;
    assign S2_AXI_RRESP     = ac_r_state == AC_R_S2 ? M_AXI_RRESP : 2'b0;
    assign S2_AXI_RLAST     = ac_r_state == AC_R_S2 ? M_AXI_RLAST : 2'b0;
    assign S2_AXI_RVALID    = ac_r_state == AC_R_S2 ? M_AXI_RVALID : 1'b0;

endmodule

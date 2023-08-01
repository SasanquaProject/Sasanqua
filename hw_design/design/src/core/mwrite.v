module mwrite
    (
        /* ----- 制御 ----- */
        input wire          CLK,
        input wire          RST,
        input wire          STALL,

        /* ----- MMUとの接続 ----- */
        output wire         DATA_WREN,
        output wire [31:0]  DATA_WADDR,
        output wire [31:0]  DATA_WDATA,

        /* ----- メモリアクセス(r)部との接続 ----- */
        // メモリ読み取り結果
        input wire          MEMR_MEM_R_VALID,
        input wire  [4:0]   MEMR_MEM_R_RD,
        input wire  [31:0]  MEMR_MEM_R_DATA,

        // レジスタ(rv32i:W)
        input wire  [4:0]   MEMR_REG_W_RD,
        input wire  [31:0]  MEMR_REG_W_DATA,

        // レジスタ(csrs:W)
        input wire  [11:0]  MEMR_CSR_W_ADDR,
        input wire  [31:0]  MEMR_CSR_W_DATA,

        // メモリ(W)
        input wire          MEMR_MEM_W_VALID,
        input wire  [31:0]  MEMR_MEM_W_ADDR,
        input wire  [3:0]   MEMR_MEM_W_STRB,
        input wire  [31:0]  MEMR_MEM_W_DATA,

        /* ----- データフォワーディング用 ----- */
        output wire [4:0]   MEMW_REG_W_RD,
        output wire [31:0]  MEMW_REG_W_DATA,
        output wire [11:0]  MEMW_CSR_W_ADDR,
        output wire [31:0]  MEMW_CSR_W_DATA
    );

    /* ----- MMUとの接続 ----- */
    assign DATA_WREN    = MEMR_MEM_W_VALID;
    assign DATA_WADDR   = MEMR_MEM_W_ADDR;
    assign DATA_WDATA   = gen_wrdata(MEMR_MEM_W_STRB, MEMR_MEM_R_DATA, MEMR_MEM_W_DATA);

    function [31:0] gen_wrdata;
        input [3:0]     STRB;
        input [31:0]    A;
        input [31:0]    B;

        case (STRB)
            4'b0001: gen_wrdata = (A & 32'hffff_ff00) | (B & 32'h0000_00ff);
            4'b0010: gen_wrdata = (A & 32'hffff_00ff) | (B & 32'h0000_ff00);
            4'b0100: gen_wrdata = (A & 32'hff00_ffff) | (B & 32'h00ff_0000);
            4'b1000: gen_wrdata = (A & 32'h00ff_ffff) | (B & 32'hff00_0000);
            4'b0011: gen_wrdata = (A & 32'hffff_0000) | (B & 32'h0000_ffff);
            4'b0110: gen_wrdata = (A & 32'hff00_00ff) | (B & 32'h00ff_ff00);
            4'b1100: gen_wrdata = (A & 32'h0000_ffff) | (B & 32'hffff_0000);
            default: gen_wrdata = B;
        endcase
    endfunction

    /* -----  入力取り込み ----- */
    reg  [31:0] memr_reg_w_data, memr_csr_w_data;
    reg  [11:0] memr_csr_w_addr;
    reg  [4:0]  memr_reg_w_rd;

    always @ (posedge CLK) begin
        if (RST) begin
            memr_reg_w_rd <= 5'b0;
            memr_reg_w_data <= 32'b0;
            memr_csr_w_addr <= 12'b0;
            memr_csr_w_data <= 32'b0;
        end
        else if (STALL) begin
            // do nothing
        end
        else begin
            memr_reg_w_rd <= MEMR_MEM_R_VALID ? MEMR_MEM_R_RD : MEMR_REG_W_RD;
            memr_reg_w_data <= MEMR_MEM_R_VALID ? MEMR_MEM_R_DATA : MEMR_REG_W_DATA;
            memr_csr_w_addr <= MEMR_CSR_W_ADDR;
            memr_csr_w_data <= MEMR_CSR_W_DATA;
        end
    end

    /* ----- 出力 ----- */
    assign MEMW_REG_W_RD    = memr_reg_w_rd;
    assign MEMW_REG_W_DATA  = memr_reg_w_data;
    assign MEMW_CSR_W_ADDR  = memr_csr_w_addr;
    assign MEMW_CSR_W_DATA  = memr_csr_w_data;

endmodule
